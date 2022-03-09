// ignore_for_file: unused_catch_clause, empty_catches

library lets_park.globals;

import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

TextEditingController globalStreet = TextEditingController();
String globalBarangay = "";
LatLng latLng = const LatLng(14.7011, 120.9830);
bool popWindow = false;
List data = [];