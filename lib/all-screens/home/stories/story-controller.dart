
import 'package:flutter/material.dart';
import 'package:ureport_ecaro/all-screens/home/stories/model/response-story-details.dart';
import 'package:ureport_ecaro/all-screens/home/stories/story-repository.dart';
import 'package:ureport_ecaro/database/database_helper.dart';
import 'package:ureport_ecaro/locator/locator.dart';
import 'model/ResponseStoryLocal.dart';
import 'model/response-story-data.dart' as storyarray;

class StoryController extends ChangeNotifier{

  var _storyservice = locator<StroyRipository>();

  List<storyarray.Result> items = List.empty(growable: true);
  DatabaseHelper _databaseHelper = DatabaseHelper();

  getStoriesFromRemote(String url,String program) async {
    var apiresponsedata = await _storyservice.getStory(url);
    if(apiresponsedata.httpCode==200){
      items.addAll(apiresponsedata.data.results);
      if(apiresponsedata.data.next != null){
        getStoriesFromRemote(apiresponsedata.data.next,program);
      }else{
        _databaseHelper.insertStory(items,program);
        notifyListeners();
      }
    }
  }

  getStoriesFromLocal(String program) {
    return _databaseHelper.getStories(program);

  }

  clearStoriesTable(){
    _databaseHelper.deleteStoryTable() ;
  }

  initializeDatabase(){
    _databaseHelper.initializeDatabase().then((value) {
    });
  }
}