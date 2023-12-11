import 'package:carpool/screens/passenger_registration_screen.dart';
import 'package:carpool/screens/passenger_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carpool/components/rounded_button.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:carpool/constants.dart';
import 'package:carpool/controller/validations.dart';

class PassengerLoginScreen extends StatefulWidget {
  static const String id = 'passenger_login_screen';
  @override
  _PassengerLoginScreenState createState() => _PassengerLoginScreenState();
}

class _PassengerLoginScreenState extends State<PassengerLoginScreen> {
  final _auth = FirebaseAuth.instance;
  String email='';
  String password='';
  bool showSpinner = false;
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
                height: 48.0,
              ),
              TextField(
                style: TextStyle(
                  color: Colors.black,
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
                  color: Colors.black,
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
                height: 24.0,
              ),
              RoundedButton('Log in', Colors.lightBlueAccent, () async {
                String errorMessage = validateLoginInput(email, password);
                if (errorMessage != '') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Center(
                          child: Text(errorMessage,
                              style: TextStyle(color: Colors.red))),
                      duration: Duration(seconds: 3),
                    ),
                  );
                  return;
                }
                setState(() {
                  showSpinner = true;
                });
                try {
                  final user = await _auth.signInWithEmailAndPassword(
                      email: email, password: password);
                  if (user != null) {
                    Navigator.pushNamed(context, PassengerScreen.id);
                  }
                  setState(() {
                    showSpinner = false;
                  });
                }  catch (e) {

                  setState(() {
                    showSpinner = false;
                  });
                  if (e is FirebaseAuthException && e.code == 'INVALID_LOGIN_CREDENTIALS') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Center(child: Text('Invalid login credentials', style: TextStyle(color: Colors.red))),
                        duration: Duration(seconds: 3),
                      ),
                    );
                    setState(() {
                      email = '';
                      password = '';
                    });
                  } else {
                    print(e);
                    // Or handle other exceptions
                  }
                }
              }),
              TextButton(
                onPressed: (){
                  Navigator.pushNamed(context, PassengerRegistrationScreen.id);
                },
                child: Text(
                  'Register',
                  style: TextStyle(
                    color: kMainColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
