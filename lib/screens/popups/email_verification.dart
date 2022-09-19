import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmailVerification extends StatefulWidget {
  const EmailVerification({
    Key? key,
  }) : super(key: key);

  @override
  State<EmailVerification> createState() => _EmailVerificationState();
}

class _EmailVerificationState extends State<EmailVerification> {
  Timer? timer;
  bool isEmailVerified = false;
  bool canResend = true;
  String buttonLabel = "Send verification email";
  bool isLoading = false;
  String header = "Email Verification";
  Icon icon = const Icon(
    Icons.email_outlined,
    color: Colors.black54,
    size: 50,
  );

  @override
  void initState() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      checkEmailVerified();
    });

    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset("assets/logo/app_icon.png"),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isLoading
                  ? const CircularProgressIndicator()
                  : Column(
                      children: [
                        isEmailVerified
                            ? const Icon(
                                Icons.mark_email_read_outlined,
                                color: Colors.black54,
                                size: 50,
                              )
                            : icon,
                        const SizedBox(height: 15),
                        Text(
                          isEmailVerified ? "Email verified!" : header,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
              const SizedBox(height: 15),
              Text(
                isEmailVerified
                    ? "Email successfully verified! You can now rent parking spaces."
                    : "Check your Spam if you did not find the verification email.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: isEmailVerified
                        ? ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              primary: Colors.green,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.check_circle_outlined),
                            label: const Text(
                              "Continue renting",
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              primary: Colors.green,
                            ),
                            onPressed: canResend
                                ? () async {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    await FirebaseAuth.instance.currentUser!
                                        .sendEmailVerification();
                                    setState(() {
                                      isLoading = false;
                                      header = "Email verification sent!";
                                      icon = const Icon(
                                        Icons.mark_email_unread_outlined,
                                        color: Colors.black54,
                                        size: 50,
                                      );
                                    });
                                    setState(() {
                                      canResend = false;
                                    });
                                    await Future.delayed(
                                      const Duration(seconds: 10),
                                    );
                                    setState(() {
                                      canResend = true;
                                      buttonLabel = "Resend verification email";
                                    });
                                  }
                                : null,
                            icon: const Icon(Icons.email_rounded),
                            label: Text(
                              buttonLabel,
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: (){
                  Navigator.pop(context);
                },
                child: Text(
                  isEmailVerified ? "Close" : "Cancel verification",
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 17,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();

    //if (mounted) {
      setState(() {
        isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
      });
    //}
  }
}
