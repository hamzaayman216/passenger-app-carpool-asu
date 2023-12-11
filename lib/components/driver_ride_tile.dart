import 'package:carpool/constants.dart';
import 'package:carpool/models/paid_status.dart';
import 'package:carpool/models/user.dart'; // Ensure this path is correct for your CarPoolUser model
import 'package:carpool/screens/delete_ride_screen.dart';
import 'package:carpool/screens/driver_chat_screen.dart';
import 'package:carpool/screens/show_passengers_screen.dart';
import 'package:flutter/material.dart';
import 'package:carpool/models/ride.dart';
import 'package:firebase_database/firebase_database.dart';

class DriverRideTile extends StatefulWidget {
  final Ride ride;

  DriverRideTile({required this.ride});

  @override
  State<DriverRideTile> createState() => _DriverRideTileState();
}

class _DriverRideTileState extends State<DriverRideTile> {
  IconData deleteButtonIcon = Icons.delete;
  IconData checkButtonIcon = Icons.check;
  String driverImageUrl = 'default_image_url'; // Placeholder URL
  String driverName = '';
  String driverPhoneNumber = '';

  @override
  void initState() {
    super.initState();
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

  void fetchPassengersAndShowScreen() async {
    List<CarPoolUser> passengers = [];
    DatabaseReference usersRef = FirebaseDatabase.instance.ref('users');

    for (String passengerId in widget.ride.passengerIds ?? []) {
      DataSnapshot snapshot = await usersRef.child(passengerId).get();

      if (snapshot.exists) {
        Map<String, dynamic> userData =
            Map<String, dynamic>.from(snapshot.value as Map);
        CarPoolUser user = CarPoolUser.fromMap(
            userData); // Assuming you have a fromMap constructor
        passengers.add(user);
      }
    }

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
          backgroundImage: driverImageUrl==''?AssetImage('images/avatar.jpg') as ImageProvider:NetworkImage(driverImageUrl) as ImageProvider,
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
        trailing: Scrollbar(
          thickness: 4,
          radius: Radius.circular(10),
          thumbVisibility: true,
          child: SingleChildScrollView(

            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.groups_rounded,
                          color: kSecondaryColor, size: 30),
                      onPressed: fetchPassengersAndShowScreen,
                    ),
                    SizedBox(width: 10),
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: Icon(
                            (widget.ride.confirmed) ? Icons.close : Icons.check,
                            color: Colors.green,
                            size: 30),
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
                            if ((modifiedDate.difference(now!)).inMinutes < 480) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Center(
                                      child: Text(
                                          '7:30 AM rides should be confirmed before 11:30 PM',
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
                            if ((modifiedDate.difference(now!)).inMinutes < 60) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Center(
                                      child: Text(
                                          '5:30 PM rides should be confirmed before 4:30 PM',
                                          style: TextStyle(color: Colors.red))),
                                  duration: Duration(seconds: 3),
                                ),
                              );
                              return;
                            }
                          }
                          setState(() {
                            bool newConfirmationStatus = !widget.ride.confirmed;

                            DatabaseReference ridesRef =
                                FirebaseDatabase.instance.ref('rides');
                            ridesRef
                                .child(widget.ride.id)
                                .update({'confirmed': newConfirmationStatus});
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: Icon(deleteButtonIcon, color: Colors.red, size: 30),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) => SingleChildScrollView(
                              child: Container(
                                padding: EdgeInsets.only(
                                    bottom:
                                        MediaQuery.of(context).viewInsets.bottom),
                                child: DeleteRideScreen(ride: widget.ride),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 18),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.chat, color: kSecondaryColor, size: 30),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DriverChatScreen(rideId: widget.ride.id),
                          ),
                        );
                      },
                    ),
                    IconButton(
                        onPressed: () {
                          DatabaseReference ridesRef =
                              FirebaseDatabase.instance.ref('rides');
                          ridesRef
                              .child(widget.ride.id)
                              .update({'status': 'Started'});
                        },
                        icon: Icon(
                          Icons.play_arrow,
                          color: Colors.green,
                          size: 30,
                        )),
                    SizedBox(width: 7,),

                    IconButton(
                        onPressed: () async {
                          if (widget.ride.status == 'Started') {
                            DatabaseReference usersRef = FirebaseDatabase.instance.ref('users');
                            DatabaseReference paidStatusRef = FirebaseDatabase.instance.ref('paidStatus');
                            DatabaseReference ridesRef = FirebaseDatabase.instance.ref('rides');

                            int totalDeduction = 0;

                            for (String passengerId in widget.ride.passengerIds ?? []) {
                              Query paidStatusQuery = paidStatusRef.orderByChild('userId').equalTo(passengerId);
                              DataSnapshot querySnapshot = await paidStatusQuery.get();

                              if (querySnapshot.exists) {
                                Map<String, dynamic> paidStatuses = Map<String, dynamic>.from(querySnapshot.value as Map);
                                for (var key in paidStatuses.keys) {
                                  PaidStatus paidStatus = PaidStatus.fromMap(Map<String, dynamic>.from(paidStatuses[key]));

                                  if (paidStatus.rideId == widget.ride.id && paidStatus.paid && paidStatus.paymentMethod == 'Card') {
                                    DataSnapshot userSnapshot = await usersRef.child(passengerId).get();
                                    CarPoolUser user = CarPoolUser.fromMap(Map<String, dynamic>.from(userSnapshot.value as Map));
                                    usersRef.child(passengerId).update({'balance': user.balance - 20});
                                    totalDeduction += 20;
                                  }
                                }
                              }
                            }

                            // Update the driver's balance
                            DataSnapshot driverSnapshot = await usersRef.child(widget.ride.driverId).get();
                            CarPoolUser driver = CarPoolUser.fromMap(Map<String, dynamic>.from(driverSnapshot.value as Map));
                            usersRef.child(widget.ride.driverId).update({'balance': driver.balance + totalDeduction});

                            // Update the ride's status to 'Finished'
                            ridesRef.child(widget.ride.id).update({'status': 'Finished'});
                          } else {
                            // Show a Snackbar if the ride is not started
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Center(child: Text('Ride should be started first', style: TextStyle(color: Colors.red))),
                                duration: Duration(seconds: 3),
                              ),
                            );
                            return;
                          }
                        },



                        icon: Icon(
                          Icons.stop,
                          color: Colors.red,
                          size: 30,
                        )),
                    SizedBox(width: 10,)

                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
