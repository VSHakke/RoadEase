import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:users_app/models/user_model.dart';

final FirebaseAuth fAuth = FirebaseAuth.instance;
//if we write as _firebaseAuth then this '_' (underscore) make this firebaseAuth private

User? currentFirebaseUser;

UserModel? userModelCurrentInfo;

List dList = []; //online-active drivers Information List

String? chosenDriverId = "";  //the driver which the user have chosen



