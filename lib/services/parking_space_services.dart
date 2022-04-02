// ignore_for_file: empty_catches

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lets_park/models/parking.dart';
import 'package:lets_park/models/parking_space.dart';

class ParkingSpaceServices {
  static void updateParkingSpaceData(
      ParkingSpace space, Parking parking) async {
    final docUser = FirebaseFirestore.instance
        .collection('parking-spaces')
        .doc(space.getSpaceId);

    List<dynamic> newParkingSession = [];
    newParkingSession.add(
      parking.toJson(),
    );
    await docUser
        .update({'parkingSessions': FieldValue.arrayUnion(newParkingSession)});
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
    await FirebaseFirestore.instance
        .collection('parking-spaces')
        .doc(id)
        .get()
        .then((snapshot) {
      List sessions = snapshot.data()!["parkingSessions"];

      if (sessions.isNotEmpty) {
        sessions.sort((sessionA, sessionB) {
          int sessionTimeA = sessionA["arrival"] + sessionA["departure"];
          int sessionTimeB = sessionB["arrival"] + sessionB["departure"];

          var r = sessionTimeA.compareTo(sessionTimeB);
          if (r != 0) return r;
          return sessionTimeA.compareTo(sessionTimeB);
        });

        for (int i = 0; i < sessions.length; i++) {
          DateTime arrival =
              _getDateTimeFromMillisecondsFromEpoch(sessions[i]["arrival"]);
          DateTime departure =
              _getDateTimeFromMillisecondsFromEpoch(sessions[i]["departure"]);

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
            //break;
          } else {
            isAvailable = false;
            break;
          }
        }
      } else {
        isAvailable = true;
      }
    });

    return isAvailable;
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
