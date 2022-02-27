import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lets_park/screens/logged_in_screens/home.dart';

class DummyPage extends StatelessWidget {
  const DummyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dummy Page to pop"),
      ),
      body: Column(
        children: [
          const Text("Please turn on location services"),
          ElevatedButton(
              onPressed: () {
                getLocation(context);
              },
              child: Text("Let's do it!")),
        ],
      ),
    );
  }

  void getLocation(BuildContext context) async {
    
  }
}
