import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:provider/provider.dart';

import '../Assistants/assistantMethod.dart';
import '../global/mapKey.dart';
import '../infoHandler/app_info.dart';
import '../models/direction.dart';

class PrecisePickupScreen extends StatefulWidget {
  const PrecisePickupScreen({super.key});

  @override
  State<PrecisePickupScreen> createState() => _PrecisePickupScreenState();
}

class _PrecisePickupScreenState extends State<PrecisePickupScreen> {

  LatLng? pickLocation;
  loc.Location location = loc.Location();
  String ? _address;

  final Completer<GoogleMapController> _controllerGoogleMaps = Completer();
  GoogleMapController? newGoogleMapController;
  Position? userCurrentPosition;
  double bottomPaddingOfMap = 0;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  GlobalKey<ScaffoldState> _scafforState= GlobalKey<ScaffoldState>();

  locateUserPosition() async {
    try {
      Position cPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      print("User Position: ${cPosition.latitude}, ${cPosition.longitude}");
      userCurrentPosition = cPosition;

      LatLng latPosition = LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
      CameraPosition cameraPosition = CameraPosition(target: latPosition, zoom: 15);
      newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

      // Fetch address
      String humanReadableAddress = await AssistanceMethod.searchAddressForGeographicCoordinates(userCurrentPosition!, context);

      setState(() {
        pickLocation = latPosition;
        _address = humanReadableAddress; // Update the local address variable
      });

    } catch (e) {
      print("Error in locateUserPosition: $e");
    }
  }

  getAddressFromLatLag() async {
    if (pickLocation == null) return; // Ensure pickLocation is not null

    try {
      GeoData data = await Geocoder2.getDataFromCoordinates(
        latitude: pickLocation!.latitude,
        longitude: pickLocation!.longitude,
        googleMapApiKey: mapKey,
      );
      print("Geocoder Response: ${data.address}");

      Directions userPickupAddress = Directions();
      userPickupAddress.locationLatitude = pickLocation!.latitude;
      userPickupAddress.locationLongitude = pickLocation!.longitude;
      userPickupAddress.locationName = data.address;

      //  Update Pick up location of user using cursor
      Provider.of<AppInfo>(context, listen: false).updatePickUpLocationAddress(userPickupAddress);

      setState(() {
        _address = data.address; // Update the address
      });
      print("Fetched Address: $_address");
    } catch (e) {
      print("Error fetching address: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller){
              _controllerGoogleMaps.complete(controller);
              newGoogleMapController = controller;

              setState(() {
                bottomPaddingOfMap = 99;
              });

              locateUserPosition();
            },
            onCameraMove: (CameraPosition? position){
              if(pickLocation != position!.target && position != null){
                setState(() {
                  pickLocation=position.target;
                });
              }
            },
            onCameraIdle: (){
              getAddressFromLatLag();
            },
          ),

          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 35),
              child: Image.asset("assets/images/pick.png", height: 45, width: 45,),
            ),
          ),

          Positioned(
            top: 40,
            right: 20,
            left: 20,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                color: Colors.white,
              ),
              padding: EdgeInsets.all(22),
              child: Text(
                Provider.of<AppInfo> (context).userPickUpLocation?.locationName !=null
                    ? (Provider.of<AppInfo>(context).userPickUpLocation!.locationName!).substring(0,30) + "..." : "Not Getting Address.",
                overflow: TextOverflow.visible,
                softWrap: true,
                style: TextStyle(color: Colors.black),

              ),
            ),
          ),
        ],
      ),
    );
  }
}
