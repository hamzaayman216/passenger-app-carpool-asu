import 'package:carpool/models/ride.dart';
import 'package:firebase_database/firebase_database.dart';

class RidesService {
  List<Ride> getDriverRides(DatabaseEvent snapshot, String driverId) {
    var ridesMap = snapshot.snapshot.value as Map<dynamic, dynamic>;
    List<Ride> rides = [];
    ridesMap.forEach((key, value) {
      if (value is Map<dynamic, dynamic>) {
        var rideMap = Map<String, dynamic>.from(value);
        var ride = Ride.fromMap(rideMap);
        if (ride.driverId == driverId && ride.status != 'Finished') {
          rides.add(ride);
        }
      }
    });
    return rides;
  }

  List<Ride> getHistoryRides(DatabaseEvent snapshot, String driverId) {
    var ridesMap = snapshot.snapshot.value as Map<dynamic, dynamic>;
    List<Ride> rides = [];
    ridesMap.forEach((key, value) {
      if (value is Map<dynamic, dynamic>) {
        var rideMap = Map<String, dynamic>.from(value);
        var ride = Ride.fromMap(rideMap);
        if (ride.driverId == driverId && ride.status == 'Finished') {
          rides.add(ride);
        }
      }
    });
    return rides;
  }

}