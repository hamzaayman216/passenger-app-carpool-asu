import 'package:carpool/components/driver_history_tile.dart';
import 'package:carpool/constants.dart';
import 'package:flutter/material.dart';
import 'package:carpool/models/ride.dart';
import 'package:carpool/components/driver_ride_tile.dart';

class DriverHistoryList extends StatelessWidget {
  final Stream<List<Ride>> ridesStream;

  DriverHistoryList({required this.ridesStream});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainColor,
      body: SafeArea(
        child: StreamBuilder<List<Ride>>(
          stream: ridesStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              List<Ride> rides = snapshot.data ?? [];
              return ListView.builder(
                itemCount: rides.length,
                itemBuilder: (context, index) {
                  Ride ride = rides[index];

                  return DriverHistoryTile(
                    ride: ride,
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
