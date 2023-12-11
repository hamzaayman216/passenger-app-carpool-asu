import 'dart:async';
import 'package:carpool/constants.dart';
import 'package:flutter/material.dart';
import 'package:carpool/models/ride.dart';
import 'package:firebase_auth/firebase_auth.dart' as fbAuth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

late fbAuth.User loggedInUser;

class PaymentScreen extends StatefulWidget {
  final Ride ride;

  PaymentScreen({required this.ride});
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _auth = FirebaseAuth.instance;
  bool userHasPaid = false;
  bool card = false;
  bool cash = false;

  Future<bool> isUserPaid() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return false;
      }

      String userId = user.uid;
      String rideId = widget.ride.id;

      DatabaseReference paidStatusRef = FirebaseDatabase.instance.ref('paidStatus');

      Query query = paidStatusRef
          .orderByChild('userId')
          .equalTo(userId)
          .orderByChild('rideId')
          .equalTo(rideId)
          .limitToFirst(1);

      // Create a completer to handle the asynchronous result
      Completer<bool> completer = Completer<bool>();

      // Listen to the 'onValue' event
      query.onValue.listen((event) {
        if (event.snapshot.value == null) {
          completer.complete(false);
        } else {
          Map<dynamic, dynamic> paymentData = event.snapshot.value as Map<dynamic, dynamic>;
          bool paid = paymentData.values.first['paid'] == true;
          completer.complete(paid);
        }
      });

      // Return the future from the completer
      return completer.future;
    } catch (e) {
      print('Error checking payment status: $e');
      return false;
    }
  }


  @override
  void initState() {
    super.initState();
    _fetchUserPaidStatus();
  }

  Future<void> _fetchUserPaidStatus() async {
    bool paidStatus = await isUserPaid();
    setState(() {
      userHasPaid = paidStatus;
    });
  }


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
                'Choose Payment Method',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  color: kSecondaryColor,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Payment Method:',
                    style: TextStyle(color: kSecondaryColor, fontSize: 15),
                  ),
                  Checkbox(
                    checkColor: Colors.lightBlueAccent,
                    side: BorderSide(color: kMainColor),
                    fillColor: MaterialStateProperty.all(Colors.white),
                    value: cash,
                    onChanged: (bool? value) {
                      setState(() {
                        cash = value!;
                        if (cash) card = false;
                      });
                    },
                  ),
                  Icon(Icons.money,color: kSecondaryColor,),
                  Text('Cash',style: TextStyle(color: kSecondaryColor),),
                  Checkbox(
                    checkColor: Colors.lightBlueAccent,
                    side: BorderSide(color: kMainColor),
                    fillColor: MaterialStateProperty.all(Colors.white),
                    value: card,
                    onChanged: (bool? value) {
                      setState(() {
                        card = value!;
                        if (card) cash = false;
                      });
                    },
                  ),
                  Icon(Icons.credit_card,color: kSecondaryColor,),
                  Text('Card',style: TextStyle(color: kSecondaryColor),),
                ],
              ),
              Center( // Wrap IconButton with Center widget
                child: TextButton(
                  child: Text('Checkout',style: TextStyle(
                    color: Colors.white,
                  ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () async {
                    if (!cash && !card) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Center(
                            child: Text('Please choose a payment method', style: TextStyle(color: Colors.red)),
                          ),
                          duration: Duration(seconds: 3),
                        ),
                      );
                      return;
                    }
                    if (!widget.ride.confirmed) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Center(
                            child: Text('This ride has not been confirmed yet', style: TextStyle(color: Colors.red)),
                          ),
                          duration: Duration(seconds: 3),
                        ),
                      );
                      return;
                    }

                    final user = _auth.currentUser;
                    if (user != null) {
                      bool isPassenger = widget.ride.passengerIds?.contains(user.uid) ?? false;
                      if (isPassenger) {
                        DatabaseReference paidStatusRef = FirebaseDatabase.instance.ref('paidStatus');
                        String paymentMethod = card ? 'Card' : 'Cash';
                        bool isPaid = card; // Assume if payment is by card, it's paid

                        // Query to check if an entry already exists
                        Query existingPaymentQuery = paidStatusRef.orderByChild('rideId').equalTo(widget.ride.id);

                        existingPaymentQuery.once().then((DatabaseEvent event) {
                          if (event.snapshot.exists) {
                            Map<String, dynamic> payments = Map<String, dynamic>.from(event.snapshot.value as Map);
                            String? key;
                            for (var k in payments.keys) {
                              if (payments[k]['userId'] == user.uid) {
                                key = k;
                                break;
                              }
                            }
                            if (key != null) {
                              // Entry exists, update the existing entry
                              paidStatusRef.child(key).update({
                                'paid': isPaid,
                                'paymentMethod': paymentMethod,
                              });
                            } else {
                              // Entry does not exist for this ride, add new
                              paidStatusRef.push().set({
                                'rideId': widget.ride.id,
                                'userId': user.uid,
                                'paid': isPaid,
                                'paymentMethod': paymentMethod,
                              });
                            }
                          } else {
                            // No entry exists, create a new one
                            paidStatusRef.push().set({
                              'rideId': widget.ride.id,
                              'userId': user.uid,
                              'paid': isPaid,
                              'paymentMethod': paymentMethod,
                            });
                          }
                        }).catchError((error) {
                          print("Failed to check existing payment status: $error");
                        });

                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Center(
                              child: Text('You are not a passenger of this ride', style: TextStyle(color: Colors.red)),
                            ),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    }
                  },



                ),
              )


            ],
          ),
        ));
  }
}