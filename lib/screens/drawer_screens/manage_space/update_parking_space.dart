// ignore_for_file: empty_catches, unused_catch_clause

import 'dart:io';

import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lets_park/models/parking_space.dart';
import 'package:lets_park/screens/drawer_screens/manage_space/parking_space_modifier/address_modifier.dart';
import 'package:lets_park/screens/drawer_screens/manage_space/parking_space_modifier/capacity_modifier.dart';
import 'package:lets_park/screens/drawer_screens/manage_space/parking_space_modifier/caretaker_name_modifier.dart';
import 'package:lets_park/screens/drawer_screens/manage_space/parking_space_modifier/features_modifier.dart';
import 'package:lets_park/screens/drawer_screens/manage_space/parking_space_modifier/info_modifier.dart';
import 'package:lets_park/screens/drawer_screens/manage_space/parking_space_modifier/paypal_modifier.dart';
import 'package:lets_park/screens/drawer_screens/manage_space/parking_space_modifier/reservability_modifier.dart';
import 'package:lets_park/screens/drawer_screens/manage_space/parking_space_modifier/rules_modifier.dart';
import 'package:lets_park/screens/popups/notice_dialog.dart';
import 'package:lets_park/services/firebase_api.dart';
import 'package:lets_park/services/parking_space_services.dart';

import 'parking_space_modifier/caretaker_number_modifier.dart';

class UpdateParkingSpace extends StatefulWidget {
  final ParkingSpace space;
  const UpdateParkingSpace({Key? key, required this.space}) : super(key: key);

  @override
  State<UpdateParkingSpace> createState() => _UpdateParkingSpaceState();
}

class _UpdateParkingSpaceState extends State<UpdateParkingSpace> {
  final _textStyle = const TextStyle(
    color: Colors.black45,
  );
  late ParkingSpace space;

  @override
  void initState() {
    space = widget.space;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: const [
            Text(
              "Update Space 1",
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: SizedBox(
                  width: 120,
                  height: 80,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      space.getImageUrl!,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.red[400],
                    size: 17,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    space.getAddress!,
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.car_crash_rounded,
                    color: Colors.blue[400],
                    size: 17,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    space.getCapacity!.toString(),
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              const Text(
                "Blah blah blah",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "Parking space Information",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Colors.black26,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "DISPLAY PHOTO",
                                style: _textStyle,
                              ),
                              Text(
                                "Choose a photo for identity purposes.",
                                style: _textStyle,
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              SizedBox(
                                width: 120,
                                height: 80,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    space.getImageUrl!,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5),
                                child: TextButton(
                                  onPressed: () async {
                                    try {
                                      final image =
                                          await ImagePicker().pickImage(
                                        source: ImageSource.gallery,
                                      );
                                      if (image == null) return;
                                      final imageTemp = File(image.path);
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) => WillPopScope(
                                          onWillPop: () async => false,
                                          child: const NoticeDialog(
                                            imageLink:
                                                "assets/logo/lets-park-logo.png",
                                            message:
                                                "We are now updating the parking space. Please wait.",
                                            forLoading: true,
                                          ),
                                        ),
                                      );
                                      await ParkingSpaceServices.deleteImageUrl(
                                          space.getImageUrl!);
                                      String newUrl = "";
                                      await FirebaseServices.uploadImage(
                                        imageTemp,
                                        "parking-area-images/" +
                                            imageTemp.path.split('/').last,
                                      ).then((url) {
                                        newUrl = url;
                                      });
                                      ParkingSpaceServices.updateSpaceImageUrl(
                                        space.getSpaceId!,
                                        newUrl,
                                      );

                                      setState(() {
                                        space.setImageUrl = newUrl;
                                      });
                                      Navigator.pop(context);
                                    } on Exception catch (e) {}
                                  },
                                  child: Row(
                                    children: const [
                                      Text(
                                        "Replace",
                                        style: TextStyle(
                                          color: Colors.blue,
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Icon(
                                        Icons.camera_alt_outlined,
                                        color: Colors.blue,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 5),
                      Row(
                        children: const [
                          Text("ADDRESS"),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoField(
                            maxLines: 1,
                            value: space.getAddress!,
                            onTap: () {
                              goToPage(
                                AddressModifier(
                                  space: space,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: const [
                          Text("INFORMATION"),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildInfoField(
                        maxLines: 5,
                        value: space.getInfo!,
                        onTap: () {
                          goToPage(
                            InfoModifier(
                              space: space,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: const [
                          Text("RULES"),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildInfoField(
                        maxLines: 5,
                        value: space.getRules!,
                        onTap: () {
                          goToPage(
                            RulesModifier(
                              space: space,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: const [
                          Text("CAPACITY"),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildInfoField(
                        maxLines: 1,
                        value: space.getCapacity!.toString(),
                        onTap: () {
                          goToPage(
                            CapacityModifier(
                              space: space,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "Caretaker",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Colors.black26,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "DISPLAY PHOTO",
                                style: _textStyle,
                              ),
                              Text(
                                "Choose a photo for identity purposes.",
                                style: _textStyle,
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.black12,
                                backgroundImage: NetworkImage(
                                  space.getCaretakerPhotoUrl!,
                                ),
                                radius: 40,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5),
                                child: TextButton(
                                  onPressed: () async {
                                    try {
                                      final image =
                                          await ImagePicker().pickImage(
                                        source: ImageSource.gallery,
                                      );
                                      if (image == null) return;
                                      final imageTemp = File(image.path);
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) => WillPopScope(
                                          onWillPop: () async => false,
                                          child: const NoticeDialog(
                                            imageLink:
                                                "assets/logo/lets-park-logo.png",
                                            message:
                                                "We are now updating the caretaker info. Please wait.",
                                            forLoading: true,
                                          ),
                                        ),
                                      );
                                      await ParkingSpaceServices.deleteImageUrl(
                                        space.getCaretakerPhotoUrl!,
                                      );
                                      String newUrl = "";
                                      await FirebaseServices.uploadImage(
                                        imageTemp,
                                        "avatar/" +
                                            imageTemp.path.split('/').last,
                                      ).then((url) {
                                        newUrl = url;
                                      });
                                      await ParkingSpaceServices
                                          .updateCaretakerPhotoUrl(
                                        space.getSpaceId!,
                                        newUrl,
                                      );

                                      setState(() {
                                        space.setCaretakerPhotoUrl = newUrl;
                                      });
                                      Navigator.pop(context);
                                    } on Exception catch (e) {}
                                  },
                                  child: Row(
                                    children: const [
                                      Text(
                                        "Replace",
                                        style: TextStyle(
                                          color: Colors.blue,
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Icon(
                                        Icons.camera_alt_outlined,
                                        color: Colors.blue,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: const [
                          Text("Name"),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildInfoField(
                        maxLines: 1,
                        value: space.getCaretakerName!,
                        onTap: () {
                          goToPage(
                            CaretakerNameModifier(
                              space: space,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: const [
                          Text("Phone number"),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildInfoField(
                        maxLines: 1,
                        value: space.getCaretakerPhoneNumber!,
                        onTap: () {
                          goToPage(
                            CaretakerNumberModifier(
                              space: space,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "Parking reservability",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Colors.black26,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        children: const [
                          Text("TYPE"),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Colors.black26,
                          ),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  buildTag(
                                    space.getDailyOrMonthly!,
                                    Colors.amber,
                                    75,
                                  ),
                                  const SizedBox(width: 10),
                                  buildTag(
                                    space.getType!,
                                    Colors.blue,
                                    110,
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  goToPage(
                                    ReservabilityModifier(
                                      space: space,
                                    ),
                                  );
                                },
                                child: const Icon(
                                  FontAwesomeIcons.pencilAlt,
                                  color: Colors.blue,
                                  size: 17,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "Features",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Colors.black26,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        children: const [
                          Text("FEATURES"),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Colors.black26,
                          ),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: getFeatures(space.getFeatures!)),
                              GestureDetector(
                                onTap: () {
                                  goToPage(
                                    FeaturesModifier(
                                      space: space,
                                    ),
                                  );
                                },
                                child: const Icon(
                                  FontAwesomeIcons.pencilAlt,
                                  color: Colors.blue,
                                  size: 17,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "Paypal Email",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Colors.black26,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        children: const [
                          Text("Paypal email"),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildInfoField(
                        maxLines: 1,
                        value: space.getPaypalEmail!,
                        onTap: () {
                          goToPage(
                            PaypalModifier(
                              space: space,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        "Please note that updating parking space information is not allowed when there are active parking sessions or the space is booked.",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextFormField _buildInfoField({
    required int maxLines,
    required String value,
    required Function()? onTap,
  }) {
    return TextFormField(
      readOnly: true,
      key: Key(value),
      initialValue: value,
      maxLines: maxLines,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        suffixIcon: GestureDetector(
          onTap: onTap,
          child: const Icon(
            FontAwesomeIcons.pencilAlt,
            color: Colors.blue,
            size: 17,
          ),
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }

  Widget buildTag(String label, Color color, double width) {
    return Container(
      width: width,
      height: 25,
      decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.all(Radius.circular(20))),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  void goToPage(Widget page) {
    Navigator.push<ParkingSpace>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: ((context) => page),
      ),
    ).then((returnedSpace) {
      if (returnedSpace != null) {
        setState(() {
          space = returnedSpace;
        });
      }
    });
  }

  Widget getFeatures(List<String> features) {
    List<Widget> newChildren = [];

    for (String feature in features) {
      if (feature.compareTo("With gate") == 0) {
        newChildren.add(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                CommunityMaterialIcons.gate,
                color: Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                feature,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 15),
            ],
          ),
        );
      } else if (feature.compareTo("CCTV") == 0) {
        newChildren.add(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                CommunityMaterialIcons.cctv,
                color: Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                feature,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 15),
            ],
          ),
        );
      } else if (feature.compareTo("Covered Parking") == 0) {
        newChildren.add(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                CommunityMaterialIcons.bus_stop_covered,
                color: Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                feature,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      } else {
        newChildren.add(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                CommunityMaterialIcons.lightbulb_on_outline,
                color: Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                feature,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      }
    }

    return Wrap(
      direction: Axis.horizontal,
      runSpacing: 10,
      children: newChildren,
    );
  }
}
