// ignore_for_file: unused_catch_clause, empty_catches

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:lets_park/main.dart';
import 'package:lets_park/models/parking_space.dart';
import 'package:lets_park/screens/popups/notice_dialog.dart';
import 'package:lets_park/screens/popups/parking_area_info.dart';
import 'package:location/location.dart' as locationlib;
import 'package:lets_park/globals/globals.dart' as globals;

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({Key? key}) : super(key: key);

  @override
  State<GoogleMapScreen> createState() => GoogleMapScreenState();
}

class GoogleMapScreenState extends State<GoogleMapScreen> {
  final double mapMinZoom = 15, mapMaxZoom = 18;
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> markers = Set();
  List<ParkingSpace> ownedSpaces = [];
  late Stream<List<ParkingSpace>> spaces;
  GoogleMapController? googleMapController;
  geolocator.Position? position;
  bool locationEnabled = false;
  CameraPosition cameraPosition = const CameraPosition(
    zoom: 15,
    bearing: 0,
    target: LatLng(
      14.7011,
      120.9830,
    ),
  );

  @override
  void initState() {
    getParkingSpacesFromDatabase();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<ParkingSpace>>(
          stream: getParkingSpacesFromDatabase(),
          builder: (context, snapshot) {
            ownedSpaces.clear();
            if (snapshot.hasData) {
              // ignore: avoid_function_literals_in_foreach_calls
              snapshot.data!.forEach((parkingSpace) {
                if (parkingSpace.getOwnerId!
                        .compareTo(FirebaseAuth.instance.currentUser!.uid) ==
                    0) {
                  ownedSpaces.add(parkingSpace);
                }
              });
              globals.appUser.setOwnedParkingSpaces = ownedSpaces;
              return GoogleMap(
                initialCameraPosition: cameraPosition,
                myLocationEnabled: locationEnabled,
                markers: getMarkers(),
                myLocationButtonEnabled: false,
                compassEnabled: false,
                rotateGesturesEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                minMaxZoomPreference: const MinMaxZoomPreference(15, 18),
                onMapCreated: (GoogleMapController controller) async {
                  _controller.complete(controller);
                  googleMapController = controller;
                },
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        child: const Icon(
          Icons.location_searching,
          color: Colors.black,
        ),
        onPressed: () async {
          try {
            getLocation(context);
          } on Exception catch (e) {}
        },
      ),
    );
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
      print(position);
      navigatorKey.currentState!.popUntil((route) => route.isFirst);

      setState(() {
        locationEnabled = true;
      });
    }
  }

  Stream<List<ParkingSpace>> getParkingSpacesFromDatabase() {
    spaces = FirebaseFirestore.instance
        .collection('parking-spaces')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map<ParkingSpace>((doc) => ParkingSpace.fromJson(doc.data()))
            .toList());
    return spaces;
  }

  Set<Marker> getMarkers() {
    late BitmapDescriptor marker;
    getIcon().then((BitmapDescriptor value) {
      marker = value;
    });

    spaces.first.then((value) {
      globals.parkinSpaceQuantity = value.length;
      // ignore: avoid_function_literals_in_foreach_calls
      value.forEach((parkingSpace) {
        markers.add(
          Marker(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (context) =>
                      ParkingAreaInfo(parkingSpace: parkingSpace),
                ),
              );
            },
            icon: marker,
            markerId: MarkerId(parkingSpace.getLatLng.toString()),
            position: parkingSpace.getLatLng!,
          ),
        );
      });
    });

    return markers;
  }

  Future<BitmapDescriptor> getIcon() async {
    BitmapDescriptor markerbitmap = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      "assets/icons/parking-marker.png",
    );
    return markerbitmap;
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
}
