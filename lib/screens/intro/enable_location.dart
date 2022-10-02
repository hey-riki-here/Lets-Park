import 'package:flutter/material.dart';
import 'package:lets_park/screens/wrapper.dart';
import 'package:location/location.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnableLocationService extends StatelessWidget {
  const EnableLocationService({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        padding: const EdgeInsets.all(40.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/icons/map-type-2.png",
                // width: 40,
              ),
              const SizedBox(height: 50),
              const Text(
                "Enable GPS",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Activating your GPS will enable us to suggest nearby parking places. Isn't that great?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await activateLocationService();
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool("firstOpen", false);
                        Navigator.pushReplacement(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeftJoined,
                            childCurrent: this,
                            child: const Wrapper(),
                          ),
                        );
                      },
                      child: const Text(
                        "Turn on GPS",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                "Maybe later",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> activateLocationService() async {
    Location location = Location();

    bool _serviceEnabled;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
  }
}
