import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lets_park/screens/documents/guidelines.dart';
import 'package:lets_park/screens/documents/privacy_policy.dart';
import 'package:lets_park/screens/documents/terms_and_conditions.dart';
import 'package:lets_park/services/signin_provider.dart';
import 'package:lets_park/shared/shared_widgets.dart';
import 'package:provider/provider.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final SharedWidget _sharedWidgets = SharedWidget();
  final firstNameController = TextEditingController();
  final surnameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final numberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isAgreed = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SignInProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _sharedWidgets.appBar(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  _sharedWidgets.headerWithLogo(),
                  const SizedBox(height: 20),
                  _sharedWidgets.note("Please complete the form"),
                  const SizedBox(height: 20),
                ],
              ),
              _createForm(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 8),
        child: ElevatedButton(
          onPressed: isAgreed
              ? () {
                  if (_formKey.currentState!.validate()) {
                    provider.signUpWithEmailandPassword(
                      name: firstNameController.text.trim() +
                          " " +
                          surnameController.text.trim(),
                      email: emailController.text.trim(),
                      password: passwordController.text.trim(),
                      context: context,
                    );
                  }
                }
              : null,
          child: const Text(
            "Register",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w400,
              fontSize: 20,
            ),
          ),
          style: ElevatedButton.styleFrom(
            primary: Colors.lightBlue,
            fixedSize: const Size(140, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50.0),
            ),
          ),
        ),
      ),
    );
  }

  Widget _createForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const SizedBox(height: 10),
          _sharedWidgets.textFormField(
            action: TextInputAction.next,
            controller: firstNameController,
            label: 'First name',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter your first name";
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _sharedWidgets.textFormField(
            action: TextInputAction.next,
            controller: surnameController,
            label: 'Surname',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter your surname";
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _sharedWidgets.textFormField(
            action: TextInputAction.next,
            controller: emailController,
            label: 'Email',
            textInputType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter your email";
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _sharedWidgets.textFormField(
            action: TextInputAction.next,
            controller: passwordController,
            label: 'Password',
            obscure: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter password";
              } else if (value.length < 8) {
                return "Passworrd must be at least 8 characters long";
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _sharedWidgets.textFormField(
            action: TextInputAction.done,
            controller: confirmPasswordController,
            label: 'Confirm Password',
            obscure: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please confirm the password";
              } else if (passwordController.text
                      .trim()
                      .compareTo(confirmPasswordController.text.trim()) !=
                  0) {
                return "Password does not match.";
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Checkbox(
                value: isAgreed,
                onChanged: (value) {
                  setState(() {
                    isAgreed = value!;
                  });
                },
              ),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    text: "I agree to the app's ",
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Privacy Policy',
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                fullscreenDialog: true,
                                builder: (context) => const PrivacyPolicy(),
                              ),
                            );
                          },
                        style: const TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                      const TextSpan(
                        text: ', ',
                      ),
                      TextSpan(
                        text: 'Terms and Conditions',
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                fullscreenDialog: true,
                                builder: (context) => const TermsAndConditions(),
                              ),
                            );
                          },
                        style: const TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                      const TextSpan(
                        text: ', and ',
                      ),
                      TextSpan(
                        text: 'Guidelines',
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                fullscreenDialog: true,
                                builder: (context) => const Guidelines(),
                              ),
                            );
                          },
                        style: const TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                      const TextSpan(
                        text: '.',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
