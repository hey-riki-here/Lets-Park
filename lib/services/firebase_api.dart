import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:lets_park/globals/globals.dart' as globals;

class FirebaseServices {
  static Future uploadParkingSpace() async {
    int id = globals.parkinSpaceQuantity + 1;
    DateTime date = DateTime.now();
    String time = date.month.toString() +
        date.day.toString() +
        date.year.toString() +
        date.hour.toString() +
        date.minute.toString() +
        date.second.toString();

    final docUser =
        FirebaseFirestore.instance.collection('parking-spaces').doc('PS$time$id');

    await docUser.set(globals.parkingSpace.toJson());
  }

  static Future<String> uploadImage(File file, String destination) async {
    final storageRef = FirebaseStorage.instance.ref(destination);
    await storageRef.putFile(file);
    String url = "";
    await storageRef.getDownloadURL().then((value) {
      url = value;
    });
    return url;
  }
}
