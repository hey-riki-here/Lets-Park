import 'package:flutter/material.dart';
import 'package:lets_park/shared/shared_widgets.dart';
import 'package:lets_park/screens/signin_register/otp_verification.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PhoneNumber extends StatefulWidget {
  const PhoneNumber({
    Key? key,
  }) : super(key: key);

  @override
  State<PhoneNumber> createState() => _PhoneNumberState();
}

class _PhoneNumberState extends State<PhoneNumber> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController numberController;
  final SharedWidget _sharedWidget = SharedWidget();

  @override
  void initState() {
    numberController =
        TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset("assets/logo/app_icon.png"),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue[100],
              radius: 50,
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  FirebaseAuth.instance.currentUser!.photoURL!,
                ),
                radius: 47,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              FirebaseAuth.instance.currentUser!.displayName!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 5),
            Text(FirebaseAuth.instance.currentUser!.email!),
            const SizedBox(height: 40),
            Row(
              children: const [
                Text(
                  "We are almost there...",
                  style: TextStyle(
                    fontSize: 22,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Row(
              children: const [
                Text(
                  "Enter your phone number here",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Form(
              key: formKey,
              child: _sharedWidget.textFormField(
                action: TextInputAction.done,
                textInputType: TextInputType.number,
                controller: numberController,
                hintText: "9182083028",
                obscure: false,
                icon: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      "+63",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter phone number";
                  } else if (value.length < 10) {
                    return "Invalid phone number";
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.forward,
        ),
        onPressed: ()  {
          if (formKey.currentState!.validate()){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OTPVerification(phoneNumber: "+63${numberController.text.trim()}")),
            );
          }
        },
      ),
    );
  }
}
