import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:users_app/assistants/assistant_methods.dart';
import 'package:users_app/authentication/login_screen.dart';
import 'dart:async';

import 'package:users_app/global/global.dart';
import 'package:users_app/mainScreens/main_screen.dart';
// Import the dart:async library

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({super.key});

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  startTimer() {
    fAuth.currentUser != null
        ? AssistantMethods.readCurrentOnlineUserInfo()
        : null;

    Timer(const Duration(seconds: 3), () async {
      // if (await fAuth.currentUser !=
      //     null) //this means that the user is already authenticated or register so now the user can login directly and dont require to signup again
      // {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        currentFirebaseUser = user;
        // Navigator.push(
        //     context, MaterialPageRoute(builder: (c) => MainScreen()));
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => MainScreen()));
      } else {
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => LoginScreen()));
      }
    });
  }

  //initState() is called whenever we go to any page
  @override
  void initState() {
    super.initState();

    startTimer(); //whenever the user comes to this page this initstate() method will be called automatically
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("images/userLogo.jpg"),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "RoadEase App",
                style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
      ),
    );
  }
}
