import 'package:carpool/constants.dart';
import 'package:carpool/screens/chat_screen.dart';
import 'package:carpool/screens/payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:carpool/models/ride.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

late User loggedInUser;

class CartTile extends StatefulWidget {
  final Ride ride;

  CartTile({required this.ride});

  @override
  State<CartTile> createState() => _CartTileState();
}

class _CartTileState extends State<CartTile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late bool isAdded = false;
  IconData buttonIcon = Icons.add;
  bool userHasPaid = false;
  String driverImageUrl = '';
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
    DatabaseReference usersRef = FirebaseDatabase.instance.ref('users').child(driverId);
    DatabaseEvent event = await usersRef.once();

    if (event.snapshot.exists) {
      Map<String, dynamic> userData = Map<String, dynamic>.from(event.snapshot.value as Map);
      setState(() {
        driverImageUrl = userData['imageUrl'] ?? ''; // Update with actual default URL if needed
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
    bool userFound = widget.ride.passengerIds?.contains(loggedInUser.uid) ?? false;

    setState(() {
      isAdded = userFound;
      buttonIcon = isAdded ? Icons.close : Icons.add;
    });
  }

  void setupPaymentStatusListener() {
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }

    String userId = user.uid;
    String rideId = widget.ride.id;

    DatabaseReference paidStatusRef = FirebaseDatabase.instance.ref('paidStatus');
    Query query = paidStatusRef.orderByChild('userId').equalTo(userId);

    query.onValue.listen((event) {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> paymentData = event.snapshot.value as Map<dynamic, dynamic>;
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
          backgroundImage: driverImageUrl==''?AssetImage('images/avatar.jpg') as ImageProvider:NetworkImage(driverImageUrl) as ImageProvider, // Assuming driver image URL is provided in ride model
        ),
        title:Text(driverName, style: TextStyle(color: kSecondaryColor)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              icon: Icon(Icons.chat, color: kSecondaryColor, size: 25),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(rideId: widget.ride.id,loggedInUser:loggedInUser),
                  ),
                );
              },),
            SizedBox(width: 10),
            IconButton(
              icon: Icon(
                userHasPaid ? Icons.money_off : Icons.attach_money_rounded,
                color: Colors.green,
                size: 30,
              ),
              onPressed: () {
                if(userHasPaid){
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Center(
                          child: Text('You already paid for this ride',
                              style: TextStyle(color: Colors.red))),
                      duration: Duration(seconds: 3),
                    ),
                  );
                  return;
                }
                if (!isAdded) {
                  return;
                }
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: PaymentScreen(
                        ride: widget.ride,
                      ),
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(
                buttonIcon,
                color: Colors.green,
                size: 30,
              ),
              onPressed: () {
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
          return;
        }
        passengerIds.add(loggedInUser.uid);
      }

      isAdded = !isAdded;
      buttonIcon = isAdded ? Icons.close : Icons.add;
      DatabaseReference ridesRef = FirebaseDatabase.instance.ref('rides');
      ridesRef.child(widget.ride.id).update({'passengerIds': passengerIds});
    });
  }
}
