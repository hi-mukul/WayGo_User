import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:waygo/Assistants/requestAssistant.dart';
import 'package:waygo/global/global.dart';
import 'package:waygo/infoHandler/app_info.dart';
import 'package:waygo/models/direction.dart';
import 'package:waygo/models/userModel.dart';
import '../global/mapKey.dart';
import '../models/direction_details_info.dart';

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
    String apiKey = 'AIzaSyCE0GI59jwIGDTK-zgJpn-A7wX_bi7S0Og'; // Use your Google Maps API Key
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
      Provider.of<AppInfo>(context, listen: false).updatePickUpLocationAddress(userPickupAddress);
    }

    return humanReadableAddress;
  }

  static Future<DirectionDetailsInfo> obtainOriginToDestinationDirectionDetails(LatLng originPosition, LatLng destinationPosition) async{

    String urlOriginToDestinationDirectionsDetails = "https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude}, ${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapKey";
    var responseDirectionApi = await RequestAssistant.recieveRequest(urlOriginToDestinationDirectionsDetails);

    // if (responseDirectionApi == "Error occured. Failed No response") {
    //   return null;
    // }

    DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();
    directionDetailsInfo.e_points = responseDirectionApi["routes"][0]["overview_polyline"]["points"];

    directionDetailsInfo.distance_text = responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
    directionDetailsInfo.distance_value = responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];

    directionDetailsInfo.duration_text = responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
    directionDetailsInfo.duration_value = responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetailsInfo;
  }

}