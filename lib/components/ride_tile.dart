import 'package:carpool/constants.dart';
import 'package:flutter/material.dart';
import 'package:carpool/models/ride.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

late User loggedInUser;

class RideTile extends StatefulWidget {
  final Ride ride;

  RideTile({required this.ride});

  @override
  State<RideTile> createState() => _RideTileState();
}

class _RideTileState extends State<RideTile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late bool isAdded = false;
  IconData buttonIcon = Icons.add; // Default icon
  bool userHasPaid = false;
  String driverImageUrl = 'default_image_url'; // Placeholder URL
  String driverName = '';
  String driverPhoneNumber = '';

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    setupPaymentStatusListener();
    getDriverDetails(widget.ride.driverId);
  }

  Future<void> getDriverDetails(String driverId) async {
    DatabaseReference usersRef =
        FirebaseDatabase.instance.ref('users').child(driverId);
    DatabaseEvent event = await usersRef.once();

    if (event.snapshot.exists) {
      Map<String, dynamic> userData =
          Map<String, dynamic>.from(event.snapshot.value as Map);
      setState(() {
        driverImageUrl = userData['imageUrl'] ??
            ''; // Update with actual default URL if needed
        driverName = userData['name'] ?? 'Unknown';
        driverPhoneNumber = userData['phoneNumber'] ?? 'N/A';
      });
    }
  }

  void getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        checkUser();
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> checkUser() async {
    bool userFound =
        widget.ride.passengerIds?.contains(loggedInUser.uid) ?? false;

    setState(() {
      isAdded = userFound;
      buttonIcon = isAdded ? Icons.close : Icons.add; // Update the button icon
    });
  }

  void setupPaymentStatusListener() {
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }

    String userId = user.uid;
    String rideId = widget.ride.id;

    DatabaseReference paidStatusRef =
        FirebaseDatabase.instance.ref('paidStatus');
    Query query = paidStatusRef.orderByChild('userId').equalTo(userId);

    query.onValue.listen((event) {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> paymentData =
            event.snapshot.value as Map<dynamic, dynamic>;
        var userPaymentData = paymentData.values.firstWhere(
          (data) => data['rideId'] == rideId,
          orElse: () => null,
        );

        if (userPaymentData != null) {
          setState(() {
            userHasPaid = userPaymentData['paid'] == true;
          });
        }
      } else {
        setState(() {
          userHasPaid = false;
        });
      }
    });
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
          backgroundImage: driverImageUrl==''?AssetImage('images/avatar.jpg') as ImageProvider:NetworkImage(
              driverImageUrl) as ImageProvider, // Assuming driver image URL is provided in ride model
        ),
        title: Text(driverName, style: TextStyle(color: kSecondaryColor)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add other ride details you want to display
            Text(
              'From: ${widget.ride.startPoint}',
              style: TextStyle(
                color: kSecondaryColor,
              ),
            ),
            Text(
              'To: ${widget.ride.endPoint}',
              style: TextStyle(
                color: kSecondaryColor,
              ),
            ),
            Text(
              widget.ride.date,
              style: TextStyle(
                color: kSecondaryColor,
              ),
            ),
            Text(
              widget.ride.time,
              style: TextStyle(
                color: kSecondaryColor,
              ),
            ),
            Text(
              '${widget.ride.passengerIds?.length ?? 0}/${widget.ride.numberOfPassengers} booked',
              style: TextStyle(
                color: kSecondaryColor,
              ),
            ),
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
              icon: Icon(
                buttonIcon,
                color: Colors.green,
                size: 30,
              ),
              onPressed: () {
                DateTime now = DateTime.now();
                DateTime date = DateTime.parse(widget.ride.date);
                if (widget.ride.time == '7:30 AM') {
                  int newHour = 7;
                  int newMinute = 30;
                  DateTime modifiedDate = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    newHour,
                    newMinute,
                    date.second,
                    date.millisecond,
                    date.microsecond,
                  );
                  if ((modifiedDate.difference(now!)).inMinutes < 570) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Center(
                            child: Text(
                                '7:30 AM rides should be booked before 10 PM',
                                style: TextStyle(color: Colors.red))),
                        duration: Duration(seconds: 3),
                      ),
                    );
                    return;
                  }
                } else if (widget.ride.time == '5:30 PM') {
                  int newHour = 17;
                  int newMinute = 30;
                  DateTime modifiedDate = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    newHour,
                    newMinute,
                    date.second,
                    date.millisecond,
                    date.microsecond,
                  );
                  if ((modifiedDate.difference(now!)).inMinutes < 270) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Center(
                            child: Text(
                                '5:30 PM rides should be booked before 1 PM',
                                style: TextStyle(color: Colors.red))),
                        duration: Duration(seconds: 3),
                      ),
                    );
                    return;
                  }
                }
                if(widget.ride.status=="Started"){
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Center(
                          child: Text(
                              'The ride already started',
                              style: TextStyle(color: Colors.red))),
                      duration: Duration(seconds: 3),
                    ),
                  );
                  return;
                }else if(widget.ride.status=="Finished"){
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Center(
                          child: Text(
                              'The ride is finished',
                              style: TextStyle(color: Colors.red))),
                      duration: Duration(seconds: 3),
                    ),
                  );
                  return;
                }
                handleAddOrRemovePassenger();
              },
            ),
          ],
        ),
      ),
    );
  }

  void handleAddOrRemovePassenger() {
    setState(() {
      List<String> passengerIds = List.from(widget.ride.passengerIds ?? []);

      if (passengerIds.contains(loggedInUser.uid)) {
        passengerIds.remove(loggedInUser.uid);
      } else {
        if (passengerIds.length >= widget.ride.numberOfPassengers) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(
                  child: Text(
                      'The ride is full',
                      style: TextStyle(color: Colors.red))),
              duration: Duration(seconds: 3),
            ),
          );
          return;
        }
        passengerIds.add(loggedInUser.uid);
      }

      isAdded = !isAdded; // Toggle the state
      buttonIcon = isAdded ? Icons.close : Icons.add; // Update the icon

      // Update in Firebase
      DatabaseReference ridesRef = FirebaseDatabase.instance.ref('rides');
      ridesRef.child(widget.ride.id).update({'passengerIds': passengerIds});
    });
  }
}
