import 'dart:io';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ParkingSpace {
  final String ownerId;
  final File image;
  final String address;
  final LatLng latLng;
  final int capacity;
  final String info;
  final double verticalClearance;
  final String type;
  List<String> features = [];

  ParkingSpace({
    required this.ownerId,
    required this.image,
    required this.address,
    required this.latLng,
    required this.capacity,
    required this.info,
    required this.verticalClearance,
    required this.type,
    required this.features,
  });
}
