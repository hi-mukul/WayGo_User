import 'dart:async';
import 'package:flutter/material.dart';
import 'package:waygo/Assistants/assistantMethod.dart';
import 'package:waygo/global/global.dart';
import 'package:waygo/screens/loginScreen.dart';
import 'package:waygo/screens/mainScreen.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {


  startTime(){
    Timer(Duration(seconds: 3), () async {
      if(await firebaseAuth.currentUser != null){
        firebaseAuth.currentUser != null ? AssistanceMethod.readCurrentOnlineInfo() : null;
        Navigator.push(context, MaterialPageRoute(builder: (c)=> MainScreen()));
      }else{
        Navigator.push(context, MaterialPageRoute(builder: (c)=>Loginscreen()));
      }
    });
  }


  @override

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTime();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('WayGo',style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),),
      ),
    );
  }
}
