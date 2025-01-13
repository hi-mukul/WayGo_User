import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:waygo/global/global.dart';
import 'package:waygo/models/userModel.dart';

import '../global/mapKey.dart';

class AssistanceMethod{

  static void readCurrentOnlineInfo() async{
    currentUser = firebaseAuth.currentUser;
    DatabaseReference userRef = FirebaseDatabase.instance
     .ref()
     .child("users")
     .child(currentUser!.uid);
    userRef.once().then((snap){
      if(snap.snapshot.value != null){
        userModleCurrentInfo = userModel.fromSnapShot(snap.snapshot);
      }
    });
  }

  static Future<String> searchAddressForGeographicCoordinates(Position position, context) async{

    // Google map API url
    String apiUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    String humanReadableAddress = "";

    var requestResponse =  await Reaquest

    return humanReadableAddress;

  }
}