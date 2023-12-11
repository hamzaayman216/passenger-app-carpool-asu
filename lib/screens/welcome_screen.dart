import 'package:carpool/screens/driver_login_screen.dart';
import 'package:carpool/screens/passenger_login_screen.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:carpool/components/rounded_icon_button.dart';
import 'package:carpool/constants.dart';



class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome_screen';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation animation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    animation = ColorTween(begin: Colors.blueGrey, end: Colors.white)
        .animate(controller);
    controller.forward();
    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Column(
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: Container(
                    child: Image.asset('images/carpool.png'),
                    height: 130,
                  ),
                ),
                TypewriterAnimatedTextKit(
                  text: ['CarPool Now'],
                  textStyle: TextStyle(
                    fontSize: 45.0,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            RoundedIconButton(
              'Driver',
              Colors.white,
                  () {
               Navigator.pushNamed(context, DriverLoginScreen.id);
              },
              Icon(Icons.directions_car_rounded,size: 50.0,color: kSecondaryColor,),
            ),
            RoundedIconButton(
              'Passenger',
              Colors.white,
                  () {
               Navigator.pushNamed(context, PassengerLoginScreen.id);
              },
              Icon(Icons.person,size: 50,color: kSecondaryColor,),
            ),
          ],
        ),
      ),
    );
  }
}
