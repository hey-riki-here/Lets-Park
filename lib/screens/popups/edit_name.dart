import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lets_park/screens/popups/notice_dialog.dart';

class NameModifier extends StatelessWidget {
  const NameModifier({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController firstNameController = TextEditingController();
    final TextEditingController lastNameController = TextEditingController();
    final key = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text("Edit Name"),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset("assets/logo/app_icon.png"),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: key,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "What is your first name?",
                style: TextStyle(
                  fontSize: 22,
                ),
              ),
              TextFormField(
                controller: firstNameController,
                decoration: const InputDecoration(hintText: "Eg. Kevin"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Field is required.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 25),
              const Text(
                "What is your last name?",
                style: TextStyle(
                  fontSize: 22,
                ),
              ),
              TextFormField(
                controller: lastNameController,
                decoration: const InputDecoration(hintText: "Eg. Pelayo"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Field is required.";
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.check,
        ),
        onPressed: () async {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => WillPopScope(
              onWillPop: () async => false,
              child: const NoticeDialog(
                imageLink: "assets/logo/lets-park-logo.png",
                message: "We are now updating your profile. Please wait.",
                forLoading: true,
              ),
            ),
          );

          await FirebaseAuth.instance.currentUser!.updateDisplayName(
              firstNameController.text.trim() +
                  " " +
                  lastNameController.text.trim());

          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }
}
