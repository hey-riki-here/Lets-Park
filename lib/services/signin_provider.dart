// ignore_for_file: empty_catches, unused_catch_clause

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:lets_park/main.dart';
import 'package:lets_park/models/app_user.dart';
import 'package:lets_park/screens/loading_screens/logging_in_screen.dart';
import 'package:lets_park/screens/popups/notice_dialog.dart';
import 'package:lets_park/screens/signin_register/login.dart';
import 'package:lets_park/screens/signin_register/register.dart';
import 'package:lets_park/globals/globals.dart' as globals;

class SignInProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _googleUser;
  GoogleSignInAccount get getGoogleUser => _googleUser!;
  Future signinWithEmailAndPass(
    String email,
    String password,
    BuildContext context,
  ) async {
    _showLoading(context);

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      await _showDialog(
        context,
        "assets/logo/lets-park-logo.png",
        "Login failed! Please make sure to enter correct account credentials.",
      );
      navigatorKey.currentState!.popUntil((route) => route.isFirst);
      Navigator.push(
          context, MaterialPageRoute(builder: ((context) => const Login())));
    }
  }

  Future signUpWithEmailandPassword({
    required String name,
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    _showLoading(context);
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await _auth.currentUser!.updateDisplayName(name);
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      await _showDialog(
        context,
        "assets/logo/lets-park-logo.png",
        "Looks like the email you entered is already link to another account. Please try different email.",
      );
      navigatorKey.currentState!.popUntil((route) => route.isFirst);
      Navigator.push(
          context, MaterialPageRoute(builder: ((context) => const Register())));
    }
  }

  Future googleLogin(BuildContext context) async {
    try {
      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) return;
      showDialog(context: context, builder: (context) => LoggingIn());
      _googleUser = googleUser;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      retrieveUserData();
    } on Exception catch (e) {
    } finally {
      notifyListeners();
      navigatorKey.currentState!.popUntil((route) => route.isFirst);
    }
  }

  Future loginWithFacebook(BuildContext context) async {
    _showLoading(context);
    try {
      final result = await FacebookAuth.instance.login();
      final fbUserCredentials =
          FacebookAuthProvider.credential(result.accessToken!.token);
      await _auth.signInWithCredential(fbUserCredentials);
    } on Exception catch (e) {
      await _showDialog(
        context,
        "assets/logo/lets-park-logo.png",
        "Looks like the email linked in your Facebook account is already link to another account. Try logging in instead.",
      );
    } finally {
      notifyListeners();
      navigatorKey.currentState!.popUntil((route) => route.isFirst);
    }
  }

  Future logout(BuildContext context) async {
    _showLoading(context);

    try {
      await FacebookAuth.instance.logOut();
    } on Exception catch (e) {}
    try {
      await googleSignIn.disconnect();
    } on Exception catch (e) {}
    _auth.signOut();

    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }

  void _showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Future _showDialog(
    BuildContext context,
    String image,
    String message,
  ) async {
    return showDialog(
      context: context,
      builder: (context) {
        return (NoticeDialog(
          imageLink: image,
          message: message,
        ));
      },
    );
  }

  void retrieveUserData() async {
    globals.appUser.setUserId = _auth.currentUser!.uid;
  }
}
