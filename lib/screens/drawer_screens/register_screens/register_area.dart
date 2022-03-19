// ignore_for_file: unused_catch_clause, empty_catches

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lets_park/globals/globals.dart' as globals;
import 'package:lets_park/main.dart';
import 'package:lets_park/models/parking_space.dart';
import 'package:lets_park/screens/drawer_screens/manage_space/manage_space.dart';
import 'package:lets_park/screens/drawer_screens/register_screens/address_step.dart';
import 'package:lets_park/screens/drawer_screens/register_screens/info_and_features.dart';
import 'package:lets_park/screens/drawer_screens/register_screens/location_section.dart';
import 'package:lets_park/screens/popups/notice_dialog.dart';
import 'package:lets_park/services/firebase_api.dart';
import 'package:lets_park/shared/shared_widgets.dart';

class RegisterArea extends StatefulWidget {
  const RegisterArea({Key? key}) : super(key: key);

  @override
  State<RegisterArea> createState() => _RegisterAreaState();
}

class _RegisterAreaState extends State<RegisterArea> {
  final SharedWidget _sharedWidget = SharedWidget();
  LatLng latLng = const LatLng(14.7011, 120.9830);
  int _currentStep = 0;
  final GlobalKey<LocationSectionState> _locationState = GlobalKey();
  final GlobalKey<AddressSectionState> _addressState = GlobalKey();
  final GlobalKey<InfoAndFeaturesState> _informationState = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _showDialog(
          imageLink: "assets/icons/marker.png",
          message: "Are you want to cancel renting out your space?",
          forConfirmation: true,
        );

        if (globals.popWindow) {
          globals.parkingSpace = ParkingSpace();
        }
        return globals.popWindow;
      },
      child: Scaffold(
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
                if (_currentStep == _steps().length - 1) {
                  if (_informationState.currentState!.getFormKey.currentState!
                      .validate()) {
                    globals.parkingSpace.setCapacity =
                        _informationState.currentState!.getCapacity;

                    globals.parkingSpace.setInfo =
                        _informationState.currentState!.getInfo;

                    globals.parkingSpace.setVerticalClearance =
                        _informationState.currentState!.getVerticalClearance;

                    globals.parkingSpace.setType =
                        _informationState.currentState!.getType;

                    globals.parkingSpace.setFeatures =
                        _informationState.currentState!.getSelectedFeatures;

                    globals.parkingSpace.setOwnerId =
                        FirebaseAuth.instance.currentUser!.uid;

                    uploadParkingSpace(context);
                  }
                }

                if (_currentStep == 1) {
                  globals.parkingSpace.setLatLng = globals.latLng;
                }

                if (_currentStep < _steps().length - 1) {
                  if (_currentStep == 0) {
                    if (_addressState.currentState!.getImage == null) {
                      _showDialog(
                        imageLink: "assets/icons/marker.png",
                        message:
                            "Please provide the entrance image of your parking space.",
                      );
                    } else {
                      if (_addressState.currentState!.getFormKey.currentState!
                          .validate()) {
                        globals.parkingSpace.setAddress =
                            globals.globalStreet.text.trim() +
                                ", " +
                                globals.globalBarangay +
                                ", Valenzuela";
                        getCoordinatesAndRefresh();
                        _currentStep += 1;
                      }
                    }
                  } else {
                    _currentStep += 1;
                  }
                } else {
                  // ignore: todo
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
      ),
    );
  }

  List<Step> _steps() => <Step>[
        Step(
          title: const Text("Address"),
          content: AddressSection(key: _addressState),
          isActive: _currentStep >= 0,
        ),
        Step(
          title: const Text("Location"),
          content: LocationSection(key: _locationState),
          isActive: _currentStep >= 1,
        ),
        Step(
          title: const Text("Info and Features"),
          content: InfoAndFeatures(key: _informationState),
          isActive: _currentStep >= 2,
        ),
      ];

  Widget _buildControls(BuildContext context, ControlsDetails details) {
    if (_currentStep == 0) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _sharedWidget.button(
            label: "Continue",
            onPressed: () {
              details.onStepContinue!();
            },
          ),
        ],
      );
    } else {
      return Row(
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
    }
  }

  Future getCoordinates(String street, String barangay) async {
    try {
      List<Location> locations = await locationFromAddress(
        street + ", " + barangay + ", Valenzuela",
      );
      globals.latLng =
          LatLng(locations.first.latitude, locations.first.longitude);
    } on Exception catch (e) {}
  }

  void getCoordinatesAndRefresh() async {
    await getCoordinates(
      globals.globalStreet.text.trim(),
      globals.globalBarangay,
    );
    _locationState.currentState!.refreshPage();
  }

  Future _showDialog(
      {required String imageLink,
      required String message,
      bool? forConfirmation = false}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return NoticeDialog(
          imageLink: imageLink,
          message: message,
          forConfirmation: forConfirmation!,
        );
      },
    );
  }

  String generateFilename() {
    int id = globals.parkinSpaceQuantity + 1;
    DateTime date = DateTime.now();
    String time = date.month.toString() +
        date.day.toString() +
        date.year.toString() +
        date.hour.toString() +
        date.minute.toString() +
        date.second.toString();
    String filename = globals.globalStreet.text +
        "-" +
        globals.globalBarangay +
        "-PS$time$id";
    return filename.toLowerCase();
  }

  void uploadParkingSpace(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: const NoticeDialog(
          imageLink: "assets/logo/lets-park-logo.png",
          message: "We are now uploading your parking space information...",
          forLoading: true,
        ),
      ),
    );

    await FirebaseServices.uploadImage(
      _addressState.currentState!.getImage!,
      "parking-area-images/" + generateFilename(),
    ).then((url) {
      globals.parkingSpace.setImageUrl = url;
    });

    await FirebaseServices.uploadParkingSpace();

    navigatorKey.currentState!.popUntil((route) => route.isFirst);

    Navigator.push(context,
        MaterialPageRoute(builder: ((context) => const ManageSpace())));
  }
}
