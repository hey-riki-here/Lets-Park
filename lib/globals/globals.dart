// ignore_for_file: unused_catch_clause, empty_catches

library lets_park.globals;

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lets_park/models/parking.dart';
import 'package:lets_park/models/user_data.dart';
import 'package:lets_park/models/parking_space.dart';

TextEditingController globalStreet = TextEditingController();
String globalBarangay = "";
LatLng latLng = const LatLng(14.7011, 120.9830);
bool popWindow = false;
ParkingSpace parkingSpace = ParkingSpace();
List<ParkingSpace> currentParkingSpaces = [];
int parkinSpaceQuantity = 0;
UserData userData = UserData();
bool subscribeToStream = true;
List<Parking> inProgressParkings = [];
Map<String, List<Parking>> parkingSession = {};
bool updateState = false;
late StreamSubscription sub;
bool goCheck = true;
bool goCheckOwnedSpaces = false;
ParkingSpace nonReservable = ParkingSpace();
String selectedType = "Daily";
List<String> favorites = [];
LatLng parkingLoc = const LatLng(0, 0);
int today = 0;
List<String> certificates = [];
