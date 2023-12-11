import 'package:carpool/screens/passenger_screen.dart';
import 'package:flutter/material.dart';
import 'package:carpool/components/rounded_button.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:carpool/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:carpool/controller/validations.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/database_manager.dart';

class PassengerRegistrationScreen extends StatefulWidget {
  static const String id = 'passenger_registration_screen';
  @override
  _PassengerRegistrationScreenState createState() =>
      _PassengerRegistrationScreenState();
}

class _PassengerRegistrationScreenState
    extends State<PassengerRegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  final _databaseManager = DatabaseManager();
  String email = '';
  String password = '';
  String name = '';
  String confirmPassword = '';
  String phoneNumber = '';
  int balance=1000;
  bool showSpinner = false;

  @override
  void initState() {
    super.initState();
    _databaseManager.open();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/carpool.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 18.0,
              ),
              TextField(
                style: TextStyle(
                  color: kSecondaryColor,
                ),
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  email = value;
                },
                decoration:
                    kTextFieldDecoration.copyWith(hintText: 'Enter your email'),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                style: TextStyle(
                  color: kSecondaryColor,
                ),
                textAlign: TextAlign.center,
                onChanged: (value) {
                  name = value;
                },
                decoration:
                    kTextFieldDecoration.copyWith(hintText: 'Enter your name'),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                style: TextStyle(
                  color: kSecondaryColor,
                ),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  phoneNumber = value;
                },
                decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Enter your phone number'),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                style: TextStyle(
                  color: kSecondaryColor,
                ),
                obscureText: true,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  password = value;
                },
                decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Enter your password'),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                style: TextStyle(
                  color: kSecondaryColor,
                ),
                obscureText: true,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  confirmPassword = value;
                },
                decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Confirm your password'),
              ),
              SizedBox(
                height: 18.0,
              ),
              RoundedButton('Register', Colors.lightBlueAccent, () async {
                String errorMessage = validateRegistrationInput(
                    name, email, phoneNumber, password, confirmPassword);

                if (errorMessage != '') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Center(
                          child: Text(errorMessage,
                              style: TextStyle(color: Colors.red))),
                      duration: Duration(seconds: 5),
                    ),
                  );
                  return;
                }

                setState(() {
                  showSpinner = true;
                });
                try {
                  final UserCredential newUser =
                      await _auth.createUserWithEmailAndPassword(
                          email: email, password: password);
                  if (newUser.user != null) {
                    // Reference to the Realtime Database
                    DatabaseReference usersRef =
                        FirebaseDatabase.instance.ref("users");

                    // Set the user data in Realtime Database
                    await usersRef.child(newUser.user!.uid).set({
                      "name": name,
                      "phoneNumber": phoneNumber,
                      "email": email,
                      "balance":balance,
                    });

                    // Insert the same user data into SQLite database
                    await _databaseManager.insertUserProfile(
                      name: name,
                      email: email,
                      phoneNumber: phoneNumber,
                      profilePhotoUrl:
                          '', // Assuming an empty string if no URL is available
                    );

                    Navigator.pushNamed(context, PassengerScreen.id);
                  }
                } catch (e) {
                  setState(() {
                    showSpinner = false;
                  });

                  // Handling Firebase Auth exceptions
                  if (e is FirebaseAuthException &&
                      e.code == 'email-already-in-use') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Center(
                            child: Text('This email is already registered',
                                style: TextStyle(color: Colors.red))),
                        duration: Duration(seconds: 5),
                      ),
                    );
                  } else {
                    print(e);
                    // Handle other exceptions, including SQLite exceptions if needed
                  }
                }
              }),
            ],
          ),
        ),
      ),
    );
  }
}
