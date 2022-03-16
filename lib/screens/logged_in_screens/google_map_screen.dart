// ignore_for_file: unused_catch_clause, empty_catches

import 'dart:async';
import 'package:flutter/material.dart';
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
  const GoogleMapScreen({Key? key}) : super(key: key);

  @override
  State<GoogleMapScreen> createState() => GoogleMapScreenState();
}

class GoogleMapScreenState extends State<GoogleMapScreen> {
  final double mapMinZoom = 15, mapMaxZoom = 18;
  final Completer<GoogleMapController> _controller = Completer();
  final FirebaseServices _firebaseServices = FirebaseServices();
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
    _firebaseServices.getParkingSpacesFromDatabase();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<ParkingSpace>>(
          stream: _firebaseServices.getParkingSpacesFromDatabase(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              FirebaseServices.getOwnedParkingAreas(snapshot);
              return GoogleMap(
                initialCameraPosition: cameraPosition,
                myLocationEnabled: locationEnabled,
                markers: _firebaseServices.getMarkers(context),
                myLocationButtonEnabled: false,
                compassEnabled: false,
                rotateGesturesEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                minMaxZoomPreference: const MinMaxZoomPreference(15, 18),
                onMapCreated: (GoogleMapController controller) async {
                  _controller.complete(controller);
                  googleMapController = controller;
                  setState(() {});
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
}
