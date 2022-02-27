import 'package:flutter/material.dart';
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
  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SignInProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _sharedWidgets.appBar(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 120,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    _sharedWidgets.headerWithLogo(),
                    const SizedBox(height: 10),
                    _sharedWidgets.note("Please complete the form"),
                  ],
                ),
                _createForm(),
                _sharedWidgets.button(
                  label: 'Register',
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      provider.signUpWithEmailandPassword(
                        name: nameController.text.trim(),
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                        context: context,
                      );
                    }
                  },
                ),
              ],
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
            controller: nameController,
            label: 'Name',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter your name";
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
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
          const SizedBox(height: 10),
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
          const SizedBox(height: 10),
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
          const SizedBox(height: 10),
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
        ],
      ),
    );
  }
}
