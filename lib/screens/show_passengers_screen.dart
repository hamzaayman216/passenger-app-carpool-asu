import 'dart:async';

import 'package:carpool/constants.dart';
import 'package:carpool/models/user.dart';
import 'package:flutter/material.dart';
import 'package:carpool/models/paid_status.dart';
import 'package:firebase_database/firebase_database.dart';


class ShowPassengersScreen extends StatefulWidget {
  final List<CarPoolUser> passengers;
  final String rideId;

  ShowPassengersScreen({required this.passengers, required this.rideId});

  @override
  State<ShowPassengersScreen> createState() => _ShowPassengersScreenState();
}

class _ShowPassengersScreenState extends State<ShowPassengersScreen> {
  Future<bool> getPaidStatus(String email, String rideId) async {
    try {
      // Fetch userId based on email from users collection (assuming it exists)
      DatabaseReference usersRef = FirebaseDatabase.instance.ref('users');
      Query userQuery = usersRef.orderByChild('email').equalTo(email);

      String userId = '';
      DataSnapshot userSnapshot = await userQuery.get();
      if (userSnapshot.exists) {
        Map<dynamic, dynamic> userData = userSnapshot.value as Map<dynamic, dynamic>;
        userId = userData.keys.first; // Assuming email is unique and we get one result
      }

      // Now, get the PaidStatus using userId
      DatabaseReference paidStatusRef = FirebaseDatabase.instance.ref('paidStatus');
      Query paidStatusQuery = paidStatusRef.orderByChild('userId').equalTo(userId);

      Completer<bool> completer = Completer<bool>();

      paidStatusQuery.onValue.listen((event) {
        if (event.snapshot.value == null) {
          completer.complete(false);
        } else {
          Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
          var filteredData = data.values.where((entry) => entry['rideId'] == rideId).toList();
          if (filteredData.isNotEmpty && filteredData.first['paid'] == true) {
            completer.complete(true);
          } else {
            completer.complete(false);
          }
        }
      });

      return completer.future;
    } catch (e) {
      print('Error getting paid status: $e');
      return false;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            topLeft: Radius.circular(20),
          ),
        ),
        padding: EdgeInsets.all(20),
        child: widget.passengers.isNotEmpty
            ? ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height*1.5 *
                widget.passengers.length /
                10,
          ),
          child: ListView.builder(
            itemCount: widget.passengers.length,
            itemBuilder: (context, index) {
              final passenger = widget.passengers[index];
              return FutureBuilder<bool>(
                future: getPaidStatus(passenger.email, widget.rideId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(); // Show loading indicator while waiting for data
                  }

                  bool isPaid = snapshot.data ?? false; // Default to false if no data is found
                  return Card(
                    color: Colors.white, // Set card background color
                    elevation: 4, // Add elevation to the card
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundImage: widget.passengers[index].imageUrl==''?AssetImage('images/avatar.jpg') as ImageProvider:NetworkImage(widget.passengers[index].imageUrl),
                          backgroundColor: Colors.white,
                        ),
                        ListTile(
                          title: Text(
                            passenger.name,
                            style: TextStyle(
                                color: kSecondaryColor), // Set text color
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Phone: ${passenger.phoneNumber}',
                                style: TextStyle(
                                    color: kSecondaryColor), // Set text color
                              ),
                              Text(
                                'Email: ${passenger.email}',
                                style: TextStyle(
                                    color: kSecondaryColor), // Set text color
                              ),
                            ],
                          ),
                          trailing: isPaid
                              ? Icon(Icons.check_circle, color: Colors.green)
                              : Icon(Icons.cancel, color: Colors.red), // Display paid status
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        )
            : Center(
          child: Text(
            'No passengers yet',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}