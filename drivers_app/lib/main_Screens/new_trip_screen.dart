import 'dart:async';

import 'package:drivers_app/assistants/assistant_methods.dart';
import 'package:drivers_app/assistants/black_theme_google_map.dart';
import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/infoHandler/app_info.dart';
import 'package:drivers_app/models/user_ride_request_information.dart';
import 'package:drivers_app/widgets/progress_dialog.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class NewTripScreen extends StatefulWidget {
  UserRideRequestInformation? userRideRequestDetails;
  NewTripScreen({this.userRideRequestDetails});

  @override
  State<NewTripScreen> createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {
  GoogleMapController? newTripGoogleMapController;
  //here we have created the instance of the GoogleMapController
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  String? buttonTitle = "Arrived";
  Color? buttonColor = Colors.green;
  //String? statusBtn="accepted";

  Set<Marker> setOfMarkers = Set<Marker>();
  Set<Circle> setOfCircle = Set<Circle>();
  Set<Polyline> setOfPolyline = Set<Polyline>();
  List<LatLng> polylinePositionCoordinates = [];//Lat & lng of user current location and mechanic current location
  PolylinePoints polylinePoints = PolylinePoints();

  double mapPadding=0;

  
  BitmapDescriptor? iconAnimatedMarker;
  var geoLocator = Geolocator();

  Position? onlineDriverCurrentPosition;

  String rideRequestStatus="accepted";
  String durationFromOriginToDestination="";

  bool isRequestDirectionDetails=false;

  //method of draw polyline from source to destionation form mainscreen.dart of the users_app

  @override
  void initState() {
    super.initState();

    saveAssignedDriverDetailstoUserRideRequest();
  }

  

  createDriverIconMarker() {
    if (iconAnimatedMarker == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: const Size(2, 2));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/car.png")
          .then((value) {
        iconAnimatedMarker = value;
      });
    }
  }


  getDriversLocationUpdatesAtRealTime() {

    LatLng oldLatLng=LatLng(0, 0);

    streamSubscriptionDriverLivePosition =
        Geolocator.getPositionStream().listen((Position position) {
      driverCurrentPosition = position;
      //when the driver is moving then we can get the live location of the driver using thiss
      onlineDriverCurrentPosition = position;

      LatLng latLngLiveDriverPosition = LatLng(
          onlineDriverCurrentPosition!.latitude,
          onlineDriverCurrentPosition!.longitude);

      //we want marker at updating live location of driver
      Marker animatingMarker=Marker(
        markerId: MarkerId("AnimatedMarker"),
        position: latLngLiveDriverPosition,
        icon:  iconAnimatedMarker ?? BitmapDescriptor.defaultMarker, // using the null-coalescing operator
        infoWindow: const InfoWindow(
          title: "This is your current location.",
        ),
      );

      setState(() {
        //driver icon marker will move according to the live location of driver
        CameraPosition cameraPosition = CameraPosition(
          target: latLngLiveDriverPosition,
          zoom: 16,
        );
      
        newTripGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

        //previous marker would get removed while updating new one
        setOfMarkers.removeWhere((element) => element.markerId.value=="AnimatedMarker");
        setOfMarkers.add(animatingMarker);

      });
      oldLatLng=latLngLiveDriverPosition;
      updateDurationTimeAtRealTime();

      //live location update of mechanic who's currently online

      //Updating driver location at realtime in database
       Map driverLatLngDataMap=
       {
        "latitude":onlineDriverCurrentPosition!.latitude.toString(),
        "longitude":onlineDriverCurrentPosition!.longitude.toString(),
       };

       FirebaseDatabase.instance.ref()
       .child("All Ride Requests")
       .child(widget.userRideRequestDetails!.rideRequestId!)
       .child("driverLocation")
       .set(driverLatLngDataMap);

      
      //here we are animating the camera with the changed position of the drivers
    });
  }

  //@override
  //step1)when the mechanic accept the request of user
   //originLatLng=driver Current location
   //destinationLatLng= user current Location

  //step2) Mechanic provide service to the user
  //originLatLng=user current location=>mechanic current location
   //destinationLatLng= user current Location

   Future<void> drawPolyLineFromOriginToDestination(LatLng originLatLng,LatLng destinationLatLng) async {

    showDialog(
        context: context,
        builder: (BuildContext context) => ProgessDialog(
              message: "Please Wait....",
            ));

    var directionDetailsInfo =
        await AssistantMethods.obtainOriginToDestinationDirectionDetails(
            originLatLng, destinationLatLng);

    Navigator.pop(context);

    print("These are points = ");
    print(directionDetailsInfo!.e_points);

    //here we have to convert these encoded points to decoded points
    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolylinePointsResultList =
        pPoints.decodePolyline(directionDetailsInfo!.e_points!);

    polylinePositionCoordinates.clear();

    //polyline in the map accpets only the latlng coordinates therefore we will convert all these points to the decoded list above to the latlng coordinates
    if (decodedPolylinePointsResultList.isNotEmpty) {
      decodedPolylinePointsResultList.forEach((PointLatLng pointLatLng) {
        polylinePositionCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    setOfPolyline.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: Colors.white,
        polylineId: const PolylineId("PolylineID"),
        jointType: JointType.round,
        points: polylinePositionCoordinates,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      setOfPolyline.add(polyline); //
    });

    //we have applied these bounds dcz we want to see the whole polyline on our screen
    LatLngBounds boundsLatLng;
    if (originLatLng.latitude > destinationLatLng.latitude &&
        originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng =
          LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    } else if (originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng = LatLngBounds(
          southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
          northeast:
              LatLng(destinationLatLng.latitude, originLatLng.longitude));
    } else if (originLatLng.latitude > destinationLatLng.latitude) {
      boundsLatLng = LatLngBounds(
          southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
          northeast:
              LatLng(originLatLng.latitude, destinationLatLng.longitude));
    } else {
      boundsLatLng =
          LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    }

    newTripGoogleMapController!
        .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));


    Marker originMarker = Marker(
      markerId: const MarkerId("originID"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId("destinationID"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      setOfMarkers.add(originMarker);
      setOfMarkers.add(destinationMarker);
    });

    Circle originCircle = Circle(
      circleId: const CircleId("originID"),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: originLatLng,
    );

    Circle destinationCircle = Circle(
      circleId: const CircleId("destinationID"),
      fillColor: Colors.red,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: destinationLatLng,
    );

    setState(() {
      setOfCircle.add(originCircle);
      setOfCircle.add(destinationCircle);
    });

  }


  //Gives duration time to reach  mechanic to user 
  updateDurationTimeAtRealTime() async
  {
    if(isRequestDirectionDetails==false)
    {
      isRequestDirectionDetails=true;

      //if mechanic location is not getting then simply retuen
      if(onlineDriverCurrentPosition==null)
      {
        return;
      }
      //mechanic current location
    var originLatLng=LatLng(onlineDriverCurrentPosition!.latitude, onlineDriverCurrentPosition!.longitude);
    var destinationLatLng;
    if(rideRequestStatus=="accepted")
    {
      destinationLatLng=widget.userRideRequestDetails!.originLatLng;//user location 
    }
    // else
    // {
    // var destinationLatLng=widget.userRideRequestDetails!.destinationLatLng;//user dropoff location
    // }

    var directionInformation =await AssistantMethods.obtainOriginToDestinationDirectionDetails(originLatLng, destinationLatLng);
    if(directionInformation!=null)
    {
      setState(() {
      durationFromOriginToDestination= directionInformation.duration_text!;
      });
    }
    isRequestDirectionDetails=false;
    }
  }
  
  @override
  

  Widget build(BuildContext context) {
    createDriverIconMarker();
    return Scaffold(
      body: Stack(
        children: [
          //google map
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapPadding),
            mapType: MapType.normal,
            myLocationEnabled: true,
            initialCameraPosition: _kGooglePlex,
            markers: setOfMarkers,
            circles: setOfCircle,
            polylines: setOfPolyline,
            onMapCreated: (GoogleMapController controller) {

              _controllerGoogleMap.complete(controller);
              newTripGoogleMapController = controller;

              setState(() {
                mapPadding=350;
              });

              //black theme for the google map
              blackThemeGoogleMap(newTripGoogleMapController);

              //mechanic current location
              var driverCurrentLatLng = LatLng(driverCurrentPosition!.latitude,
                  driverCurrentPosition!.longitude);

              //user current location
              var userPickUpLatLng =
                  widget.userRideRequestDetails!
                  .originLatLng;

              drawPolyLineFromOriginToDestination(driverCurrentLatLng, userPickUpLatLng!);

              getDriversLocationUpdatesAtRealTime();
            },
          ),

          //ui
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white30,
                    blurRadius: 18,
                    spreadRadius: .5,
                    offset: Offset(0.6, 0.6),
                  ),
                ],
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                child: Column(
                  children: [
                    //user phone-no
                    Text(
                      widget.userRideRequestDetails!.userPhone!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightGreenAccent,
                      ),
                    ),

                    

                    const SizedBox(
                      height: 18,
                    ),

                    const Divider(
                      thickness: 2,
                      height: 2,
                      color: Colors.grey,
                    ),

                     const SizedBox(
                      height: 8,
                    ),


                    //user name - icon
                    Row(
                      children: [
                        Text(
                          widget.userRideRequestDetails!.userName!,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.lightGreenAccent,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Icon(
                            Icons.phone_android,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    //user origin location with icon
                    Row(
                      children: [
                        Image.asset(
                          "images/origin.png",
                          width: 30,
                          height: 30,
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        Expanded(
                          child: Container(
                            child: Text(
                              widget.userRideRequestDetails!.originAddress!,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    const Divider(
                      thickness: 2,
                      height: 2,
                      color: Colors.grey,
                    ),

                    const SizedBox(
                      height: 10.0,
                    ),


                    ElevatedButton.icon(
                      onPressed: () {
                        if(rideRequestStatus=="accepted")//mechanic has arrived at user location
                        {
                          //when the click up arrived button ,we have to change the status to arrived
                          rideRequestStatus="arrived";

                          //to update this status in database
                          FirebaseDatabase.instance.ref()
                          .child("All Ride Requests")
                          .child(widget.userRideRequestDetails!.rideRequestId!)
                          .child("status")
                          .set(rideRequestStatus);

                          setState(() {
                            buttonTitle="Start Service";
                            buttonColor=Colors.lightGreen;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: buttonColor,
                      ),
                      icon: const Icon(
                        Icons.directions_car,
                        color: Colors.white,
                        size: 25,
                      ),
                      label: Text(
                        
                        buttonTitle!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  

  saveAssignedDriverDetailstoUserRideRequest() {
    DatabaseReference databaseReference = FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .child(widget.userRideRequestDetails!.rideRequestId!);

    Map driverLocationDataMap = {
      "latitude": driverCurrentPosition!.latitude.toString(),
      "longitude": driverCurrentPosition!.longitude.toString(),
    };
    databaseReference.child("driverLocation").set(driverLocationDataMap);

    databaseReference.child("status").set("accepted");
    databaseReference.child("driverId").set(onlineDriverData.id);
    databaseReference.child("driverName").set(onlineDriverData.name);
    databaseReference.child("driverPhone").set(onlineDriverData.phone);

    saveRideRequestIdToDriverHistory();
  }

   //history for mechanic to keep track of how many services he/she has completed
  saveRideRequestIdToDriverHistory() {
    DatabaseReference tripsHistoryRef = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentFirebaseUser!.uid)
        .child("tripsHistory");

    tripsHistoryRef
        .child(widget.userRideRequestDetails!.rideRequestId!)
        .set(true);
  }
}