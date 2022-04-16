// ignore_for_file: empty_catches, avoid_function_literals_in_foreach_calls

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lets_park/globals/globals.dart' as globals;
import 'package:lets_park/models/parking.dart';
import 'package:lets_park/models/parking_space.dart';

class ParkingSpaceServices {
  static void updateParkingSpaceData(
    ParkingSpace space,
    Parking parking,
  ) async {
    final docUser = FirebaseFirestore.instance
        .collection('parking-spaces')
        .doc(space.getSpaceId)
        .collection("parking-sessions")
        .doc(parking.getParkingId);

    await docUser.set(parking.toJson());
  }

  static Future<bool> isParkingSpaceAvailableAtTimeRange(
    String? id,
    int? arrival,
    int? departure,
  ) async {
    bool isAvailable = false;
    DateTime selectedArrival = _getDateTimeFromMillisecondsFromEpoch(arrival!);
    DateTime selectedDeparture =
        _getDateTimeFromMillisecondsFromEpoch(departure!);
    List<Parking> sessions = [];
    await FirebaseFirestore.instance
        .collection('parking-spaces')
        .doc(id)
        .collection("parking-sessions")
        .get()
        .then((value) => value.docs.forEach((element) {
              sessions.add(Parking.fromJson(element.data()));
            }));
    if (sessions.isNotEmpty) {
      sessions.sort((sessionA, sessionB) {
        int sessionTimeA = sessionA.getArrival! + sessionA.getDeparture!;
        int sessionTimeB = sessionB.getArrival! + sessionB.getDeparture!;

        var r = sessionTimeA.compareTo(sessionTimeB);
        if (r != 0) return r;
        return sessionTimeA.compareTo(sessionTimeB);
      });

      for (int i = 0; i < sessions.length; i++) {
        DateTime arrival =
            _getDateTimeFromMillisecondsFromEpoch(sessions[i].getArrival!);
        DateTime departure =
            _getDateTimeFromMillisecondsFromEpoch(sessions[i].getDeparture!);

        if (selectedArrival.compareTo(arrival) == 0 &&
            selectedDeparture.compareTo(departure) == 0) {
          isAvailable = false;
          break;
        } else if (selectedArrival.compareTo(arrival) == -1 &&
            selectedDeparture.compareTo(departure) == -1 &&
            selectedDeparture.compareTo(arrival) == -1) {
          isAvailable = true;
          break;
        } else if (selectedArrival.compareTo(arrival) == 1 &&
            selectedDeparture.compareTo(departure) == 1 &&
            selectedArrival.compareTo(departure) == 1) {
          isAvailable = true;
        } else {
          isAvailable = false;
          break;
        }
      }
    } else {
      isAvailable = true;
    }
    return isAvailable;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getParkingSessionsDocs(
      String spaceId) {
    return FirebaseFirestore.instance
        .collection('parking-spaces')
        .doc(spaceId)
        .collection('parking-sessions')
        .snapshots();
  }

  static DateTime _getDateTimeFromMillisecondsFromEpoch(int time) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(time);
    dateTime = DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      dateTime.minute,
    );

    return dateTime;
  }
}
