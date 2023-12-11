import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:carpool/constants.dart';
import 'package:carpool/models/ride.dart';
import 'package:carpool/components/cart_list.dart'; // Import CartList
import 'package:firebase_auth/firebase_auth.dart';

class CartScreen extends StatefulWidget {
  static const String id = 'cart_screen';

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {

  final FirebaseAuth _auth = FirebaseAuth.instance; // Assuming FirebaseAuth is used for user authentication
  late Stream<List<Ride>> filteredRidesStream;

  @override
  void initState() {
    super.initState();
    filteredRidesStream = _fetchFilteredRides();
  }

  Stream<List<Ride>> _fetchFilteredRides() {
    return FirebaseDatabase.instance
        .ref('rides')
        .onValue
        .map((event) {
      List<Ride> rides = [];
      User? currentUser = _auth.currentUser;
      if (event.snapshot.value != null && currentUser != null) {
        Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          Ride ride = Ride.fromMap(Map<String, dynamic>.from(value));
          if (ride.passengerIds!.contains(currentUser.uid) && ride.status!='Finished') {
            rides.add(ride);
          }
        });
      }
      return rides;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainColor,
      appBar: AppBar(
        title: Text('My Cart', style: TextStyle(color: kSecondaryColor)),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: kSecondaryColor),
      ),
      body: SafeArea(
        child: CartList(cartListStream: filteredRidesStream), // Use CartList with the filtered rides stream
      ),
    );
  }
}
