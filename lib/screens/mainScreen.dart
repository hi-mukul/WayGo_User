import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:provider/provider.dart';
import 'package:waygo/Assistants/assistantMethod.dart';
import 'package:waygo/global/global.dart';
import 'package:waygo/infoHandler/app_info.dart';
import 'package:waygo/screens/precise_pickUp_location.dart';
import 'package:waygo/screens/searchPlaceScreen.dart';
import '../global/mapKey.dart';
import '../models/direction.dart';
import '../widgets/progress_dialog.dart';

class MainScreen extends StatefulWidget {

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
  GlobalKey<ScaffoldState> _scafforState= GlobalKey<ScaffoldState>();

  double searchLocationContainerHeight=220;
  double waitingResponseFromDriverContainerHeight=0;
  double assignedDriverInfoContainerHeight=0;

  Position? userCurrentPosition;
  var geoLocation=Geolocator();
  LocationPermission? _locationPermission;
  double bottomPaddingOfMap = 0;

  List<LatLng> pLineCoordinatedList=[];
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
      Position cPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      print("User Position: ${cPosition.latitude}, ${cPosition.longitude}");
      userCurrentPosition = cPosition;

      LatLng latPosition = LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
      CameraPosition cameraPosition = CameraPosition(target: latPosition, zoom: 15);
      newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

      // Fetch address
      String humanReadableAddress = await AssistanceMethod.searchAddressForGeographicCoordinates(userCurrentPosition!, context);
      print("Fetched Address from AssistanceMethod : " +humanReadableAddress);

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

  Future<void> drawPolyFromOriginToDestination(bool darkTheme) async{
    var originPosition = Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
    var destinationPosition = Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

    var originLatLng = LatLng(originPosition!.locationLatitude!, originPosition.locationLongitude!);
    var destinationLatLng = LatLng(destinationPosition!.locationLatitude!, destinationPosition.locationLongitude!);

    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(message: "Please wait", ),
    );

    var  directionDetailsInfo = await AssistanceMethod.obtainOriginToDestinationDirectionDetails(originLatLng, destinationLatLng);
    setState(() {
      tripDirectionDetailsInfo = directionDetailsInfo;
    });

    Navigator.pop(context);

    PolylinePoints pPoints=PolylinePoints();
    List<PointLatLng> decodePolyLinePointsResultList = pPoints.decodePolyline(directionDetailsInfo.e_points!);

    pLineCoordinatedList.clear();

    if(decodePolyLinePointsResultList.isNotEmpty){
      decodePolyLinePointsResultList.forEach((PointLatLng pointLatLng){
        pLineCoordinatedList.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polyLinetSet.clear();
    setState(() {
      Polyline polyLine = Polyline(
        color: darkTheme?  Colors.amberAccent : Colors.blue,
        polylineId: PolylineId("PolylineID"),
        jointType: JointType.round,
        points: pLineCoordinatedList,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
        width: 5,
      );

      polyLinetSet.add(polyLine);

    });

    LatLngBounds boundsLatLng;
    if(originLatLng.latitude > destinationLatLng.latitude && originLatLng.longitude > destinationLatLng.longitude){
      boundsLatLng =  LatLngBounds(
          southwest: destinationLatLng,
          northeast: originLatLng,
      );
    }
    else if(originLatLng.longitude> destinationLatLng.longitude){
      boundsLatLng = LatLngBounds(
          southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
          northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude),
      );
    }
    else if(originLatLng.latitude> destinationLatLng.latitude){
      boundsLatLng = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
        northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude),
      );
    }
    else{
      boundsLatLng = LatLngBounds(
          southwest: originLatLng,
          northeast: destinationLatLng,
      );
    }

    newGoogleMapController!.animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));

    Marker originMarker = Marker(
        markerId: MarkerId("originID"),
      infoWindow: InfoWindow(title: originPosition.locationName, snippet: "Origin"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: MarkerId("destinationID"),
      infoWindow: InfoWindow(title: destinationPosition.locationName, snippet: "Destination"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      markerSet.add(originMarker);
      markerSet.add(destinationMarker);
    });

    Circle originCircle = Circle(
      circleId: CircleId("originID"),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: originLatLng,
    );

    Circle destinatonCircle = Circle(
      circleId: CircleId("destinationID"),
      fillColor: Colors.red,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: destinationLatLng,
    );

    setState(() {
      circlesSet.add(originCircle);
      circlesSet.add(destinatonCircle);
    });

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
    bool darkTheme=MediaQuery.of(context).platformBrightness==Brightness.dark;
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


            // UI for searching location 
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(color: darkTheme? Colors.black : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color:  darkTheme ? Colors.grey.shade900 : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Padding(padding: EdgeInsets.all(6),
                                  child: Row(
                                    children: [
                                      Icon(Icons.location_on_outlined, color:darkTheme? Colors.amber.shade500 : Colors.blue,),
                                      SizedBox(width: 10,),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("From",
                                            style: TextStyle(
                                                color: darkTheme? Colors.amber.shade500 : Colors.blue,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold
                                            ),
                                          ),
                                          Text(
                                            Provider.of<AppInfo> (context).userPickUpLocation !=null
                                                       ? (Provider.of<AppInfo>(context).userPickUpLocation!.locationName!).substring(0,30) + "..."
                                                : "Not Getting Address.",
                                            style: TextStyle(color: Colors.grey, fontSize: 15, ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 4,),

                                Divider(
                                  height: 1,
                                  thickness: 2,
                                  color: darkTheme? Colors.amber.shade500 : Colors.blue,
                                ),

                                SizedBox(height: 4,),

                                Padding(padding: EdgeInsets.all(5),
                                  child: GestureDetector(
                                    onTap: () async {
                                      // go to search place screen
                                      var responseFromSearchScreen = await Navigator.push(context, MaterialPageRoute(builder: (c) => SearchPlaceScreen()));

                                      if(responseFromSearchScreen == "obtainedDropoof"){
                                        setState(() {
                                          openNavigationDrawer = false;
                                        });
                                      }

                                      await drawPolyFromOriginToDestination(darkTheme);

                                    },
                                    child: Row(
                                      children: [
                                        Icon(Icons.location_on_outlined, color:darkTheme? Colors.amber.shade500 : Colors.blue,),
                                        SizedBox(width: 10,),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("To",
                                              style: TextStyle(
                                                  color: darkTheme? Colors.amber.shade500 : Colors.blue,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold
                                              ),
                                            ),
                                            Text(
                                              Provider.of<AppInfo> (context).userDropOffLocation !=null
                                                  ? Provider.of<AppInfo>(context).userDropOffLocation!.locationName!
                                                  : "Where to?.",
                                              style: TextStyle(color: Colors.grey, fontSize: 15, ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 5,),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                    onPressed: (){
                                      Navigator.push(context, MaterialPageRoute(builder: (c)=> PrecisePickupScreen()));
                                    },
                                    child: Text(
                                        "Change PickUp",
                                      style: TextStyle(
                                        color: darkTheme? Colors.black : Colors.white,
                                      ),
                                    ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: darkTheme? Colors.amber.shade500 : Colors.blue,
                                    foregroundColor: darkTheme? Colors.black : Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    textStyle: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                
                                    )
                                  ),
                                ),
                              ),

                              SizedBox(
                                height: 12,
                                width: 5,
                              ),

                              Expanded(
                                child: ElevatedButton(
                                  onPressed: (){
                                
                                  },
                                  child: Text(
                                    "Request a ride",
                                    style: TextStyle(
                                      color: darkTheme? Colors.black : Colors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: darkTheme? Colors.amber.shade500 : Colors.blue,
                                      foregroundColor: darkTheme? Colors.black : Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      textStyle: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                
                                      )
                                  ),
                                ),
                              ),
                            ],
                          ),

                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Positioned(
            //   top: 40,
            //   right: 20,
            //   left: 20,
            //   child: Container(
            //     decoration: BoxDecoration(
            //       border: Border.all(color: Colors.black),
            //       color: Colors.white,
            //     ),
            //     padding: EdgeInsets.all(22),
            //     child: Text(
            //       Provider.of<AppInfo> (context).userPickUpLocation?.locationName !=null
            //           ? (Provider.of<AppInfo>(context).userPickUpLocation!.locationName!).substring(0,30) + "..." : "Not Getting Address.",
            //       overflow: TextOverflow.visible,
            //       softWrap: true,
            //       style: TextStyle(color: Colors.black),
            //
            //     ),
            //   ),
            // ),

          ],
        ),
      ),
    );
  }
}