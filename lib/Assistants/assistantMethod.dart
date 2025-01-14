import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:waygo/Assistants/requestAssistant.dart';
import 'package:waygo/global/global.dart';
import 'package:waygo/models/direction.dart';
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

  static Future<String> searchAddressForGeographicCoordinates(Position position, context) async {
    String apiKey = 'AIzaSyAdaCJqLrTD3MUmTqFuI_xAhMcIh74xyXo'; // Use your Google Maps API Key
    // Google Maps API URL
    String apiUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    String humanReadableAddress = "";

    // Handle API response
    var requestResponse = await RequestAssistant.recieveRequest(apiUrl);

    if (requestResponse != "Error occured. Failed No response" && requestResponse["results"] != null && requestResponse["results"].isNotEmpty) {
      humanReadableAddress = requestResponse["results"][0]["formatted_address"];

      Directions userPickupAddress = Directions();
      userPickupAddress.locationLatitude = position.latitude;
      userPickupAddress.locationLongitude = position.longitude;
      userPickupAddress.locationName = humanReadableAddress;

      // Optional: Update the context's state (if needed)
      // Provider.of<AppInfo>(context, listen: false).updatePickUpLocationAddress(userPickupAddress);
    }

    return humanReadableAddress;
  }

}