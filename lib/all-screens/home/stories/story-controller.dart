
import 'package:flutter/material.dart';
import 'package:ureport_ecaro/all-screens/home/stories/model/response-story-details.dart';
import 'package:ureport_ecaro/all-screens/home/stories/save_story.dart';
import 'package:ureport_ecaro/all-screens/home/stories/story-repository.dart';
import 'package:ureport_ecaro/database/database_helper.dart';
import 'package:ureport_ecaro/locator/locator.dart';
import 'package:ureport_ecaro/network_operation/utils/connectivity_controller.dart';
import 'package:ureport_ecaro/utils/load_data_handling.dart';
import 'model/ResponseStoryLocal.dart';
import 'model/response-story-data.dart' as storyarray;

class StoryController extends ConnectivityController{

  var _storyservice = locator<StroyRipository>();

  var isExpanded = false;
  void setExpanded(bool state){
    isExpanded = state;
    notifyListeners();
  }

  var isLoading = false;
  setLoading(){
    isLoading = true;
    notifyListeners();
  }

  List<storyarray.Result> items = List.empty(growable: true);
  DatabaseHelper _databaseHelper = DatabaseHelper();

  getStoriesFromRemote(String url,String program) async {
    setLoading();
    var apiresponsedata = await _storyservice.getStory(url);

    print("Response is : ${apiresponsedata.toString()}");

    if(apiresponsedata.httpCode==200){
      items.addAll(apiresponsedata.data.results);
      if(apiresponsedata.data.next != null){
        getStoriesFromRemote(apiresponsedata.data.next,program);
      }else{
        await _databaseHelper.insertStory(items,program);
        items.forEach((element) {
          StorageUtil.writeStory(element.content, "${program}_${element.id}");
        });
        LoadDataHandling.storeStoryLastUpdate();
        isLoading = false;
        notifyListeners();
      }
    }else{
      isLoading = false;
      notifyListeners();
    }
  }

  getStoriesFromLocal(String program) {
    return _databaseHelper.getStories(program);
  }

  getCategories(String program) {
    return _databaseHelper.getStoryCategories(program);
  }

  clearStoriesTable(){
    _databaseHelper.deleteStoryTable() ;
  }

  initializeDatabase(){
    _databaseHelper.initializeDatabase().then((value) {

      print("the database story table created$value");
    });
  }
}