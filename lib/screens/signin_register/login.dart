import 'package:flutter/material.dart';
import 'package:lets_park/services/signin_provider.dart';
import 'package:lets_park/shared/shared_widgets.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final SharedWidget _sharedWidgets = SharedWidget();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _sharedWidgets.appBar(context),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sharedWidgets.headerWithLogo(),
              _sharedWidgets.note("Login and get started!"),
              _createForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _createForm() {
    final provider = Provider.of<SignInProvider>(context, listen: false);
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
                    controller: emailController,
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
                  const SizedBox(height: 10),
                  _sharedWidgets.textFormField(
                    action: TextInputAction.done,
                    controller: passwordController,
                    label: 'Password',
                    obscure: true,
                    icon: const Icon(Icons.lock),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your password";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  child: const Text(
                    "Forgot password?",
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                    ),
                  ),
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 50),
            _sharedWidgets.button(
              label: 'Login',
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  provider.signinWithEmailAndPass(emailController.text.trim(), passwordController.text.trim(), context);

                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
