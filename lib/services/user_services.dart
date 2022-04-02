// ignore_for_file: avoid_function_literals_in_foreach_calls, unused_catch_clause

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lets_park/models/parking.dart';
import 'package:lets_park/globals/globals.dart' as globals;

class UserServices {
  static Future registerNewUserData() async {
    String id = FirebaseAuth.instance.currentUser!.uid;
    final docUser = FirebaseFirestore.instance.collection('user-data').doc(id);

    globals.userData.setUserId = id;

    await docUser.set(globals.userData.toJson());
  }

  static void updateUserParkingData(Parking parking) async {
    String docId = FirebaseAuth.instance.currentUser!.uid;
    final docUser =
        FirebaseFirestore.instance.collection('user-data').doc(docId);
    List<dynamic> newPark = [];
    newPark.add(
      parking.toJson(),
    );
    await docUser.update({'userParkings': FieldValue.arrayUnion(newPark)});
    getUserData();
  }

  static void getUserData() async {
    try {
      List<Parking>? parkings = [];
      var collection = FirebaseFirestore.instance.collection('user-data');
      var docSnapshot =
          await collection.doc(FirebaseAuth.instance.currentUser!.uid).get();
      if (docSnapshot.exists) {
        Map<String, dynamic>? data = docSnapshot.data();
        List fromDatabase = await data!['userParkings'];

        fromDatabase.forEach((data) {
          parkings.add(
            Parking(
              data['driver'],
              data['stars'],
              data['address'],
              data['plateNumber'],
              data['arrival'],
              data['departure'],
              data['duration'],
              data['price'] + 0.0,
            ),
          );
        });

        globals.userData.setParkings = parkings;
      }
    } on Exception catch (e) {
      // Some codes here
    }
  }
}
