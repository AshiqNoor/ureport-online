import 'package:flutter/material.dart';
import 'package:ureport_ecaro/database/database_helper.dart';
import 'package:ureport_ecaro/locator/locator.dart';
import 'package:ureport_ecaro/network_operation/utils/connectivity_controller.dart';
import 'package:ureport_ecaro/utils/load_data_handling.dart';
import 'package:ureport_ecaro/utils/sp_utils.dart';
import 'model/response-opinion-localdb.dart';
import 'model/response_opinions.dart' as opinionsarray;
import 'opinion_repository.dart';
import 'model/response_opinions.dart' as questionArray;

class OpinionController extends ConnectivityController{

  DatabaseHelper _databaseHelper = DatabaseHelper();
  var sp = locator<SPUtil>();

  int opinionID = 0;

  var isExpanded = false;
  void setExpanded(bool state){
    isExpanded = state;
  }

  var isLoading = false;
  var isSyncing = false;

  setLoading(){
    isLoading = true;
    notifyListeners();
  }
  setSyncing(){
    isSyncing = true;
    notifyListeners();
  }

  var _opinionrepository = locator<OpinionRepository>();
  List<opinionsarray.Result> items = List.empty(growable: true);

  getLatestOpinions(String url,String program){
    setLoading();
    getOpinionsFromRemote(url+"?limit=40", program);
  }

  getOpinionsFromRemote(String url,String program) async {
    var apiresponsedata = await _opinionrepository.getOpinions(url);
    if(apiresponsedata.httpCode==200){
      items.addAll(apiresponsedata.data.results);
      if(apiresponsedata.data.next != null ){
        getOpinionsFromRemote(apiresponsedata.data.next,program);
      }else{
        await _databaseHelper.insertOpinion(items,program);
        LoadDataHandling.storeOpinionLastUpdate();
        isLoading = false;
        isSyncing = false;
        notifyListeners();
      }
    }
  }

  getOpinionsFromLocal(String program, int id) {
    return _databaseHelper.getOpinions(program, id);
  }

  getCategories(String program){
    return _databaseHelper.getOpinionCategories(program);
  }

  notify(){
    notifyListeners();
  }

}