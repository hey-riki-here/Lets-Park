// ignore_for_file: unused_catch_clause, empty_catches, avoid_function_literals_in_foreach_calls

import 'dart:io';

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
  bool isAgreed = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _showDialog(
          imageLink: "assets/icons/marker.png",
          message: "Do you want to cancel renting out your space?",
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
                  bool valid = true;

                  if (!_informationState.currentState!.getFormKey.currentState!
                      .validate()) {
                    valid = false;
                  }

                  if (!_informationState
                      .currentState!.getPaypalFormKey.currentState!
                      .validate()) {
                    valid = false;
                  }
                  if (valid) {
                    globals.parkingSpace.setCapacity = 10;

                    globals.parkingSpace.setRating = 0;

                    globals.parkingSpace.setInfo =
                        _informationState.currentState!.getInfo;

                    globals.parkingSpace.setVerticalClearance = 0;

                    globals.parkingSpace.setDailyOrMonthly =
                        _informationState.currentState!.getDailyOrMonthly;

                    globals.parkingSpace.setType =
                        _informationState.currentState!.getReservability;

                    globals.parkingSpace.setFeatures =
                        _informationState.currentState!.getSelectedFeatures;

                    globals.parkingSpace.setRules =
                        _informationState.currentState!.getRules;

                    globals.parkingSpace.setPaypalEmail =
                        _informationState.currentState!.getPaypalEmail;

                    globals.parkingSpace.setOwnerId =
                        FirebaseAuth.instance.currentUser!.uid;

                    globals.parkingSpace.setOwnerName =
                        FirebaseAuth.instance.currentUser!.displayName;

                    showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return StatefulBuilder(
                          builder: (context, setState) => AlertDialog(
                            title: const Text(
                              "Parking Guidelines",
                              style: TextStyle(fontSize: 24.0),
                            ),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            contentPadding: const EdgeInsets.only(top: 10.0),
                            content: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 16,
                                    bottom: 50,
                                    right: 16,
                                    left: 16,
                                  ),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: const [
                                        Text(
                                          "Title here",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                        Text(
                                          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. In suscipit vel augue eget varius. Integer sit amet porta augue. Vestibulum lacinia hendrerit mi. Quisque ac elementum enim, quis scelerisque orci. Donec non quam mauris. Suspendisse potenti. Vestibulum dignissim tempor lobortis. Ut est lectus, dictum vitae pharetra et, vestibulum scelerisque ligula. Nulla pretium, dolor vel auctor iaculis, est augue ornare ex, in cursus tellus risus ut nisl. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos.",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w300,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          "Title here",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                        Text(
                                          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. In suscipit vel augue eget varius. Integer sit amet porta augue. Vestibulum lacinia hendrerit mi. Quisque ac elementum enim, quis scelerisque orci. Donec non quam mauris. Suspendisse potenti. Vestibulum dignissim tempor lobortis. Ut est lectus, dictum vitae pharetra et, vestibulum scelerisque ligula. Nulla pretium, dolor vel auctor iaculis, est augue ornare ex, in cursus tellus risus ut nisl. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos.",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w300,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          "Title here",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                        Text(
                                          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. In suscipit vel augue eget varius. Integer sit amet porta augue. Vestibulum lacinia hendrerit mi. Quisque ac elementum enim, quis scelerisque orci. Donec non quam mauris. Suspendisse potenti. Vestibulum dignissim tempor lobortis. Ut est lectus, dictum vitae pharetra et, vestibulum scelerisque ligula. Nulla pretium, dolor vel auctor iaculis, est augue ornare ex, in cursus tellus risus ut nisl. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos.",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w300,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          "Title here",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                        Text(
                                          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. In suscipit vel augue eget varius. Integer sit amet porta augue. Vestibulum lacinia hendrerit mi. Quisque ac elementum enim, quis scelerisque orci. Donec non quam mauris. Suspendisse potenti. Vestibulum dignissim tempor lobortis. Ut est lectus, dictum vitae pharetra et, vestibulum scelerisque ligula. Nulla pretium, dolor vel auctor iaculis, est augue ornare ex, in cursus tellus risus ut nisl. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos.",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w300,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          "Title here",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                        Text(
                                          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. In suscipit vel augue eget varius. Integer sit amet porta augue. Vestibulum lacinia hendrerit mi. Quisque ac elementum enim, quis scelerisque orci. Donec non quam mauris. Suspendisse potenti. Vestibulum dignissim tempor lobortis. Ut est lectus, dictum vitae pharetra et, vestibulum scelerisque ligula. Nulla pretium, dolor vel auctor iaculis, est augue ornare ex, in cursus tellus risus ut nisl. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos.",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w300,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          "Title here",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                        Text(
                                          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. In suscipit vel augue eget varius. Integer sit amet porta augue. Vestibulum lacinia hendrerit mi. Quisque ac elementum enim, quis scelerisque orci. Donec non quam mauris. Suspendisse potenti. Vestibulum dignissim tempor lobortis. Ut est lectus, dictum vitae pharetra et, vestibulum scelerisque ligula. Nulla pretium, dolor vel auctor iaculis, est augue ornare ex, in cursus tellus risus ut nisl. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos.",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w300,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: isAgreed,
                                        onChanged: (value) {
                                          setState(() {
                                            isAgreed = value!;
                                          });
                                        },
                                      ),
                                      const Text(
                                        "I have read the Parking Guidelines thoroughly.",
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                style: TextButton.styleFrom(
                                  primary: Colors.black54,
                                ),
                                onPressed: () {
                                  Navigator.pop(context, false);
                                  isAgreed = false;
                                },
                                child: const Text('Cancel'),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  right: 10,
                                ),
                                child: ElevatedButton(
                                  onPressed: isAgreed
                                      ? () {
                                          Navigator.pop(context, true);
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.blue.shade800,
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    "Proceed",
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ).then((proceed) {
                      if (proceed != null && proceed) {
                        uploadParkingSpace(context);
                      }
                    });
                  }
                }

                if (_currentStep == 1) {
                  globals.parkingSpace.setLatLng = globals.latLng;
                }

                if (_currentStep < _steps().length - 1) {
                  if (_currentStep == 0) {
                    if (_addressState.currentState!.getSpaceImage == null) {
                      _showDialog(
                        imageLink: "assets/icons/marker.png",
                        message:
                            "Please provide the entrance image of your parking space.",
                      );
                      return;
                    }

                    if (_addressState.currentState!.getCaretakerImage == null) {
                      _showDialog(
                        imageLink: "assets/icons/marker.png",
                        message:
                            "Please provide photo of your parking space's caretaker.",
                      );
                      return;
                    }

                    bool valid = false;

                    if (_addressState
                        .currentState!.getAddressFormKey.currentState!
                        .validate()) {
                      valid = true;
                    } else {
                      return;
                    }

                    if (_addressState
                        .currentState!.getCaretakerFormKey.currentState!
                        .validate()) {
                      valid = true;
                    } else {
                      return;
                    }

                    if (valid) {
                      globals.parkingSpace.setAddress =
                          globals.globalStreet.text.trim() +
                              ", " +
                              globals.globalBarangay +
                              ", Valenzuela";
                      globals.parkingSpace.setCaretakerName =
                          _addressState.currentState!.getCaretakerName;
                      globals.parkingSpace.setCaretakerPhoneNumber =
                          _addressState.currentState!.getCaretakerPhoneNumber;
                      getCoordinatesAndRefresh();
                      _currentStep += 1;
                    }
                  } else if (_currentStep == 1) {
                    if (_locationState.currentState!.getImageFiles!.length ==
                        1) {
                      _showDialog(
                        imageLink: "assets/icons/marker.png",
                        message:
                            "Please provide the required business certificates.",
                      );
                      return;
                    }

                    if (_locationState.currentState!.getImageFiles!.isEmpty) {
                      _showDialog(
                        imageLink: "assets/icons/marker.png",
                        message: "Please provide business certificates.",
                      );
                      return;
                    }

                    _currentStep += 1;
                  } else {
                    _currentStep += 1;
                  }
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
      _addressState.currentState!.getSpaceImage!,
      "parking-area-images/" + generateFilename(),
    ).then((url) {
      globals.parkingSpace.setImageUrl = url;
    });

    await FirebaseServices.uploadImage(
      _addressState.currentState!.getCaretakerImage!,
      "avatar/" +
          _addressState.currentState!.getCaretakerImage!.path.split('/').last,
    ).then((url) {
      globals.parkingSpace.setCaretakerPhotoUrl = url;
    });

    await FirebaseServices.uploadFiles(
      _locationState.currentState!.getImageFiles!,
    ).then((urls) {
      globals.parkingSpace.setCertificates = urls;
    });

    await FirebaseServices.uploadParkingSpace();

    navigatorKey.currentState!.popUntil((route) => route.isFirst);

    Navigator.push(context,
        MaterialPageRoute(builder: ((context) => const ManageSpace())));
  }
}
