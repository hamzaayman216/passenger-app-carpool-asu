import 'package:flutter/material.dart';
import 'package:carpool/constants.dart';
import 'package:carpool/models/ride.dart';
import 'package:carpool/components/ride_tile.dart';

class RideList extends StatefulWidget {
  final Stream<List<Ride>> ridesStream;

  RideList({required this.ridesStream});

  @override
  _RideListState createState() => _RideListState();
}

class _RideListState extends State<RideList> {
  String searchStartPoint = '';
  String searchEndPoint = '';
  List<String> searchPreferences = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: StreamBuilder<List<Ride>>(
                stream: widget.ridesStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    List<Ride> rides = _filterRides(snapshot.data ?? []);
                    return ListView.builder(
                      itemCount: rides.length,
                      itemBuilder: (context, index) {
                        return RideTile(ride: rides[index]);
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search Start Point',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() => searchStartPoint = value);
            },
          ),
          SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search End Point',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() => searchEndPoint = value);
            },
          ),
          // Additional UI for preferences can be added here
        ],
      ),
    );
  }

  List<Ride> _filterRides(List<Ride> rides) {
    return rides.where((ride) {
      bool matchesStartPoint = ride.startPoint.toLowerCase().contains(searchStartPoint.toLowerCase());
      bool matchesEndPoint = ride.endPoint.toLowerCase().contains(searchEndPoint.toLowerCase());
      return matchesStartPoint && matchesEndPoint;
    }).toList();
  }

}
