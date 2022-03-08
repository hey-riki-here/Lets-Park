// ignore_for_file: unused_catch_clause, empty_catches

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lets_park/globals/globals.dart' as globals;
import 'package:lets_park/screens/drawer_screens/register_screens/address_step.dart';
import 'package:lets_park/screens/drawer_screens/register_screens/location_section.dart';
import 'package:lets_park/shared/shared_widgets.dart';

class RegisterArea extends StatefulWidget {
  final int _pageId = 5;
  const RegisterArea({Key? key}) : super(key: key);

  @override
  State<RegisterArea> createState() => _RegisterAreaState();
}

class _RegisterAreaState extends State<RegisterArea> {
  final SharedWidget _sharedWidget = SharedWidget();
  LatLng latLng = const LatLng(14.7011, 120.9830);
  int _currentStep = 0;
  final GlobalKey<LocationSectionState> _locationState = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        title: const Text(
          "Rent out your space",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: Theme(
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: Stepper(
          elevation: 1,
          controlsBuilder: (BuildContext context, ControlsDetails details) =>
              _buildControls(
            context,
            details,
          ),
          steps: _steps(),
          type: StepperType.horizontal,
          currentStep: _currentStep,
          onStepContinue: () async {
            setState(() {
              if (_currentStep < _steps().length - 1) {
                if (_currentStep == 0) {
                  getCoordinatesAndRefresh();
                }
                _currentStep += 1;
              } else {
                //TODO
              }
            });
          },
          onStepCancel: () {
            setState(() {
              if (_currentStep > 0) {
                _currentStep -= 1;
              } else {
                _currentStep = 0;
              }
            });
          },
        ),
      ),
    );
  }

  List<Step> _steps() => <Step>[
        Step(
          title: const Text("Address"),
          content: const AddressSection(),
          isActive: _currentStep >= 0,
        ),
        Step(
          title: const Text("Location"),
          content: LocationSection(key: _locationState),
          isActive: _currentStep >= 1,
        ),
        Step(
          title: const Text("Info and Features"),
          content: Container(
            color: Colors.green,
            width: 500,
            height: 800,
          ),
          isActive: _currentStep >= 2,
        ),
      ];

  Widget _buildControls(BuildContext context, ControlsDetails details) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: details.onStepCancel,
            child: Row(
              children: const [
                Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black45,
                  size: 18,
                ),
                Text(
                  "Back",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ),
          _sharedWidget.button(
            label: "Continue",
            onPressed: () {
              details.onStepContinue!();
            },
          ),
        ],
      );

  Future getCoordinates(String street, String barangay) async {
    try {
      List<Location> locations = await locationFromAddress(
        street + ", " + barangay + ", Valenzuela",
      );
      globals.latLng =
          LatLng(locations.first.latitude, locations.first.longitude);
      print(globals.latLng);
    } on Exception catch (e) {
      print("Error");
    }
  }

  void getCoordinatesAndRefresh() async {
    await getCoordinates(
      globals.globalStreet.text.trim(),
      globals.globalBarangay,
    );
    _locationState.currentState!.refreshPage();
  }
}
