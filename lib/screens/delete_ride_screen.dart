import 'package:carpool/constants.dart';
import 'package:flutter/material.dart';
import 'package:carpool/models/ride.dart';
import 'package:firebase_auth/firebase_auth.dart' as fbAuth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

late fbAuth.User loggedInUser;

class DeleteRideScreen extends StatefulWidget {
  final Ride ride;

  DeleteRideScreen({required this.ride});
  @override
  State<DeleteRideScreen> createState() => _DeleteRideScreenState();
}

class _DeleteRideScreenState extends State<DeleteRideScreen> {
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20),
              topLeft: Radius.circular(20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Delete Ride',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  color: kSecondaryColor,
                ),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    // Reference to the 'rides' node
                    DatabaseReference ridesRef = FirebaseDatabase.instance.ref('rides');

                    // Query the 'rides' node for the specific ride
                    Query query = ridesRef.orderByChild('id').equalTo(widget.ride.id);
                    DataSnapshot snapshot = await query.get();

                    if (snapshot.exists) {
                      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
                      String keyToDelete = data.keys.firstWhere(
                            (k) => data[k]['id'] == widget.ride.id,
                        orElse: () => null,
                      );

                      if (keyToDelete != null) {
                        // Delete the specific ride
                        await ridesRef.child(keyToDelete).remove();
                      }
                    }

                    Navigator.pop(context);
                  } catch (e) {
                    print('Error deleting ride: $e');
                  }
                },
                child: Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
            ],
          ),
        ));
  }
}
