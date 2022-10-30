// ignore_for_file: empty_catches, unused_catch_clause

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lets_park/screens/popups/edit_name.dart';
import 'package:lets_park/screens/popups/notice_dialog.dart';
import 'package:lets_park/services/firebase_api.dart';
import 'package:lets_park/shared/shared_widgets.dart';

class UpdateProfile extends StatefulWidget {
  final Function notifyParent;
  const UpdateProfile({
    Key? key,
    required this.notifyParent,
  }) : super(key: key);

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  User user = FirebaseAuth.instance.currentUser!;
  final _numberKey = GlobalKey<FormState>();
  late TextEditingController _numberController;
  final SharedWidget _sharedWidget = SharedWidget();
  String photoUrl =
      "https://cdn4.iconfinder.com/data/icons/user-people-2/48/5-512.png";
  String originalNumber = "";
  File? image;
  final _textStyle = const TextStyle(
    color: Colors.black45,
  );

  @override
  void initState() {
    _numberController = TextEditingController(text: FirebaseAuth.instance.currentUser!.phoneNumber);
    if (user.photoURL != null) {
      photoUrl = user.photoURL!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                       photoUrl,
                      ),
                      radius: 40,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user.displayName!,
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
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      photoUrl,
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
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (context) => WillPopScope(
                                              onWillPop: () async => false,
                                              child: const NoticeDialog(
                                                imageLink:
                                                    "assets/logo/lets-park-logo.png",
                                                message:
                                                    "We are now updating your profile. Please wait.",
                                                forLoading: true,
                                              ),
                                            ),
                                          );
                                          String newUrl = "";
                                          await FirebaseServices.uploadImage(
                                            imageTemp,
                                            "avatar/" +
                                                imageTemp.path.split('/').last,
                                          ).then((url) {
                                            newUrl = url;
                                          });
                                          await user.updatePhotoURL(newUrl);
                                          Navigator.pop(context);
                                          setState(() {
                                            user = FirebaseAuth.instance.currentUser!;
                                            photoUrl = user.photoURL!;
                                            widget.notifyParent();
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Full name"),
                              const SizedBox(height: 5),
                              TextFormField(
                                readOnly: true,
                                key: Key(user.toString()),
                                initialValue: user.displayName,
                                textInputAction: TextInputAction.done,
                                decoration: InputDecoration(
                                  suffixIcon: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: ((context) =>
                                              const NameModifier()),
                                        ),
                                      ).then((value) {
                                        setState(() {
                                          user = FirebaseAuth
                                              .instance.currentUser!;
                                          widget.notifyParent();
                                        });
                                      });
                                    },
                                    child: const Icon(
                                      FontAwesomeIcons.pencilAlt,
                                      color: Colors.blue,
                                      size: 17,
                                    ),
                                  ),
                                  border: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                  ),
                                ),
                              ),
                            ],
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
                                _sharedWidget.textFormField(
                                  action: TextInputAction.done,
                                  textInputType: TextInputType.number,
                                  controller: _numberController,
                                  obscure: false,
                                  readOnly: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Enter phone number";
                                    } else if (value.length < 10) {
                                      return "Invalid phone number";
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextFormField _buildFields(
    TextEditingController? controller,
    String label,
    String type,
    bool readOnly,
  ) {
    return TextFormField(
      readOnly: readOnly,
      maxLength: type.compareTo("text") == 0 ? 55 : 11,
      controller: controller,
      textInputAction: TextInputAction.done,
      keyboardType: type.compareTo("text") == 0
          ? TextInputType.text
          : TextInputType.number,
      decoration: const InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      onChanged: (value) {},
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Field is required.";
        }
        return null;
      },
    );
  }

  
}
