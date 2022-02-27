import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lets_park/main.dart';
import 'package:lets_park/screens/popups/notice_dialog.dart';

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({Key? key}) : super(key: key);

  @override
  _GoogleMapState createState() => _GoogleMapState();
}

class _GoogleMapState extends State<GoogleMapScreen> {
  final double mapMinZoom = 15, mapMaxZoom = 18;
  final Completer<GoogleMapController> _controller = Completer();
  final LocationSettings locSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 0,
  );
  GoogleMapController? googleMapController;
  Position? position;
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
        
          StreamSubscription<ServiceStatus> serviceStatus =
              Geolocator.getServiceStatusStream().listen(
            (ServiceStatus status) {
              if (status == ServiceStatus.enabled) {
                locationEnabled = true;
              } else {
                locationEnabled = false;
              }
              setState(() {});
            },
          );

          bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
          if (serviceEnabled) {
            StreamSubscription<Position> positionStream =
                Geolocator.getPositionStream(
              locationSettings: locSettings,
            ).listen(
              (Position? position) async {
                googleMapController = await _controller.future;
                double zoom = await googleMapController!.getZoomLevel();
                LatLngBounds bounds =
                    await googleMapController!.getVisibleRegion();

                if ((position!.latitude < bounds.northeast.latitude &&
                        position.longitude < bounds.northeast.longitude) &&
                    (position.latitude > bounds.southwest.latitude &&
                        position.longitude > bounds.southwest.longitude)) {
                  googleMapController!.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: LatLng(position.latitude, position.longitude),
                        zoom: zoom,
                      ),
                    ),
                  );
                }
              },
            );
          }
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
    bool serviceEnabled;

// Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const NoticeDialog(
          imageLink: "assets/logo/marker.png",
          message: "Please wait while we are locating your current location...",
          forLoading: true,
        ),
      );

      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
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
