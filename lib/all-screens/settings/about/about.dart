import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ureport_ecaro/locator/locator.dart';
import 'package:ureport_ecaro/utils/click_sound.dart';
import 'package:ureport_ecaro/utils/loading_bar.dart';
import 'package:ureport_ecaro/utils/remote-config-data.dart';
import 'package:ureport_ecaro/utils/resources.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ureport_ecaro/utils/sp_utils.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

import 'about_controller.dart';

class About extends StatefulWidget {
  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  late WebViewPlusController webViewController;
  double _height = 1;
  var sp = locator<SPUtil>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Provider.of<AboutController>(context, listen: false).startMonitoring();

    Provider.of<AboutController>(context, listen: false).data = sp.getValueNoNull(SPUtil.ABOUT_DATA);
    Provider.of<AboutController>(context, listen: false).title = sp.getValueNoNull(SPUtil.ABOUT_TITLE);

    Provider.of<AboutController>(context, listen: false).aboutData = null;
    Provider.of<AboutController>(context, listen: false).getAboutFromRemote(
        RemoteConfigData.getAboutUrl(sp.getValue(SPUtil.PROGRAMKEY)));

  }

  @override
  Widget build(BuildContext context) {

    return Consumer<AboutController>(
      builder: (context, provider, child) {
        return SafeArea(
          child: Scaffold(
            body: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: RemoteConfigData.getBackgroundColor(),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            ClickSound.soundClose();
                          },
                          child: Container(
                            margin: EdgeInsets.only(left: 20),
                            height: 80,
                            child: Image(
                              height: 35,
                              width: 35,
                              color: RemoteConfigData.getTextColor(),
                              image: AssetImage("assets/images/v2_ic_back.png"),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  provider.isRefreshing
                      ? Container(
                          color: RemoteConfigData.getBackgroundColor(),
                          height: 5,
                          padding: EdgeInsets.only(left: 20, right: 20),
                          child: LinearProgressIndicator(
                            color: RemoteConfigData.getPrimaryColor(),
                          ),
                        )
                      : Container(),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () {
                        return provider.isOnline?Provider.of<AboutController>(context,
                                listen: false)
                            .refreshAboutFromRemote(
                                RemoteConfigData.getAboutUrl(
                                    sp.getValue(SPUtil.PROGRAMKEY))):Future.value();
                      },
                      child: SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: provider.data != ""
                            ? Container(
                                height: _height,
                                child: WebViewPlus(
                                  onWebViewCreated: (controller) {
                                    webViewController = controller;
                                    controller.webViewController.clearCache();
                                    if(provider.isOnline){
                                      getContent(provider.title, provider.data);
                                    }else{
                                      getContentOffline(provider.title, provider.data);
                                    }

                                  },
                                  onPageFinished: (url) {
                                    webViewController
                                        .getHeight()
                                        .then((double height) {
                                      setState(() {
                                        _height = height;
                                      });
                                    });
                                  },
                                  javascriptMode: JavascriptMode.unrestricted,
                                ),
                              )
                            :provider.isOnline?Container(
                              height: MediaQuery.of(context).size.height,
                              child: Center(child: LoadingBar.spinkit),
                            ):noInternetDialog(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  noInternetDialog() {
    Timer(
      Duration(seconds: 1),
        (){
          AlertDialog alert = AlertDialog(
            content: Text(AppLocalizations.of(context)!.no_internet_text),
            actions: [
              TextButton(
                child: Text("EXIT",style: TextStyle(color: Colors.red),),
                onPressed: () {
                  ClickSound.soundClick();
                  Navigator.of(context).pop();
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: Text("RETRY"),
                onPressed: () {
                  ClickSound.soundClick();
                  Navigator.of(context).pop();
                  Provider.of<AboutController>(context, listen: false).aboutData = null;
                  Provider.of<AboutController>(context, listen: false).getAboutFromRemote(
                      RemoteConfigData.getAboutUrl(sp.getValue(SPUtil.PROGRAMKEY)));
                },
              )
            ],
          );

          // show the dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return alert;
            },
          );
        }
    );
  }

  getContent(String title, String content) {
    content = content.replaceAll(
        "<br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>",
        "<br><br>");
    content = content.replaceAll(
        "<br><br><br><br><br><br><br><br><br><br><br><br><br><br>", "<br><br>");
    content = content.replaceAll(
        "<br><br><br><br><br><br><br><br><br><br><br><br><br>", "<br><br>");
    content = content.replaceAll(
        "<br><br><br><br><br><br><br><br><br><br><br><br>", "<br><br>");
    content = content.replaceAll(
        "<br><br><br><br><br><br><br><br><br><br><br>", "<br><br>");
    content = content.replaceAll(
        "<br><br><br><br><br><br><br><br><br><br>", "<br><br>");
    content =
        content.replaceAll("<br><br><br><br><br><br><br><br><br>", "<br><br>");
    content =
        content.replaceAll("<br><br><br><br><br><br><br><br>", "<br><br>");
    content = content.replaceAll("<br><br><br><br><br><br><br>", "<br><br>");
    content = content.replaceAll("<br><br><br><br><br><br>", "<br><br>");
    content = content.replaceAll("<br><br><br><br><br>", "<br><br>");
    content = content.replaceAll("<br><br><br><br>", "<br><br>");
    content = content.replaceAll("<br><br><br>", "<br><br>");

    String final_content = '''
    <html> 
    <style>  
    body{
    background-color:${RemoteConfigData.getWebBackgroundColor()};
      margin: 0;
      padding: 0;
    }
    .content_body{
    width: 80% !important;
    margin-left: auto;
    margin-right: auto;
    display: block;
    padding: 20 20px;
    position: relative;
    z-index: 9999;
    } 
    .content_footer{
      position: absolute;
      bottom: 0;
      right: 0;
      z-index: 999999;
    }
    p{color:${RemoteConfigData.getWebTextColor()};}
    h2{color:${RemoteConfigData.getWebTextColor()};}
    b{color:${RemoteConfigData.getWebTextColor()};}
    div{color:${RemoteConfigData.getWebTextColor()};}
    
    .footer_wraper{
      display: flex;
      justify-content: center;
      background: #fff;
    }
    .footer_logo{
      margin-top:30px;
      margin-bottom: 20px;
      height: 45px;
      weight: 100%;
    }
    .cotent_footer_img{
      height: 120px;
      weight: 100%;
    }
    .content_text{
      margin-bottom:150px;
    }
    
    </style> 
    <body>
    <div class="content_body"> 
      <div><h2>$title</h2></div>
      <div class= "content_text">$content</div>
      <div class="content_footer">
        <img src = "https://storage.googleapis.com/u-report-7f1f3.appspot.com/icon/globe.png"  class="cotent_footer_img"/>
      </div>
     </div>
    <div class="footer_wraper">
      <img src = "${RemoteConfigData.getLargeIcon()}" class="footer_logo"/>
    </div> 
    </body> 
    </html>''';

    webViewController.loadUrl(Uri.dataFromString(final_content,
            mimeType: 'text/html', encoding: Encoding.getByName("UTF-8"))
        .toString());
  }

  getContentOffline(String title, String content) {
    content = content.replaceAll(
        "<br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>",
        "<br><br>");
    content = content.replaceAll(
        "<br><br><br><br><br><br><br><br><br><br><br><br><br><br>", "<br><br>");
    content = content.replaceAll(
        "<br><br><br><br><br><br><br><br><br><br><br><br><br>", "<br><br>");
    content = content.replaceAll(
        "<br><br><br><br><br><br><br><br><br><br><br><br>", "<br><br>");
    content = content.replaceAll(
        "<br><br><br><br><br><br><br><br><br><br><br>", "<br><br>");
    content = content.replaceAll(
        "<br><br><br><br><br><br><br><br><br><br>", "<br><br>");
    content =
        content.replaceAll("<br><br><br><br><br><br><br><br><br>", "<br><br>");
    content =
        content.replaceAll("<br><br><br><br><br><br><br><br>", "<br><br>");
    content = content.replaceAll("<br><br><br><br><br><br><br>", "<br><br>");
    content = content.replaceAll("<br><br><br><br><br><br>", "<br><br>");
    content = content.replaceAll("<br><br><br><br><br>", "<br><br>");
    content = content.replaceAll("<br><br><br><br>", "<br><br>");
    content = content.replaceAll("<br><br><br>", "<br><br>");

    String final_content = '''
    <html> 
    <style>  
    body{
    background-color:${RemoteConfigData.getWebBackgroundColor()};
      margin: 0;
      padding: 0;
    }
    .content_body{
    width: 80% !important;
    margin-left: auto;
    margin-right: auto;
    display: block;
    padding: 20 20px;
    position: relative;
    z-index: 9999;
    } 
    .content_footer{
      position: absolute;
      bottom: 0;
      right: 0;
      z-index: 999999;
    }
    p{color:${RemoteConfigData.getWebTextColor()};}
    h2{color:${RemoteConfigData.getWebTextColor()};}
    b{color:${RemoteConfigData.getWebTextColor()};}
    div{color:${RemoteConfigData.getWebTextColor()};}
    
    .footer_wraper{
      display: flex;
      justify-content: center;
      background: #fff;
    }
    .footer_logo{
      margin-top:30px;
      margin-bottom: 20px;
      height: 45px;
      weight: 100%;
    }
    .cotent_footer_img{
      height: 120px;
      weight: 100%;
    }
    .content_text{
      margin-bottom:150px;
    }
    
    </style> 
    <body>
    <div class="content_body"> 
      <div><h2>$title</h2></div>
      <div class= "content_text">$content</div>
     </div>
    </body> 
    </html>''';

    webViewController.loadUrl(Uri.dataFromString(final_content,
            mimeType: 'text/html', encoding: Encoding.getByName("UTF-8"))
        .toString());
  }
}
