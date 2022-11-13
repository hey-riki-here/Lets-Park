// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:flutter/material.dart';
import 'package:lets_park/models/parking_space.dart';
import 'package:lets_park/screens/drawer_screens/register_screens/info_and_features.dart';
import 'package:lets_park/screens/popups/notice_dialog.dart';
import 'package:lets_park/services/parking_space_services.dart';

class FeaturesModifier extends StatefulWidget {
  final ParkingSpace space;
  const FeaturesModifier({
    Key? key,
    required this.space,
  }) : super(key: key);

  @override
  State<FeaturesModifier> createState() => _FeaturesModifierState();
}

class _FeaturesModifierState extends State<FeaturesModifier> {
  final GlobalKey<FeaturesState> _featuresState = GlobalKey();

  final featuresItems = <FeaturesItem>[
    FeaturesItem(title: "With gate"),
    FeaturesItem(title: "CCTV"),
    FeaturesItem(title: "Covered Parking"),
    FeaturesItem(title: "Lighting"),
  ];
  List<String> features = [];

  @override
  void initState() {
    features = widget.space.getFeatures!;

    featuresItems.forEach((feature) {
      if (features.contains(feature.getTitle)) {
        feature.setChecked = true;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text("Edit space features"),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset("assets/logo/app_icon.png"),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: const [
                Text(
                  "Update parking space features",
                  style: TextStyle(
                    fontSize: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Features(
              features: featuresItems,
              key: _featuresState,
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.save,
        ),
        onPressed: () async {
          widget.space.setFeatures =
              _featuresState.currentState!.getSelectedFeatures;

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => WillPopScope(
              onWillPop: () async => false,
              child: const NoticeDialog(
                imageLink: "assets/logo/lets-park-logo.png",
                message: "We are now updating the parking space. Please wait.",
                forLoading: true,
              ),
            ),
          );

          await Future.delayed(const Duration(seconds: 1));

          ParkingSpaceServices.updateSpaceFeatures(
            widget.space.getSpaceId!,
            _featuresState.currentState!.getSelectedFeatures,
          );

          Navigator.pop(context);
          Navigator.pop(context, widget.space);
        },
      ),
    );
  }
}
