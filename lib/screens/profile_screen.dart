import 'package:carpool/constants.dart';
import 'package:carpool/models/user.dart';
import 'package:carpool/screens/cart_screen.dart';
import 'package:carpool/screens/history_screen.dart';
import 'package:carpool/screens/profile_edit_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  static const String id = 'profile_screen';
  final CarPoolUser user;

  ProfileScreen({required this.user});

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
                color: kMainColor,
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
              ],),
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
                      builder: (context) => ProfileEditScreen(user: user)),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.shopping_cart,
                color: kSecondaryColor,
              ),
              title: Text(
                'Cart',
                style: TextStyle(color: kSecondaryColor),
              ),
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CartScreen()),
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
                          HistoryScreen()),
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