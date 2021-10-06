import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ureport_ecaro/all-screens/home/stories/stories-details.dart';
import 'package:ureport_ecaro/all-screens/home/stories/story-controller.dart';
import 'package:provider/provider.dart';
import 'package:ureport_ecaro/all-screens/home/stories/story_search.dart';
import 'package:ureport_ecaro/locator/locator.dart';
import 'package:ureport_ecaro/utils/click_sound.dart';
import 'package:ureport_ecaro/utils/load_data_handling.dart';
import 'package:ureport_ecaro/utils/loading_bar.dart';
import 'package:ureport_ecaro/utils/nav_utils.dart';
import 'package:ureport_ecaro/utils/remote-config-data.dart';
import 'package:ureport_ecaro/utils/resources.dart';
import 'package:ureport_ecaro/utils/snackbar.dart';
import 'package:ureport_ecaro/utils/sp_utils.dart';
import 'package:ureport_ecaro/utils/top_bar_background.dart';
import 'model/ResponseStoryLocal.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StoryList extends StatefulWidget {
  @override
  _StoryListState createState() => _StoryListState();
}

class _StoryListState extends State<StoryList> with AutomaticKeepAliveClientMixin{
  var sp = locator<SPUtil>();

  int itemCount = 10;

  @override
  void initState() {
    super.initState();
    Provider.of<StoryController>(context, listen: false).startMonitoring();
  }

  @override
  Widget build(BuildContext context) {

    Provider.of<StoryController>(context, listen: false).initializeDatabase();
    List<ResultLocal>? stories = [];

    if(Provider.of<StoryController>(context, listen: false).isLoaded){
      Provider.of<StoryController>(context, listen: false).getRecentStory(
          RemoteConfigData.getStoryUrl(sp.getValue(SPUtil.PROGRAMKEY)),
          sp.getValue(SPUtil.PROGRAMKEY));
      Provider.of<StoryController>(context, listen: false).isLoaded = false;
    }


    return Consumer<StoryController>(builder: (context, provider, snapshot) {
      var _futureStory = provider.getStoriesFromLocal(sp.getValue(SPUtil.PROGRAMKEY));
      return SafeArea(
          child: Scaffold(
              body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TopBar.getTopBar(AppLocalizations.of(context)!.stories),
            Container(
              child: Divider(
                height: 1.5,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(
              height: 5,
            ),
            provider.isSyncing
                ? Container(
                    height: 5,
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: LinearProgressIndicator(
                      color: RemoteConfigData.getPrimaryColor(),
                    ),
                  )
                : Container(),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: GestureDetector(
                onTap: () {
                  ClickSound.soundTap();
                  NavUtils.push(context, StorySearch());
                },
                child: Card(
                  elevation: 2,
                  child: Container(
                    height: 40,
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.search,
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          Icon(
                            Icons.arrow_drop_down,
                            color: Colors.grey,
                            size: 38,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: FutureBuilder<List<ResultLocal>>(
                  future: _futureStory,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      stories = List.from(snapshot.data!.reversed);
                    }
                    return RefreshIndicator(
                      onRefresh: () {
                        return _futureStory =
                            getDataFromApi(context, provider); // EDITED
                      },
                      child: stories!.length > 0
                          ? Container(
                              padding: EdgeInsets.only(left: 20, right: 20),
                              child: ListView.builder(
                                  physics: ScrollPhysics(),
                                  shrinkWrap: true,
                                  addAutomaticKeepAlives: true,
                                  itemCount: stories!.length <= 10
                                      ? stories!.length
                                      : itemCount <= stories!.length ?
                                  itemCount + 1 : stories!.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return GestureDetector(
                                      onTap: () {
                                        ClickSound.soundTap();
                                        NavUtils.push(
                                            context,
                                            StoryDetails(
                                                stories![index].id.toString(),
                                                stories![index]
                                                    .title
                                                    .toString(),
                                                stories![index]
                                                    .images
                                                    .toString(),
                                                stories![index]
                                                    .createdOn
                                                    .toString()));
                                      },
                                      child: Container(
                                        child: index <= itemCount - 1
                                            ? getItem(
                                                stories?[index].images != ''
                                                    ? stories![index].images
                                                    : "assets/images/default.jpg",
                                                stories![index].featured,
                                                stories![index].title,
                                                stories![index].summary,
                                                context)
                                            : Container(
                                                margin: EdgeInsets.only(
                                                    top: 5, bottom: 20),
                                                height: 35,
                                                child: GestureDetector(
                                                  onTap: (){
                                                    ClickSound.soundTap();
                                                    itemCount = itemCount+ 10;
                                                    setState(() {});
                                                  },
                                                    child: Center(
                                                        child:
                                                            Text(
                                                              AppLocalizations.of(context)!.see_more,
                                                              style: TextStyle(
                                                                fontSize: 18,
                                                                color: Colors.black,
                                                                decoration: TextDecoration.underline
                                                              ),
                                                            )
                                                    )
                                                )
                                        ),
                                      ),
                                    );
                                  }),
                            )
                          : Center(
                              child: Container(
                                height: 60,
                                width: 60,
                                child: LoadingBar.spinkit,
                              ),
                            ),
                    );
                  }),
            )
          ],
        ),
      )));
    });
  }

  Future<dynamic> getDataFromApi(
      BuildContext context, StoryController provider) async {
    if (provider.isOnline) {
      Provider.of<StoryController>(context, listen: false).setSyncing();
      return Provider.of<StoryController>(context, listen: false)
          .getRecentStory(
              RemoteConfigData.getStoryUrl(sp.getValue(SPUtil.PROGRAMKEY)),
              sp.getValue(SPUtil.PROGRAMKEY));
    } else {
      return ShowSnackBar.showNoInternetMessage(context);
    }
  }

  @override

  bool get wantKeepAlive => true;
}

getBackground() {
  return Image(image: AssetImage("assets/images/bg_home.png"));
}

getItem(String image_url, String featured, String title, String summery, BuildContext context) {
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    margin: EdgeInsets.only(top: 10, bottom: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        getItemTitleImage(image_url),
        getItemFeatured(featured,context),
        getItemTitle(title),
        getItemSummery(summery, context),
      ],
    ),
  );
}
//test

getItemTitleImage(String image_url) {
  return ClipRRect(
    borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10), topRight: Radius.circular(10)),
    child: CachedNetworkImage(
      height: 200,
      fit: BoxFit.cover,
      imageUrl: image_url,
      progressIndicatorBuilder: (context, url, downloadProgress) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              height: 60,
              width: 60,
              child: LoadingBar.spinkit,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text("Loading")
        ],
      ),
      errorWidget: (context, url, error) => Container(
          color: AppColors.errorWidgetBack,
          child: Center(
            child: Container(
              height: 50,
              width: 50,
              child: LoadingBar.spinkit,
            ),
          )
      ),
    ),
  );
}

getItemFeatured(String featured, BuildContext context) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Container(
        margin: EdgeInsets.only(left: 10, top: 15, bottom: 5, right: 10),
        height: 10,
        width: 10,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: RemoteConfigData.getBackgroundColor()),
      ),
      Container(
        margin: EdgeInsets.only(top: 10),
        child: Text(
          featured == "true" ? AppLocalizations.of(context)!.featured_story : "STORY",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        ),
      )
    ],
  );
}

getItemTitle(String title) {
  return Container(
    padding: EdgeInsets.all(10),
    child: Text(
      title,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  );
}

getItemSummery(String summery, BuildContext context) {
  return Container(
      padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: RichText(
        text: TextSpan(
          style:
              TextStyle(fontSize: 14, color: Colors.black),
          children: <TextSpan>[
            TextSpan(text: summery),
            TextSpan(
                text: summery.length != 0?" ${AppLocalizations.of(context)!.read_more}":"${AppLocalizations.of(context)!.read_more}",
                style: new TextStyle(
                    fontSize: 13, color: RemoteConfigData.getPrimaryColor())),
          ],
        ),
      ));
}
