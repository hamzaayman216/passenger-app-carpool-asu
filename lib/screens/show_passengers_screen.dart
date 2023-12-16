import 'package:carpool/constants.dart';
import 'package:carpool/controller/services/payment_status_service.dart';
import 'package:carpool/models/user.dart';
import 'package:flutter/material.dart';

class ShowPassengersScreen extends StatefulWidget {
  final List<CarPoolUser> passengers;
  final String rideId;

  ShowPassengersScreen({required this.passengers, required this.rideId});

  @override
  State<ShowPassengersScreen> createState() => _ShowPassengersScreenState();
}

class _ShowPassengersScreenState extends State<ShowPassengersScreen> {

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
                future: PaymentStatusService().getPaidStatus(passenger.email, widget.rideId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  bool isPaid = snapshot.data ?? false;
                  return Card(
                    color: Colors.white,
                    elevation: 4,
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
                                color: kSecondaryColor),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Phone: ${passenger.phoneNumber}',
                                style: TextStyle(
                                    color: kSecondaryColor),
                              ),
                              Text(
                                'Email: ${passenger.email}',
                                style: TextStyle(
                                    color: kSecondaryColor),
                              ),
                            ],
                          ),
                          trailing: isPaid
                              ? Icon(Icons.check_circle, color: Colors.green)
                              : Icon(Icons.cancel, color: Colors.red),
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