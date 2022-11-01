import 'package:flutter/material.dart';
import 'package:lets_park/services/signin_provider.dart';
import 'package:lets_park/shared/shared_widgets.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lets_park/screens/signin_register/email_sent.dart';

class ForgotPassword extends StatefulWidget {
  final String email;
  const ForgotPassword({Key? key, this.email = "",}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController? emailController;
  final _formKey = GlobalKey<FormState>();
  final SharedWidget _sharedWidgets = SharedWidget();
  bool canResend = true;

  @override
  initState(){
    emailController = TextEditingController(text: widget.email);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              child: Image.asset("assets/logo/app_icon.png"),
            ),
            const SizedBox(width: 5),
            const Text(
              "Let's Park!",
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Password reset",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "We will send a link for resetting your password on the email you enter below.",
                style: TextStyle(
                  color: Colors.black45,
                ),
              ),
              const SizedBox(height: 20),
              _createForm(),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: canResend ? [
                  TextButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Cancel"
                    ),
                  ),
                  const SizedBox(width: 5),
                  ElevatedButton(
                    onPressed: resetPassword,
                    child: const Text(
                      "Reset password"
                    ),
                  ),
                ] : [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.grey.shade500,
                      strokeWidth: 3,
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

  Widget _createForm() {
    return Form(
      key: _formKey,
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  _sharedWidgets.textFormField(
                    action: TextInputAction.next,
                    controller: emailController!,
                    label: 'Email',
                    textInputType: TextInputType.emailAddress,
                    icon: const Icon(Icons.person),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your email";
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
    );
  }

  void showToast() {  
    Fluttertoast.showToast(  
      msg: 'Password reset email sent.',  
      toastLength: Toast.LENGTH_LONG,
      backgroundColor: Colors.grey[200],
      textColor: Colors.black,
    );  
  }  

  void resetPassword() async {

    if (_formKey.currentState!.validate()){

    }
    setState((){
      canResend = false;
    });

    await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController!.text.trim());
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const PasswordResetSent(),
      ),
    );
    showToast();
    
  }
}
