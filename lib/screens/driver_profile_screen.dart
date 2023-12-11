import 'package:carpool/constants.dart';
import 'package:carpool/models/user.dart';
import 'package:carpool/screens/driver_history_screen.dart';
import 'package:carpool/screens/profile_edit_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carpool/screens/driver_history_screen.dart';
import 'driver_profile_edit_screen.dart';

class DriverProfileScreen extends StatelessWidget {
  static const String id = 'driver_profile_screen';
  final CarPoolUser user;

  DriverProfileScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(user.name), // Replace with dynamic data
              accountEmail: Text(user.email), // Replace with dynamic data
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: user.imageUrl == ''
                    ? AssetImage('images/avatar.jpg') as ImageProvider
                    : NetworkImage(user.imageUrl) as ImageProvider,
              ),
              decoration: BoxDecoration(
                color: Colors
                    .lightBlueAccent, // Set light blue accent background for the header
              ),
              otherAccountsPictures: <Widget>[
                Text(
                  '\$${user.balance.toString()}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            ListTile(
              leading: Icon(
                Icons.person,
                color: kSecondaryColor,
              ),
              title: Text(
                'Profile',
                style: TextStyle(color: kSecondaryColor),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          DriverProfileEditScreen(user: user)),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.history,
                color: kSecondaryColor,
              ),
              title: Text(
                'History',
                style: TextStyle(color: kSecondaryColor),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          DriverHistoryScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.logout,
                color: kSecondaryColor,
              ),
              title: Text(
                'Logout',
                style: TextStyle(color: kSecondaryColor),
              ),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
    );
  }
}
