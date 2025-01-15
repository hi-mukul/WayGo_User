import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:provider/provider.dart';
import 'package:waygo/Assistants/assistantMethod.dart';
import 'package:waygo/global/global.dart';
import 'package:waygo/global/mapKey.dart';
import 'package:waygo/infoHandler/app_info.dart';

import '../models/direction.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  LatLng? pickLocation;
  loc.Location location = loc.Location();
  String ? _address;

  final Completer<GoogleMapController> _controllerGoogleMaps = Completer();
  GoogleMapController? newGoogleMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );


  @override

  GlobalKey<ScaffoldState> _scafforState= GlobalKey<ScaffoldState>();
  double searchLocationContainerHeight=220;
  double waitingResponseFromDriverContainerHeight=0;
  double assignedDriverInfoContainerHeight=0;

  Position? userCurrentPosition;
  var geoLocation=Geolocator();
  LocationPermission? _locationPermission;
  double bottomPaddingOfMap = 0;

  List<LatLng> pLineCoordinates=[];
  Set<Polyline> polyLinetSet={};
  Set<Marker> markerSet={};
  Set<Circle> circlesSet={};

  String userName= "";
  String userEmail="";

  bool openNavigationDrawer=true;

  bool activeNearbyDriverKeysLoaded=false;

  BitmapDescriptor? activeNearbyIcon;

  locateUserPosition() async {
    try {
      Position cPosition = await Geolocator.getCurrentPosition();
      print("User Position: ${cPosition.latitude}, ${cPosition.longitude}");
      userCurrentPosition = cPosition;

      LatLng latPosition = LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
      CameraPosition cameraPosition = CameraPosition(target: latPosition, zoom: 15);
      newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

      // Fetch address
      String humanReadableAddress = await AssistanceMethod.searchAddressForGeographicCoordinates(userCurrentPosition!, context);
      print("Fetched Address from AssistanceMethod: $humanReadableAddress");

      setState(() {
        pickLocation = latPosition;
        _address = humanReadableAddress; // Update the local address variable
      });

      userName = userModleCurrentInfo?.name ?? "Unknown User";
      userEmail = userModleCurrentInfo?.email ?? "Unknown Email";

      print("UserName: $userName, UserEmail: $userEmail");
    } catch (e) {
      print("Error in locateUserPosition: $e");
    }
  }

    // initializedGeoFireListener();
    //
    // AssistanceMethod.readTripKeysForOnlineUser(context);


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


  checkIfLocationPermissionAllowed() async {
    try {
      _locationPermission = await Geolocator.requestPermission();
      if (_locationPermission == LocationPermission.denied) {
        _locationPermission = await Geolocator.requestPermission();
      }
      if (_locationPermission == LocationPermission.deniedForever) {
        print("Location permissions are permanently denied. Please enable them in settings.");
      }
    } catch (e) {
      print("Error in checkIfLocationPermissionAllowed: $e");
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkIfLocationPermissionAllowed();
  }

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              mapType: MapType.normal,
              myLocationEnabled: true,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
              initialCameraPosition: _kGooglePlex,
              polylines: polyLinetSet,
              markers: markerSet,
              circles: circlesSet,
              onMapCreated: (GoogleMapController controller){
                _controllerGoogleMaps.complete(controller);
                newGoogleMapController = controller;

                setState(() {
                  bottomPaddingOfMap = 200;
                });

                locateUserPosition();
              },
              onCameraMove: (CameraPosition? position){
                if(pickLocation != position!.target){
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
                      ? (Provider.of<AppInfo>(context).userPickUpLocation!.locationName!).substring(0,24) + "..." : "Not Getting Address.",
                  overflow: TextOverflow.visible,
                  softWrap: true,
                  style: TextStyle(color: Colors.black),

                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}