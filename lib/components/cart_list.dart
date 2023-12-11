import 'package:carpool/constants.dart';
import 'package:flutter/material.dart';
import 'package:carpool/models/ride.dart';
import 'package:carpool/components/cart_tile.dart';

class CartList extends StatelessWidget {
  final Stream<List<Ride>> cartListStream;

  CartList({required this.cartListStream});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainColor,
      body: SafeArea(
        child: StreamBuilder<List<Ride>>(
          stream: cartListStream,
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

                  return CartTile(
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
