import 'package:carpool/constants.dart';
import 'package:carpool/controller/services/user_service.dart';
import 'package:carpool/models/user.dart';
import 'package:carpool/screens/chat_history_screen.dart';
import 'package:carpool/screens/show_passengers_screen.dart';
import 'package:flutter/material.dart';
import 'package:carpool/models/ride.dart';
import 'package:firebase_auth/firebase_auth.dart';

late User loggedInUser;

class HistoryTile extends StatefulWidget {
  final Ride ride;

  HistoryTile({required this.ride});

  @override
  State<HistoryTile> createState() => _HistoryTileState();
}

class _HistoryTileState extends State<HistoryTile> {
  UserService userService = UserService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  IconData deleteButtonIcon = Icons.delete;
  IconData checkButtonIcon = Icons.check;
  String driverImageUrl = ''; // Placeholder URL
  String driverName = '';
  String driverPhoneNumber = '';

  @override
  void initState() {
    super.initState();
    loggedInUser = _auth.currentUser!;
    getDriverDetails(widget.ride.driverId);

  }

  Future<void> getDriverDetails(String driverId) async {
    Map<String, dynamic>? userData =await
    userService.getDriverDetails(driverId);
    setState(() {
      driverImageUrl = userData!['imageUrl'] ??
          '';
      driverName = userData!['name'] ?? 'Unknown';
      driverPhoneNumber = userData!['phoneNumber'] ?? 'N/A';
    });

  }

  void fetchPassengersAndShowScreen() async {
    List<CarPoolUser> passengers = await userService.fetchPassengers(widget.ride);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: ShowPassengersScreen(
              passengers: passengers, rideId: widget.ride.id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          backgroundImage: NetworkImage(driverImageUrl),
        ),
        title: Text(driverName, style: TextStyle(color: kSecondaryColor)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(driverPhoneNumber, style: TextStyle(color: kSecondaryColor)),
            Text('From: ${widget.ride.startPoint}',
                style: TextStyle(color: kSecondaryColor)),
            Text('To: ${widget.ride.endPoint}',
                style: TextStyle(color: kSecondaryColor)),
            Text(widget.ride.date, style: TextStyle(color: kSecondaryColor)),
            Text(widget.ride.time, style: TextStyle(color: kSecondaryColor)),
            Text(
                '${widget.ride.passengerIds?.length ?? 0}/${widget.ride.numberOfPassengers} booked',
                style: TextStyle(color: kSecondaryColor)),
            Text(
                widget.ride.preferences.isEmpty?'Preferences: N/A':'Preferences: ${widget.ride.preferences.join(", ")}',
                style: TextStyle(color: kSecondaryColor)),
            Text(
              widget.ride.confirmed?'Confirmed: Yes':'Confirmed: No',
              style: TextStyle(
                color: kSecondaryColor,
              ),
            ),
            Text(
              'Status: ${widget.ride.status}',
              style: TextStyle(
                color: kSecondaryColor,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.groups_rounded,
                  color: kSecondaryColor, size: 35),
              onPressed: fetchPassengersAndShowScreen,
            ),
            SizedBox(width: 18),
            IconButton(
              icon: Icon(Icons.chat, color: kSecondaryColor, size: 30),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ChatHistoryScreen(rideId: widget.ride.id,loggedInUser: loggedInUser,),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
