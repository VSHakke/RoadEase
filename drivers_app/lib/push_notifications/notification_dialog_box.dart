import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:drivers_app/assistants/assistant_methods.dart';
import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/main_Screens/new_trip_screen.dart';
import 'package:drivers_app/models/user_ride_request_information.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


class NotificationDialogBox extends StatefulWidget
{
  UserRideRequestInformation? userRideRequestDetails;

  NotificationDialogBox({this.userRideRequestDetails});

  @override
  State<NotificationDialogBox> createState() => _NotificationDialogBoxState();
}




class _NotificationDialogBoxState extends State<NotificationDialogBox>
{
  @override
  Widget build(BuildContext context) 
  {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: Colors.transparent,
      elevation: 2,
      child: Container(
        margin: const EdgeInsets.all(8),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[800],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            const SizedBox(height: 14,),

            Image.asset(
              "images/car_logo.png",
              width: 160,
            ),

            const SizedBox(height: 10,),

            //title
            const Text(
              "New Request",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.grey
              ),
            ),

            const SizedBox(height: 14.0),

            const Divider(
              height: 3,
              thickness: 3,
            ),

            //addresses origin destination
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  //origin location with icon
                  Row(
                    children: [
                      Image.asset(
                        "images/origin.png",
                        width: 30,
                        height: 30,
                      ),
                      const SizedBox(width: 14,),
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

                  const SizedBox(height: 20.0),

                  //destination location with icon
                  /*Row(
                    children: [
                      Image.asset(
                        "images/destination.png",
                        width: 30,
                        height: 30,
                      ),
                      const SizedBox(width: 14,),
                      Expanded(
                        child: Container(
                          child: Text(
                            widget.userRideRequestDetails!.destinationAddress!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),*/
                ],
              ),
            ),


            const Divider(
              height: 3,
              thickness: 3,
            ),

            //buttons cancel accept
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                    ),
                    onPressed: ()
                    {
                      audioPlayer.pause();
                      audioPlayer.stop();
                      audioPlayer = AssetsAudioPlayer();

                      //cancel the rideRequest

                      Navigator.pop(context);
                    },
                    child: Text(
                      "Cancel".toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ),

                  const SizedBox(width: 25.0),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                    ),
                    onPressed: ()
                    {
                      audioPlayer.pause();
                      audioPlayer.stop();
                      audioPlayer = AssetsAudioPlayer();//update the value of audioPlayer instance

                      //accept the rideRequest

                      //Navigator.pop(context);
                      acceptRideRequest(context);
                    },
                    child: Text(
                      "Accept".toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  acceptRideRequest(BuildContext context)
  {
    //retrieve newRideStatus that is if rideRequestId is exist,then we will change this status to accepted.
    String getRideRequestId="";
    FirebaseDatabase.instance
    .ref().child("drivers")
    .child(currentFirebaseUser!.uid)
    .child("newRideStatus")
    .once()
    .then((snap){
      if(snap.snapshot.value!=null)
      {
        getRideRequestId=snap.snapshot.value.toString();
        // print("This is getRideRequestId :" );
        // print(getRideRequestId);

      }
      else
      {
        Fluttertoast.showToast(msg: "This request does not exist.");
      }

       /* print("This is userRideRequestDetails!.rideRequestId :" );
        print(widget.userRideRequestDetails!.rideRequestId.toString());
        Fluttertoast.showToast(msg: "getRideRequestId = "+ widget.userRideRequestDetails!.rideRequestId.toString());*/


      //verify getRideRequestId with userRideRequestDetails
      if(getRideRequestId==widget.userRideRequestDetails!.rideRequestId)
      {
        //update new ride Status to accepted
        FirebaseDatabase.instance
        .ref().child("drivers")
        .child(currentFirebaseUser!.uid)
        .child("newRideStatus")
        .set("accepted");

        //pause the live location updates
        AssistantMethods.pauseLiveLocationUpdates();

        //send the mechanic to newRideScreen that newRideScreen will show the polyline from mechanic current position towoards the user current location 
        ///trip of mechanic started to reach towords user and provide services
        Navigator.push(context, MaterialPageRoute(builder: (c)=>NewTripScreen(
          userRideRequestDetails:widget.userRideRequestDetails,
        )
        ));
        
      }
      else
      {
        Fluttertoast.showToast(msg: "This request does not exist");
      }
    });
  }
}
