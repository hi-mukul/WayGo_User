import 'package:flutter/material.dart';
import 'package:waygo/models/direction.dart';

class AppInfo extends ChangeNotifier{
  Directions ? userPickUpLocation, userDropOffLocation;
  int countTotalTrips = 0;
  // List<String> historyTripKeyList=[];
  // List<TripHistoryModel> allTripshistoryInfoList=[];

  void updatePickUpLocationAddress(Directions userPickUpAddress){
    userPickUpLocation = userPickUpAddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress(Directions dropOffAddress){
    userDropOffLocation = dropOffAddress;
    notifyListeners();
  }
}