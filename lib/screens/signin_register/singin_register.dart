import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lets_park/screens/signin_register/login.dart';
import 'package:lets_park/screens/signin_register/register.dart';
import 'package:lets_park/services/signin_provider.dart';
import 'package:lets_park/shared/shared_widgets.dart';
import 'package:provider/provider.dart';

class SignInOrRegister extends StatelessWidget {
  const SignInOrRegister({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SharedWidget _sharedWidgets = SharedWidget();
    final provider = Provider.of<SignInProvider>(context, listen: false);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sharedWidgets.headerWithLogo(),
              _sharedWidgets
                  .note("Sign in or create account to enjoy our app!"),
              _buttons(context, provider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buttons(BuildContext context, SignInProvider provider) {
    // ignore: constant_identifier_names
    const _BUTTON_TEXT_STYLE = TextStyle(
      fontSize: 16,
    );

    // defining the style of same design buttons
    var _buttonStyle = ElevatedButton.styleFrom(
      primary: Colors.white,
      onPrimary: Colors.black,
      side: const BorderSide(
        width: 1.0,
        color: Colors.black38,
      ),
      elevation: 0,
      minimumSize: const Size(
        double.infinity,
        50,
      ),
    );

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              primary: Colors.indigo,
              minimumSize: const Size(double.infinity, 50),
            ),
            label: const Text(
              "Continue with Facebook",
              style: _BUTTON_TEXT_STYLE,
            ),
            icon: const FaIcon(FontAwesomeIcons.facebookSquare),
            onPressed: () {
              provider.loginWithFacebook(context);
            },
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            style: _buttonStyle,
            label: const Text(
              "Continue with Google",
              style: _BUTTON_TEXT_STYLE,
            ),
            icon: const FaIcon(
              FontAwesomeIcons.google,
              size: 16,
              color: Colors.red,
            ),
            onPressed: () {
              provider.googleLogin(context);
            },
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            style: _buttonStyle,
            child: const Text(
              "Login now",
              style: _BUTTON_TEXT_STYLE,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: ((context) => const Login()),
              ),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            style: _buttonStyle,
            child: const Text(
              "Create account",
              style: _BUTTON_TEXT_STYLE,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: ((context) => const Register()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
