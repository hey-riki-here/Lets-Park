// ignore_for_file: unused_catch_clause, empty_catches

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lets_park/globals/globals.dart' as globals;
import 'package:lets_park/shared/shared_widgets.dart';

class LocationSection extends StatefulWidget {
  const LocationSection({required Key key}) : super(key: key);

  @override
  State<LocationSection> createState() => LocationSectionState();
}

class LocationSectionState extends State<LocationSection> {
  final SharedWidget _sharedWidget = SharedWidget();
  late GoogleMapController googleMapController;
  MapType mapType = MapType.normal;
  String mapTypeAsset = "assets/icons/map-type-1.png";
  CameraPosition cameraPosition = const CameraPosition(
    zoom: 15,
    bearing: 0,
    target: LatLng(
      14.7011,
      120.9830,
    ),
  );
  final ImagePicker imagePicker = ImagePicker();
  File? valenzuelaBusinessPermit, bnCertificate, fsic, govId;
  List<File> certificates = [];
  List<XFile>? imageFileList = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sharedWidget.stepHeader("Location"),
        const SizedBox(height: 30),
        const Text(
          "Pinpoint the location of the entrance of your space",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          "(If you think the location is incorrect please double check your given address.)",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 400,
          child: Stack(
            children: [
              Material(
                elevation: 3,
                child: GoogleMap(
                  initialCameraPosition: cameraPosition,
                  mapType: mapType,
                  myLocationButtonEnabled: false,
                  compassEnabled: false,
                  rotateGesturesEnabled: false,
                  minMaxZoomPreference: const MinMaxZoomPreference(15, 20),
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                    Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer(),
                    ),
                  },
                  onMapCreated: (GoogleMapController controller) {
                    googleMapController = controller;
                  },
                  onCameraMove: (CameraPosition position) {
                    cameraPosition = position;
                  },
                  onCameraIdle: () {
                    LatLng currentLatLng = LatLng(
                        cameraPosition.target.latitude,
                        cameraPosition.target.longitude);
                    globals.latLng = currentLatLng;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Material(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      elevation: 5,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          setState(() {
                            if (mapType == MapType.normal) {
                              mapType = MapType.satellite;
                              mapTypeAsset = "assets/icons/map-type-2.png";
                            } else {
                              mapType = MapType.normal;
                              mapTypeAsset = "assets/icons/map-type-1.png";
                            }
                          });
                        },
                        child: Ink(
                          height: 40,
                          width: 40,
                          child: Center(
                            child: Image(
                              width: 30,
                              image: AssetImage(
                                mapTypeAsset,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Center(
                child: Image(
                  image: AssetImage("assets/icons/marker.png"),
                  width: 30,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        _sharedWidget.stepHeader("Business Certificates"),
        const SizedBox(height: 30),
        const Text(
          "Please provide the following certificates of your space:\n\n• Valenzuela Business Permit\n• Government ID",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          "(This will let the user know that your parking space is legal and follows parking guidelines.)",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          "Valenzuela Business Permit",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 5),
        valenzuelaBusinessPermit != null
            ? buildImage("vbp", valenzuelaBusinessPermit)
            : OutlinedButton.icon(
                onPressed: () {
                  chooseImage("vbp");
                },
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: const Text("Select from photos"),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
        const SizedBox(height: 10),
        // const Text(
        //   "BN - Certificate",
        //   style: TextStyle(
        //     fontSize: 16,
        //     fontWeight: FontWeight.w300,
        //   ),
        // ),
        // const SizedBox(height: 5),
        // bnCertificate != null ? buildImage("bnc", bnCertificate) : OutlinedButton.icon(
        //   onPressed: () {
        //     chooseImage("bnc");
        //   },
        //   icon: const Icon(Icons.add_photo_alternate_outlined),
        //   label: const Text("Select from photos"),
        //   style: ElevatedButton.styleFrom(
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(8.0),
        //     ),
        //   ),
        // ),
        // const SizedBox(height: 10),
        // const Text(
        //   "Fire Safety Inspection Certificate",
        //   style: TextStyle(
        //     fontSize: 16,
        //     fontWeight: FontWeight.w300,
        //   ),
        // ),
        // const SizedBox(height: 5),
        // fsic != null ? buildImage("fsic", fsic) : OutlinedButton.icon(
        //   onPressed: () {
        //     chooseImage("fsic");
        //   },
        //   icon: const Icon(Icons.add_photo_alternate_outlined),
        //   label: const Text("Select from photos"),
        //   style: ElevatedButton.styleFrom(
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(8.0),
        //     ),
        //   ),
        // ),
        // const SizedBox(height: 10),
        const Text(
          "Government ID",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 5),
        govId != null
            ? buildImage("govId", govId)
            : OutlinedButton.icon(
                onPressed: () {
                  chooseImage("govId");
                },
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: const Text("Select from photos"),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
      ],
    );
  }

  Future chooseImage(String imageSrc) async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (image == null) return;
      final imageTemp = File(image.path);
      if (imageSrc.compareTo("vbp") == 0) {
        setState(() => valenzuelaBusinessPermit = imageTemp);
        certificates.add(valenzuelaBusinessPermit!);
      } else {
        setState(() => govId = imageTemp);
        certificates.add(govId!);
      }
    } on Exception catch (e) {}
  }

  // void selectImages() async {
  //   final List<XFile>? selectedImages = await imagePicker.pickMultiImage();
  //   if (selectedImages!.isNotEmpty) {
  //     imageFileList!.addAll(selectedImages);
  //   }
  //   setState(() {});
  // }

  void refreshPage() {
    googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: globals.latLng),
      ),
    );
  }

  Widget buildImage(String imageSrc, File? image) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
        bottom: 8.0,
        right: 12,
      ),
      child: Stack(
        children: [
          SizedBox(
            width: 150,
            height: 150,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(image!.path),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 5,
            right: 5,
            child: GestureDetector(
              onTap: () {
                if (imageSrc.compareTo("vbp") == 0) {
                  certificates.remove(valenzuelaBusinessPermit!);
                  setState(() => valenzuelaBusinessPermit = null);
                } else {
                  certificates.remove(govId!);
                  setState(() => govId = null);
                }
              },
              child: Container(
                alignment: Alignment.center,
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Text(
                  "✕",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<File>? get getImageFiles => certificates;
}

// Wrap(
//           children: imageFileList!
//               .map(
//                 (image) => Padding(
//                   padding: const EdgeInsets.only(
//                     top: 8.0,
//                     bottom: 8.0,
//                     right: 12,
//                   ),
//                   child: Stack(
//                     children: [
//                       SizedBox(
//                         width: 150,
//                         height: 150,
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(8),
//                           child: Image.file(
//                             File(image.path),
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       ),
//                       Positioned(
//                         top: 5,
//                         right: 5,
//                         child: GestureDetector(
//                           onTap: (){
//                             setState(() {
//                               imageFileList!.remove(image);
//                             });
//                           },
//                           child: Container(
//                             alignment: Alignment.center,
//                             width: 30,
//                             height: 30,
//                             decoration: BoxDecoration(
//                               color: Colors.grey.shade300,
//                               borderRadius: BorderRadius.circular(50),
//                             ),
//                             child: const Text(
//                               "✕",
//                               style: TextStyle(
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               )
//               .toList(),
//         ),
