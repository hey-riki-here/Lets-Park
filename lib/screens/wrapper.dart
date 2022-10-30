import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lets_park/screens/signin_register/singin_register.dart';
import 'package:lets_park/screens/signin_register/otp_verification.dart';
import 'package:lets_park/screens/signin_register/phone_number.dart';
import 'logged_in_screens/home_screen.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasData) {
            print("Called");
            return FirebaseAuth.instance.currentUser!.phoneNumber != null ? const HomeScreen() : const PhoneNumber();
          } else {
            return const SignInOrRegister();
          }
        },
      ),
    );
  }
}
