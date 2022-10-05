// ignore_for_file: unused_catch_clause, empty_catches, avoid_function_literals_in_foreach_calls

import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:lets_park/main.dart';
import 'package:lets_park/models/parking_space.dart';
import 'package:lets_park/screens/popups/notice_dialog.dart';
import 'package:lets_park/services/firebase_api.dart';
import 'package:location/location.dart' as locationlib;

class GoogleMapScreen extends StatefulWidget {
  final Function notifyParent;
  const GoogleMapScreen({
    Key? key,
    required this.notifyParent,
  }) : super(key: key);

  @override
  State<GoogleMapScreen> createState() => GoogleMapScreenState();
}

class GoogleMapScreenState extends State<GoogleMapScreen> {
  final double mapMinZoom = 15, mapMaxZoom = 18;
  final Completer<GoogleMapController> _controller = Completer();
  final FirebaseServices _firebaseServices = FirebaseServices();
  List<ParkingSpace> spaces = [];
  Set<Marker> markers = {};
  GoogleMapController? googleMapController;
  geolocator.Position? position;
  bool locationEnabled = true;
  CameraPosition cameraPosition = const CameraPosition(
    zoom: 15,
    bearing: 0,
    target: LatLng(
      14.7011,
      120.9830,
    ),
  );
  bool isMapLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream:
            FirebaseFirestore.instance.collection('parking-spaces').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            spaces.clear();
            snapshot.data!.docs.forEach((space) {
              spaces.add(ParkingSpace.fromJson(space.data()));
            });
            return Stack(
              children: [
                FutureBuilder<Set<Marker>>(
                  future: getMarkers(),
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<Set<Marker>> snapshot,
                  ) {
                    if (snapshot.hasData) {
                      return GoogleMap(
                        initialCameraPosition: cameraPosition,
                        myLocationEnabled: locationEnabled,
                        markers: snapshot.data!,
                        myLocationButtonEnabled: false,
                        compassEnabled: false,
                        rotateGesturesEnabled: false,
                        zoomControlsEnabled: false,
                        mapToolbarEnabled: false,
                        minMaxZoomPreference: const MinMaxZoomPreference(
                          15,
                          22,
                        ),
                        onMapCreated: (GoogleMapController controller) async {
                          _controller.complete(controller);
                          googleMapController = controller;
                          changeMapMode(googleMapController!);
                          widget.notifyParent();
                          setState(() {
                            isMapLoading = false;
                          });
                        },
                      );
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
                isMapLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              "Loading map please wait.",
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            SizedBox(height: 10),
                            CircularProgressIndicator(),
                          ],
                        ),
                      )
                    : const SizedBox(),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Future<Set<Marker>> getMarkers() async {
    final markers = await _firebaseServices
        .getMarkers(context, spaces)
        .then((markers) => markers);
    return markers;
  }

  void getLocation(BuildContext context) async {
    locationlib.Location location = locationlib.Location();

    bool _serviceEnabled;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const NoticeDialog(
          imageLink: "assets/icons/marker.png",
          message: "Please wait while we are locating your current location...",
          forLoading: true,
        ),
      );

      position = await geolocator.Geolocator().getCurrentPosition(
          desiredAccuracy: geolocator.LocationAccuracy.high);
      googleMapController = await _controller.future;
      googleMapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position!.latitude, position!.longitude),
            zoom: 16.5,
          ),
        ),
      );
      navigatorKey.currentState!.popUntil((route) => route.isFirst);

      setState(() {
        locationEnabled = true;
      });
    }
  }

  void goToLocation(String location) async {
    List<geocoding.Location> locations = await locationFromAddress(
      location,
    );

    googleMapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(locations.first.latitude, locations.first.longitude),
        ),
      ),
    );
  }

  void focusMapOnLocation(LatLng location) {
    googleMapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(location.latitude, location.longitude),
        ),
      ),
    );
  }

  //this is the function to load custom map style json
  void changeMapMode(GoogleMapController mapController) {
    getJsonFile("assets/map_style.json")
        .then((value) => setMapStyle(value, mapController));
  }

  //helper function
  void setMapStyle(String mapStyle, GoogleMapController mapController) {
    mapController.setMapStyle(mapStyle);
  }

  //helper function
  Future<String> getJsonFile(String path) async {
    ByteData byte = await rootBundle.load(path);
    var list = byte.buffer.asUint8List(byte.offsetInBytes, byte.lengthInBytes);
    return utf8.decode(list);
  }
}
