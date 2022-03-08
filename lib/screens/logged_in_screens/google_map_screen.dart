// ignore_for_file: unused_catch_clause, empty_catches

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:lets_park/main.dart';
import 'package:lets_park/screens/popups/notice_dialog.dart';
import 'package:location/location.dart';

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({Key? key}) : super(key: key);

  @override
  _GoogleMapState createState() => _GoogleMapState();
}

class _GoogleMapState extends State<GoogleMapScreen> {
  final double mapMinZoom = 15, mapMaxZoom = 18;
  final Completer<GoogleMapController> _controller = Completer();
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: cameraPosition,
        myLocationEnabled: locationEnabled,
        myLocationButtonEnabled: false,
        compassEnabled: false,
        rotateGesturesEnabled: false,
        zoomControlsEnabled: false,
        minMaxZoomPreference: const MinMaxZoomPreference(15, 18),
        onMapCreated: (GoogleMapController controller) async {
          _controller.complete(controller);
          googleMapController = controller;
        },
      ),
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

    Location location = Location();

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
}
