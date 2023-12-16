import 'package:carpool/components/rounded_button.dart';
import 'package:carpool/constants.dart';
import 'package:carpool/controller/validations.dart';
import 'package:carpool/models/user.dart';
import 'package:carpool/screens/passenger_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:carpool/models/database_manager.dart';

class ProfileEditScreen extends StatefulWidget {
  static const String id = 'profile_edit_screen';
  final CarPoolUser user;

  ProfileEditScreen({required this.user});

  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  File? _selectedImage;
  final _databaseManager = DatabaseManager();


  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }


  void saveProfile() async {
    String updatedName = _nameController.text.trim();
    String updatedPhoneNumber = _phoneController.text.trim();
    String userEmail = widget.user.email;
    String errorMessage = validateEdit(updatedPhoneNumber, updatedName);

    if (errorMessage != '') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(child: Text(errorMessage, style: TextStyle(color: Colors.red))),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    DatabaseReference usersRef = FirebaseDatabase.instance.ref('users');
    FirebaseStorage storage = FirebaseStorage.instance;

    try {
      String imageUrl = '';
      if (_selectedImage != null) {
        String fileName = 'profile_images/${DateTime.now().millisecondsSinceEpoch}_${_selectedImage!.path.split('/').last}';
        UploadTask uploadTask = storage.ref(fileName).putFile(_selectedImage!);
        TaskSnapshot snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
      }

      Query query = usersRef.orderByChild('email').equalTo(userEmail);
      DatabaseEvent event = await query.once();

      if (event.snapshot.exists) {
        Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
        String userId = data.keys.first;

        Map<String, Object> updates = {
          'name': updatedName,
          'phoneNumber': updatedPhoneNumber,
        };
        if (imageUrl.isNotEmpty) {
          updates['imageUrl'] = imageUrl;
        }
        await usersRef.child(userId).update(updates);

        await _databaseManager.updateUserProfile(
          id: userId,
          name: updatedName,
          phoneNumber: updatedPhoneNumber,
          profilePhotoUrl: imageUrl,
        );

        Navigator.pushNamed(context, PassengerScreen.id);
      } else {
      }
    } catch (e) {
    }
  }



  @override
  void initState() {
    super.initState();

    _databaseManager.open().then((_) {
      _nameController.text = widget.user.name;
      _emailController.text = widget.user.email;
      _phoneController.text = widget.user.phoneNumber;    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Edit Profile', style: TextStyle(color: kSecondaryColor)),
        elevation: 20,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: kSecondaryColor),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: <Widget>[
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 200,
              backgroundColor: Colors.white,
              backgroundImage: _selectedImage != null
                  ? FileImage(_selectedImage!)
                  : widget.user.imageUrl==''? AssetImage('images/avatar.jpg'): NetworkImage(widget.user.imageUrl) as ImageProvider,

            ),
          ),

          SizedBox(height: 10,),
          SizedBox(height: 20),
          TextField(
            controller: _nameController,
            decoration: kTextFieldDecoration,
            style: TextStyle(
              color: kSecondaryColor,
            ),
          ),
          SizedBox(height: 20),
          TextField(
            controller: _phoneController,
            decoration: kTextFieldDecoration,
            style: TextStyle(
              color: kSecondaryColor,
            ),
          ),
          SizedBox(height: 20),
          RoundedButton(
            'Save',
            kMainColor,
                () {
              saveProfile();
            },
          ),
        ],
      ),
    );
  }
}