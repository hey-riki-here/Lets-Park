// ignore_for_file: unused_catch_clause, empty_catches

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:lets_park/main.dart';
import 'package:lets_park/models/parking_space.dart';
import 'package:lets_park/screens/popups/notice_dialog.dart';
import 'package:lets_park/screens/popups/parking_area_info.dart';
import 'package:location/location.dart';
import 'package:lets_park/globals/globals.dart' as globals;

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({Key? key}) : super(key: key);

  @override
  _GoogleMapState createState() => _GoogleMapState();
}

class _GoogleMapState extends State<GoogleMapScreen> {
  final double mapMinZoom = 15, mapMaxZoom = 18;
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> markers = Set();
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
      value.forEach((parkingSpace) {
        markers.add(
          Marker(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (context) =>  ParkingAreaInfo(parkingSpace: parkingSpace),
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
}
