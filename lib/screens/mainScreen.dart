import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:waygo/Assistants/assistantMethod.dart';
import 'package:waygo/global/global.dart';
import 'package:waygo/global/mapKey.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  LatLng? pickLoaction;
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

  locateUserPosition() async{
    Position cPosition = await Geolocator.getCurrentPosition();
    userCurrentPosition = cPosition;

    LatLng latPosition =  LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
    CameraPosition cameraPosition= CameraPosition(target: latPosition, zoom: 15);

    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String humanReadableAddress =  await AssistanceMethod.searchAddressForGeographicCoordinates(userCurrentPosition!, context);
    print("This is our address =" + humanReadableAddress);
    setState(() {
      pickLoaction = latPosition; // Update pickLoaction
      _address = humanReadableAddress; // Update address
    });

    userName = userModleCurrentInfo!.name!;
    userEmail = userModleCurrentInfo!.email!;

    // initializedGeoFireListener();
    //
    // AssistanceMethod.readTripKeysForOnlineUser(context);
  }

  getAddressFromLatLag() async {
    if (pickLoaction == null) return; // Ensure pickLoaction is not null

    try {
      GeoData data = await Geocoder2.getDataFromCoordinates(
        latitude: pickLoaction!.latitude,
        longitude: pickLoaction!.longitude,
        googleMapApiKey: mapKey,
      );
      setState(() {
        _address = data.address; // Update the address
      });
      print("Fetched Address: $_address");
    } catch (e) {
      print("Error fetching address: $e");
    }
  }


  checkIfLocationPermissionAllowed()async{
    _locationPermission = await Geolocator.requestPermission();

    if(_locationPermission == LocationPermission.denied){
      _locationPermission  = await Geolocator.requestPermission();
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

                });

                locateUserPosition();
              },
              onCameraMove: (CameraPosition? position){
                if(pickLoaction != position!.target){
                  setState(() {
                    pickLoaction=position.target;
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
                padding: EdgeInsets.all(21),
                child: Text(_address ?? "Set your pickup location ",
                  overflow: TextOverflow.visible,
                  softWrap: true,
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}