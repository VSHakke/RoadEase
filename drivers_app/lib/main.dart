import 'package:drivers_app/firebase_options.dart';
import 'package:drivers_app/splashScreen/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase.initializeApp();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyBkCI_IMYyTCLTxv6u49YVVLFckNRCTHFg',
      // authDomain: 'YOUR_AUTH_DOMAIN',
      databaseURL: 'https://roadease-app-784b3-default-rtdb.firebaseio.com',
      projectId: 'roadease-app-784b3',
      storageBucket: 'roadease-app-784b3.appspot.com',
      messagingSenderId: '352827242635',
      appId: '1:352827242635:android:079ef6c94c9bc40e12bc8e',
    ),
    // options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MyApp(
      child: MaterialApp(
        title: 'Drivers App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MySplashScreen(),
        debugShowCheckedModeBanner: false, //it removes debug batch
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  //const MyApp({super.key});
  final Widget? child;

  MyApp({this.child});

  static void restartApp(BuildContext context) {
    //Whenever we want to restart the app,we simply call this method
    context.findAncestorStateOfType<_MyAppState>()!.restartApp();
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child!,
    );
  }
}
