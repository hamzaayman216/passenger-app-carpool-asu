import 'package:carpool/constants.dart';
import 'package:carpool/models/user.dart';
import 'package:flutter/material.dart';
import 'package:carpool/models/ride.dart';
import 'package:firebase_auth/firebase_auth.dart' as fbAuth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

FirebaseDatabase database = FirebaseDatabase.instance;
late fbAuth.User loggedInUser;

class AddRideScreen extends StatefulWidget {
  @override
  State<AddRideScreen> createState() => _AddRideScreenState();
}

class _AddRideScreenState extends State<AddRideScreen> {
  final _auth = FirebaseAuth.instance;
  String errorMessage = '';
  int numberOfPassengers = 1;
  bool womenOnly = false;
  bool menOnly = false;
  bool acOn = false;
  bool noSmoking = false;
  List<String> preferences = [];
  DateTime? selectedDate;
  String? selectedRideTime;
  String selectedStart = 'Gate 3';
  String selectedEnd = 'Nasr City';


  @override
  void initState() {
    super.initState();
    getCurrentUser();
    setInitialTime();
  }

  void setInitialTime() {
    DateTime now = DateTime.now();
    if (now.hour <= 20) {
      selectedRideTime = '7:30 AM';
    } else  {
      selectedRideTime = '5:30 PM';
    }
  }



  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }



  void getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
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
              'Add Ride',
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
                  'From:',
                  style: TextStyle(color: kSecondaryColor, fontSize: 15),
                ),
                SizedBox(
                  width: 20,
                ),
                DropdownButton<String>(
                  value: selectedStart,
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: kSecondaryColor,
                  ),
                  style: TextStyle(color: kSecondaryColor),
                  onChanged: (String? value) {
                    setState(() {
                      selectedStart = value!;
                    });
                  },
                  dropdownColor: Colors.white,
                  items: points.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'To:',
                  style: TextStyle(color: kSecondaryColor, fontSize: 15),
                ),
                SizedBox(
                  width: 37,
                ),
                DropdownButton<String>(
                  value: selectedEnd,
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: kSecondaryColor,
                  ),
                  style: TextStyle(
                    color: kSecondaryColor,
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      selectedEnd = value!;
                    });
                  },
                  dropdownColor: Colors.white,
                  items: points.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Number of Passengers:',
                  style: TextStyle(color: kSecondaryColor, fontSize: 15),
                ),
                SizedBox(width: 20),
                DropdownButton<int>(
                  value: numberOfPassengers,
                  icon: Icon(Icons.arrow_drop_down, color: kSecondaryColor),
                  style: TextStyle(color: kSecondaryColor),
                  onChanged: (int? newValue) {
                    setState(() {
                      numberOfPassengers = newValue!;
                    });
                  },
                  dropdownColor: Colors.white,
                  items: List<int>.generate(5, (i) => i + 1)
                      .map<DropdownMenuItem<int>>((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Gender Preference:',
                  style: TextStyle(color: kSecondaryColor, fontSize: 15),
                ),
                Checkbox(
                  checkColor: Colors.lightBlueAccent,
                  side: BorderSide(color: kMainColor),
                  fillColor: MaterialStateProperty.all(Colors.white),
                  value: menOnly,
                  onChanged: (bool? value) {
                    setState(() {
                      menOnly = value!;
                      if (menOnly) womenOnly = false;
                    });
                  },
                ),
                Text('Men Only'),
                Checkbox(
                  checkColor: Colors.lightBlueAccent,
                  side: BorderSide(color: kMainColor),
                  fillColor: MaterialStateProperty.all(Colors.white),
                  value: womenOnly,
                  onChanged: (bool? value) {
                    setState(() {
                      womenOnly = value!;
                      if (womenOnly) menOnly = false;
                    });
                  },
                ),
                Text('Women Only'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Other Preferences:',
                  style: TextStyle(color: kSecondaryColor, fontSize: 15),
                ),
                Checkbox(
                  checkColor: Colors.lightBlueAccent,
                  side: BorderSide(color: kMainColor),
                  fillColor: MaterialStateProperty.all(Colors.white),
                  value: noSmoking,
                  onChanged: (bool? value) {
                    setState(() {
                      noSmoking = value!;
                    });
                  },
                ),
                Text('No-Smoking'),
                Checkbox(
                  checkColor: Colors.lightBlueAccent,
                  side: BorderSide(color: kMainColor),
                  fillColor: MaterialStateProperty.all(Colors.white),
                  value: acOn,
                  onChanged: (bool? value) {
                    setState(() {
                      acOn = value!;
                    });
                  },
                ),
                Text('AC On'),
              ],
            ),
            TextButton(
              onPressed: () => _selectDate(context),
              style: ElevatedButton.styleFrom(
                primary: Colors.white, // Set background color to black
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.date_range,
                    color: kSecondaryColor, // Set icon color to white
                  ),
                  SizedBox(
                      width: 8), // Add some space between the icon and text
                  Text(
                    'Selected Date: ${selectedDate != null ? selectedDate!.toLocal().toString().split(' ')[0] : 'Select Date'}',
                    style: TextStyle(color: kSecondaryColor),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer_outlined, color: kSecondaryColor,),
                Text(
                  'Selected Time',
                  style: TextStyle(color: kSecondaryColor, fontSize: 15),
                ),
                SizedBox(width: 20,),
                DropdownButton<String>(
                  dropdownColor: Colors.white,
                  value: selectedRideTime,
                  icon: Icon(Icons.arrow_drop_down, color: kSecondaryColor),
                  style: TextStyle(color: kSecondaryColor),
                  onChanged: (String? newValue) {
                      setState(() {
                        selectedRideTime = newValue;
                      });
                  },
                  items:
                      timeOptions.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            TextButton(
              onPressed: () async {
                if (selectedDate == null || selectedRideTime == null) {
                  setState(() {
                    errorMessage = 'Please choose Date and Time';
                  });
                  return;
                } else if ((selectedStart == 'Gate 3' ||
                        selectedStart == 'Gate 4') &&
                    (selectedEnd == 'Gate 3' || selectedEnd == 'Gate 4')) {
                  setState(() {
                    errorMessage = 'Path must be from or to university';
                  });
                  return;
                } else if ((selectedStart != 'Gate 3' &&
                        selectedStart != 'Gate 4') &&
                    (selectedEnd != 'Gate 3' && selectedEnd != 'Gate 4')) {
                  setState(() {
                    errorMessage = 'Path must be from or to university';
                  });
                  return;
                }

                if (selectedRideTime == '7:30 AM') {
                  if (selectedStart == 'Gate 3' || selectedStart == 'Gate 4') {
                    setState(() {
                      errorMessage = 'Invalid start point for 7:30 AM ride';
                    });
                    return;
                  } else if (selectedEnd != 'Gate 3' && selectedEnd != 'Gate 4') {
                    setState(() {
                      errorMessage = 'Invalid end point for 7:30 AM ride';
                    });
                    return;

                  }
                } else if (selectedRideTime == '5:30 PM') {
                  if (selectedEnd == 'Gate 3' || selectedEnd == 'Gate 4') {
                    setState(() {
                      errorMessage = 'Invalid end point for 5:30 PM ride';
                    });
                    return;
                  } else if (selectedStart != 'Gate 3' && selectedStart != 'Gate 4') {
                    setState(() {
                      errorMessage = 'Invalid start point for 5:30 PM ride';
                    });
                    return;
                  }
                }

                DateTime now = DateTime.now();

                if(selectedRideTime=='7:30 AM') {
                  int newHour = 7;
                  int newMinute=30;
                  DateTime modifiedDate = DateTime(
                    selectedDate!.year,
                    selectedDate!.month,
                    selectedDate!.day,
                    newHour,
                    newMinute,
                    selectedDate!.second,
                    selectedDate!.millisecond,
                    selectedDate!.microsecond,
                  );
                  if ((modifiedDate.difference(now!)).inMinutes<790) {
                    setState(() {
                      errorMessage = '7:30 AM rides should be added before 8 PM';
                    });
                    return;
                  }
                }else if(selectedRideTime=='5:30 PM'){
                  int newHour = 17;
                  int newMinute=30;
                  DateTime modifiedDate = DateTime(
                    selectedDate!.year,
                    selectedDate!.month,
                    selectedDate!.day,
                    newHour,
                    newMinute,
                    selectedDate!.second,
                    selectedDate!.millisecond,
                    selectedDate!.microsecond,
                  );
                  if ((modifiedDate.difference(now!)).inMinutes<390) {
                    setState(() {
                      errorMessage = '5:30 PM rides should be added before 11 AM';
                    });
                    return;
                  }
                }

                if (menOnly == true) {
                  preferences.add('Men Only');
                }
                if (womenOnly == true) {
                  preferences.add('Women Only');
                }
                if (noSmoking == true) {
                  preferences.add('No Smoking');
                }
                if (acOn == true) {
                  preferences.add('AC On');
                }

                String date =
                    '${selectedDate?.year}-${selectedDate?.month}-${selectedDate?.day}';
                String time = selectedRideTime!;

                String newRideId =
                    database.ref().child('rides').push().key ?? '';
                Ride ride = Ride(
                  time: time,
                  date: date,
                  endPoint: selectedEnd,
                  startPoint: selectedStart,
                  id: newRideId,
                  numberOfPassengers: numberOfPassengers,
                  confirmed: false,
                  preferences: preferences,
                  driverId: loggedInUser.uid,
                  chatMessages: [],
                  status: 'Pending'
                );

                await database.ref('rides/$newRideId').set(ride.toMap());
                Navigator.pop(context);
              },
              child: Text(
                'Add',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: kMainColor,
              ),
            ),
            Center(
              child: Text(
                errorMessage,
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
