
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ureport_ecaro/all-screens/home/navigation-screen.dart';
import 'package:ureport_ecaro/database/database_helper.dart';
import 'package:ureport_ecaro/locator/locator.dart';
import 'package:ureport_ecaro/utils/nav_utils.dart';
import 'package:ureport_ecaro/utils/sp_utils.dart';

class SeetingDetails extends StatefulWidget{
  @override
  _SeetingDetailsState createState() => _SeetingDetailsState();
}

class _SeetingDetailsState extends State<SeetingDetails> {
  DatabaseHelper _databaseHelper = DatabaseHelper();
  var spservice = locator<SPUtil>();
  late String switchstate;
  bool statesf=true;
    @override
  void initState() {
    switchstate= spservice.getValue(SPUtil.DELETE5DAYS);
    if(switchstate=="true"){
      statesf=true;
    }else statesf=false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Color(0xffF5FCFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Icon(Icons.arrow_back,color: Colors.black,),
        title: Text("Seetings",style: TextStyle(color: Colors.black,fontSize: 18),),
      ),
      body: Column(
        children: [

          Container(
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10))
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Notification",style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold),),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset("assets/images/ic_sound.png",height: 15,width: 15,),
                    SizedBox(width: 8,),
                    Text("ON/OFF",style: TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.w700),),
                    Spacer(),
                    Expanded(
                      child: SwitchListTile(
                          value: true, onChanged: (value){}
                      ),
                    ),

                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 15,),

          Container(
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10))
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Sound",style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold),),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset("assets/images/ic_sound.png",height: 15,width: 15,),
                    SizedBox(width: 8,),
                    Text("ON/OFF",style: TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.w700),),
                    Spacer(),
                    Expanded(
                      child: SwitchListTile(
                          value: true, onChanged: (value){}
                      ),
                    ),

                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 15,),
          Container(
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10))
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Chat",style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold),),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset("assets/images/ic_chatt.png",height: 15,width: 15,),
                    SizedBox(width: 8,),
                    Expanded(child: Text("Automatically remove message after 5 days",style: TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.w700),)),
                    SizedBox(width: 60,),
                    Switch(
                        value: statesf, onChanged: (value){
                      spservice.setValue(SPUtil.DELETE5DAYS, value.toString());

                    }
                    ),

                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset("assets/images/ic_chatt.png",height: 15,width: 15,),
                    SizedBox(width: 8,),
                    Text("Remove all message",style: TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.w700),),
                    Spacer(),
                    GestureDetector(
                      onTap: ()async{

                        showDialog(context: context, builder: (_){

                          return Dialog(

                            child: Container(
                              margin: EdgeInsets.only(left: 10,right: 10),

                              width: double.infinity,
                              height: 120,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                  color: Colors.white

                              ),
                              child: Column(

                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [

                                  SizedBox(height: 5,),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Are You Sure?Do you want to delete this message? ",style:TextStyle(color:Colors.red,fontSize: 15)),

                                    ],
                                  ),
                                  SizedBox(height: 5,),

                                  GestureDetector(
                                      onTap:()async{
                                        await _databaseHelper.deleteConversation().then((value) {

                                          NavUtils.push(context,NavigationScreen());

                                        });
                                      },
                                      child: Text("Delete",style: TextStyle(color: Colors.red,fontSize: 18),)),
                                  SizedBox(height: 10,),
                                  Divider(height: 1,color: Colors.grey,),
                                  SizedBox(height: 10,),
                                  GestureDetector(
                                      onTap:(){
                                        Navigator.pop(context);
                                      },
                                      child: Text("Cancel",style: TextStyle(color: Colors.blue,fontSize: 18),)),

                                ],
                              ),
                            ),
                          );
                        });


                      },
                      child: Container(
                        padding: EdgeInsets.only(left: 15,right: 15,top: 3,bottom: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          color: Color(0xff41B6E6),
                        ),
                        child: Text("Remove",style: TextStyle(color: Colors.white,fontSize: 10),),
                      ),
                    ),

                  ],
                ),
              ],
            ),
          ),



        ],
      ),
    );
  }
}