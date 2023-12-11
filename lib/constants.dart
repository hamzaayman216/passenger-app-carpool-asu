import 'package:flutter/material.dart';


String regexSpecialCharacters=r'[!@#$%^&*(),.?":{}|<>]';
String regexEmail=r'^\d{2}[pP]?\d{4}@eng.asu.edu.eg$';
String regexPhoneNumber=r'^01\d{9}$';
String regexName=r'^[a-zA-Z ]+$';

final List<String> points = [
  'Gate 3',
  'Gate 4',
  'Heliopolis',
  'Nasr City',
  'October',
  'Maadi',
  'Zamalek',
  '5th District',
  'Rehab',
  'Madinaty',
  'Abbaseya',
  '1st District',
];
final List<String> timeOptions = ['7:30 AM', '5:30 PM'];
const kMainColor =Colors.lightBlueAccent;
const kSecondaryColor=Colors.black;
//const kMainColor =Colors.orange;

const kTextFieldDecoration=InputDecoration(
  hintText: '',
  hintStyle:TextStyle(color: Colors.blueGrey),
  contentPadding:
  EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide:
    BorderSide(color: kMainColor, width: 1),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide:
    BorderSide(color: Colors.lightBlueAccent, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);

const kSendButtonTextStyle = TextStyle(
  color: Colors.lightBlueAccent,
  fontWeight: FontWeight.bold,
  fontSize: 18.0,
);

const kMessageTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  hintText: 'Type your message here...',
  border: InputBorder.none,
);

const kMessageContainerDecoration = BoxDecoration(
  border: Border(
    top: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
  ),
);