import 'package:carpool/screens/cart_screen.dart';
import 'package:carpool/screens/driver_chat_screen.dart';
import 'package:carpool/screens/driver_login_screen.dart';
import 'package:carpool/screens/driver_registration_screen.dart';
import 'package:carpool/screens/driver_screen.dart';
import 'package:carpool/screens/passenger_login_screen.dart';
import 'package:carpool/screens/passenger_screen.dart';
import 'package:carpool/screens/profile_edit_screen.dart';
import 'package:carpool/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'screens/passenger_registration_screen.dart';
import 'screens/passenger_screen.dart';
import 'screens/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
void main() async {
 WidgetsFlutterBinding.ensureInitialized(); // Ensure that Flutter is initialized
  await Firebase.initializeApp(); // Initialize Firebase

  runApp(CarPool());
}


class CarPool extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        textTheme: TextTheme(
          bodyText2: TextStyle(color: Colors.black54),
        ),
      ),
      initialRoute: PassengerLoginScreen.id,
      routes:{
        PassengerLoginScreen.id:(context)=>PassengerLoginScreen(),
        PassengerRegistrationScreen.id:(context)=> PassengerRegistrationScreen(),
        PassengerScreen.id:(context)=>PassengerScreen(),
        CartScreen.id:(context)=>CartScreen(),
      } ,
    );
  }
}