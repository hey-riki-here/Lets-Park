import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:lets_park/screens/intro/allow_location.dart';
import 'package:lets_park/shared/shared_widgets.dart';

class Introduction extends StatelessWidget {
  const Introduction({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SharedWidget _sharedWidgets = SharedWidget();

    return SafeArea(
      child: IntroductionScreen(
        pages: [
          PageViewModel(
            title: 'Park with ease!',
            body: 'View avaialbe parking area near you and view information.',
            image: getImageFromAsset('assets/images/intro_1.png'),
          ),
          PageViewModel(
            title: 'Book or Pay Now a parking area!',
            body: 'Reserve a parking area or pay immedialety a parking area.',
            image: getImageFromAsset('assets/images/intro_2.png'),
          ),
          PageViewModel(
            title: 'Rent out your space',
            body: "Register your vacant space it’s easy and free!",
            image: getImageFromAsset('assets/images/intro_3.png'),
          ),
          PageViewModel(
            title: 'Earn from your space!',
            body: "Generate extra income from your registered space.",
            image: getImageFromAsset('assets/images/intro_4.png'),
            footer: Padding(
              padding: const EdgeInsets.only(top: 100),
              child: _sharedWidgets.button(
                label: 'Continue',
                onPressed: () => navigateToAllowLocationPermission(context),
              ),
            ),
          ),
        ],
        showSkipButton: true,
        showDoneButton: true,
        skip: const Text(
          'Skip',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        next: const Icon(
          Icons.arrow_forward,
          color: Colors.black,
        ),
        done: const Text(
          'Done',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        dotsDecorator: DotsDecorator(
          activeSize: const Size(22, 10),
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        onSkip: () => navigateToAllowLocationPermission(context),
        onDone: () => navigateToAllowLocationPermission(context),
      ),
    );
  }

  Widget getImageFromAsset(String asset) {
    return Center(
      child: Image.asset(
        asset,
        width: 650,
      ),
    );
  }

  void navigateToAllowLocationPermission(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AllowLocationPermission(),
      ),
    );
  }
}
