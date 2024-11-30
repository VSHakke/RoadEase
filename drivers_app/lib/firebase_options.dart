import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // SIMPLIFIED CODE

    return webProduction;
  }

  static const FirebaseOptions webProduction = FirebaseOptions(
    apiKey: 'AIzaSyBkCI_IMYyTCLTxv6u49YVVLFckNRCTHFg',
    appId: '1:352827242635:android:079ef6c94c9bc40e12bc8e',
    messagingSenderId: '352827242635',
    projectId: 'roadease-app-784b3',
    // authDomain: 'xxx.firebaseapp.com',
    storageBucket: 'roadease-app-784b3.appspot.com',
    // measurementId: 'xxx',
  );
}
