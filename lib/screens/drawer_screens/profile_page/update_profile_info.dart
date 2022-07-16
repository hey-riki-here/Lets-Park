// ignore_for_file: empty_catches, unused_catch_clause

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lets_park/globals/globals.dart' as globals;
import 'package:lets_park/main.dart';
import 'package:lets_park/models/user_data.dart';
import 'package:lets_park/screens/drawer_screens/profile.dart';
import 'package:lets_park/screens/popups/notice_dialog.dart';
import 'package:lets_park/services/firebase_api.dart';
import 'package:lets_park/services/signin_provider.dart';

class UpdateProfile extends StatefulWidget {
  final UserData userData;
  const UpdateProfile({
    Key? key,
    required this.userData,
  }) : super(key: key);

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  final _nameKey = GlobalKey<FormState>();
  final _numberKey = GlobalKey<FormState>();
  late TextEditingController _fNameController;
  late TextEditingController _lNameController;
  late TextEditingController _numberController;
  String originalFirst = "";
  String originalLast = "";
  String originalNumber = "";
  bool disableSaveButton = true, imageChanged = false;
  File? image;
  final _textStyle = const TextStyle(
    color: Colors.black45,
  );

  @override
  void initState() {
    originalFirst = widget.userData.getFirstName!;
    originalLast = widget.userData.getLastName!;
    originalNumber = widget.userData.getPhoneNumber!;

    _fNameController = TextEditingController(text: originalFirst);
    _lNameController = TextEditingController(text: originalLast);
    _numberController = TextEditingController(text: originalNumber);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (disableSaveButton == false) {
          await _showDialog(
            imageLink: "assets/icons/marker.png",
            message: "Are you sure you want to discard changes?",
            forConfirmation: true,
          );
          return globals.popWindow;
        } else {
          return true;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Update Profile",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      imageChanged
                          ? CircleAvatar(
                              backgroundImage: FileImage(image!),
                              radius: 40,
                            )
                          : CircleAvatar(
                              backgroundImage: NetworkImage(
                                widget.userData.getImageURL!,
                              ),
                              radius: 40,
                            ),
                      const SizedBox(height: 10),
                      Text(
                        widget.userData.getFirstName! +
                            " " +
                            widget.userData.getLastName!,
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(FirebaseAuth.instance.currentUser!.email!),
                      const SizedBox(height: 15),
                      const Text(
                        "Profile Info",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Column(
                  children: [
                    const Text(
                      "Basic Information",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: Colors.black26,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(8),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "DISPLAY PHOTO",
                                      style: _textStyle,
                                    ),
                                    Text(
                                      "Choose a photo for identity purposes.",
                                      style: _textStyle,
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    imageChanged
                                        ? CircleAvatar(
                                            backgroundImage: FileImage(image!),
                                            radius: 30,
                                          )
                                        : CircleAvatar(
                                            backgroundImage: NetworkImage(
                                              widget.userData.getImageURL!,
                                            ),
                                            radius: 30,
                                          ),
                                    Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: TextButton(
                                        onPressed: () async {
                                          try {
                                            final image =
                                                await ImagePicker().pickImage(
                                              source: ImageSource.gallery,
                                            );
                                            if (image == null) return;
                                            final imageTemp = File(image.path);

                                            setState(() {
                                              imageChanged = true;
                                              disableSaveButton = false;
                                              this.image = imageTemp;
                                            });
                                          } on Exception catch (e) {}
                                        },
                                        child: Row(
                                          children: const [
                                            Text(
                                              "Replace",
                                              style: TextStyle(
                                                color: Colors.blue,
                                              ),
                                            ),
                                            SizedBox(width: 5),
                                            Icon(
                                              Icons.camera_alt_outlined,
                                              color: Colors.blue,
                                              size: 16,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(),
                            const SizedBox(height: 5),
                            Row(
                              children: const [
                                Text("NAME"),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Form(
                              key: _nameKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("First name"),
                                  const SizedBox(height: 5),
                                  _buildFields("Firstname", "text"),
                                  const SizedBox(height: 10),
                                  const Text("Last name"),
                                  const SizedBox(height: 5),
                                  _buildFields("Lastname", "text"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Contacts",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: Colors.black26,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(8),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "EMAIL",
                              style: _textStyle,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "All of your bookings and reservations' info will be sent through your email. It can't however be changed.",
                              style: _textStyle,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              FirebaseAuth.instance.currentUser!.email!,
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Divider(),
                            const SizedBox(height: 5),
                            Form(
                              key: _numberKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Phone number"),
                                  const SizedBox(height: 5),
                                  _buildFields("Phonenum", "number"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildButtons(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextFormField _buildFields(String label, String type) {
    return TextFormField(
      maxLength: type.compareTo("text") == 0 ? 55 : 11,
      controller: label.compareTo("Firstname") == 0
          ? _fNameController
          : label.compareTo("Lastname") == 0
              ? _lNameController
              : _numberController,
      textInputAction: TextInputAction.done,
      keyboardType: type.compareTo("text") == 0
          ? TextInputType.text
          : TextInputType.number,
      decoration: const InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      onChanged: (value) {
        setState(() {
          if (_fNameController.text.compareTo(originalFirst) != 0 ||
              _lNameController.text.compareTo(originalLast) != 0 ||
              _numberController.text.compareTo(originalNumber) != 0 ||
              imageChanged) {
            disableSaveButton = false;
          } else {
            disableSaveButton = true;
          }
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Field is required.";
        }
        return null;
      },
    );
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () {},
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: disableSaveButton
              ? null
              : () async {
                  bool isNameValidated = false, isNumberValidated = false;

                  if (_nameKey.currentState!.validate()) {
                    isNameValidated = true;
                  }

                  if (_numberKey.currentState!.validate()) {
                    isNumberValidated = true;
                  }

                  if (isNameValidated && isNumberValidated) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => WillPopScope(
                        onWillPop: () async => false,
                        child: const NoticeDialog(
                          imageLink: "assets/logo/lets-park-logo.png",
                          message:
                              "We are now updating your profile. Please wait.",
                          forLoading: true,
                        ),
                      ),
                    );

                    if (imageChanged) {
                      await FirebaseServices.uploadImage(
                        image!,
                        "avatar/" + image!.hashCode.toString(),
                      ).then((url) async {
                        await FirebaseFirestore.instance
                            .collection('user-data')
                            .doc(widget.userData.getUserId)
                            .update({
                          'imageUrl': url,
                        });
                      });
                    }

                    if (_fNameController.text.compareTo(originalFirst) != 0) {
                      await FirebaseFirestore.instance
                          .collection('user-data')
                          .doc(widget.userData.getUserId)
                          .update({
                        'firstName': _fNameController.text,
                      });
                    }

                    if (_lNameController.text.compareTo(originalLast) != 0) {
                      await FirebaseFirestore.instance
                          .collection('user-data')
                          .doc(widget.userData.getUserId)
                          .update({
                        'lastName': _lNameController.text,
                      });
                    }

                    if (_numberController.text.compareTo(originalNumber) != 0) {
                      await FirebaseFirestore.instance
                          .collection('user-data')
                          .doc(widget.userData.getUserId)
                          .update({
                        'phoneNumber': _numberController.text,
                      });
                    }

                    await SignInProvider.getUserData(widget.userData.getUserId!).then((userData) {
                      globals.loggedIn = userData;
                    });

                    navigatorKey.currentState!
                        .popUntil((route) => route.isFirst);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: ((context) => const Profile()),
                      ),
                    );
                  }
                },
          child: const Text("Save"),
        ),
      ],
    );
  }

  Future _showDialog(
      {required String imageLink,
      required String message,
      bool? forConfirmation = false}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return NoticeDialog(
          imageLink: imageLink,
          message: message,
          forConfirmation: forConfirmation!,
        );
      },
    );
  }
}
