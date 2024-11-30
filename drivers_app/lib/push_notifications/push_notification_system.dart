

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/models/user_ride_request_information.dart';
import 'package:drivers_app/push_notifications/notification_dialog_box.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PushNotificationSystem
{
  FirebaseMessaging messaging=FirebaseMessaging.instance;

  Future initializeCloudMessaging(BuildContext context) async
  {
    //1.Terminated
    //When the app is completely closed and opened directly from the push notification
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? remoteMessage)
    {
      //remoteMessage brings the service request from which we can get user info and his location
      if(remoteMessage!=null)
      {
        // print("This is remote message : ");
        // print(remoteMessage?.data["rideRequestId"]);
        //display the request of user and user information who request for service(repair the car)
        readUserRideRequestInformation(remoteMessage!.data["rideRequestId"],context);
      }
    });

    //2.Forground
    //When the app is opend & it receives a push notification
    //onMessage means the app is open and we can see notications it will perform that functionality
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) 
    {
      // print("This is remote message : ");
      // print(remoteMessage?.data["rideRequestId"]);
      //display the request and user information
      readUserRideRequestInformation(remoteMessage?.data["rideRequestId"],context);

    });

    //3.Background
    //When the app is in the background and opened directly from the push notifications.
    //onMessageOpenedApp performs the functionality which is When the app is in the background and opened directly from the push notifications.

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) 
    {
      
      // print("This is remote message : ");
      // print(remoteMessage?.data["rideRequestId"]);
      //display the request and user information
      readUserRideRequestInformation(remoteMessage?.data["rideRequestId"],context);
      
    });

  }
  
  readUserRideRequestInformation(String userRideRequestId,BuildContext context)
  {
    FirebaseDatabase.instance.ref()
    .child("All Ride Request")
    .child(userRideRequestId)
    .once()
    .then((snapData)
    {
      if(snapData.snapshot.value != null)
      {
        audioPlayer.open(Audio("music/music_notification.mp3"));
        audioPlayer.play();

        double originLat= double.parse((snapData.snapshot.value! as Map)["origin"]["latitude"]);
        double originLng= double.parse((snapData.snapshot.value! as Map)["origin"]["longitude"]);
        String originAddress=(snapData.snapshot.value! as Map)["originAddress"];

        double destinationLat= double.parse((snapData.snapshot.value! as Map)["destination"]["latitude"]);
        double destinationLng= double.parse((snapData.snapshot.value! as Map)["destination"]["longitude"]);
        String destinationAddress=(snapData.snapshot.value! as Map)["destinationAddress"];

        String userName=(snapData.snapshot.value! as Map)["userName"];
        String  userPhone=(snapData.snapshot.value! as Map)["userPhone"];

        String? rideRequestId=snapData.snapshot.key;


        UserRideRequestInformation userRideRequestDetails = UserRideRequestInformation();

        userRideRequestDetails.originLatLng = LatLng(originLat, originLng);
        userRideRequestDetails.originAddress = originAddress;

        userRideRequestDetails.destinationLatLng = LatLng(destinationLat, destinationLng);
        userRideRequestDetails.destinationAddress = destinationAddress;

        userRideRequestDetails.userName = userName;
        userRideRequestDetails.userPhone = userPhone;

        userRideRequestDetails.rideRequestId=rideRequestId;

        //to confirm whether we are getting information correct or not
        /*print("This is user Ride Request Information : ");
        print(userRideRequestInformation.userName);
        print(userRideRequestInformation.userPhone);
        print(userRideRequestInformation.originAddress);
        print(userRideRequestInformation.destinationAddress);*/

        showDialog(
          context: context,
           builder: (BuildContext context) => NotificationDialogBox(
                userRideRequestDetails: userRideRequestDetails,
             
           ),
        );
        
      }
      else
      {
        Fluttertoast.showToast(msg: "This Ride Request Id does not exist. ");
      }
    });
  }

  //When the user sent a request to mechanic to come for repairing a car.Then we will communicate and recognize that specific mechanic
  //This can be done with the help of Token that is registered  token each mechanic has it's own token which will stored in realtime database
  //with the help of these token we can communicate(user - mechanic)

  //Method which is responsible for generating tokens
  Future  generateAndGetToken() async
  {
    String? registerationToken=await messaging.getToken();//generate and get the token and assign to the registrationToken varible.
    //once we get the token then have to stored in the database for that each mechanic who is currently online.
    //When any mechanic restored the app or reinstalled the app or uninstalled the app or clear up the phone data,then mechanic again open up the app and log in then it will generate new token(updated token).

    // print("FCM registration token : ");
    // print(registerationToken);
    
    FirebaseDatabase.instance.ref()
    .child("drivers")
    .child(currentFirebaseUser!.uid)
    .child("token").set(registerationToken);


    //for send and receive notications
    messaging.subscribeToTopic("allDrivers");
    messaging.subscribeToTopic("allUsers");


  }
}