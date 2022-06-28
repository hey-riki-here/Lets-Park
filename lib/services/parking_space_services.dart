// ignore_for_file: empty_catches, avoid_function_literals_in_foreach_calls

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:lets_park/main.dart';
import 'package:lets_park/models/parking.dart';
import 'package:lets_park/models/parking_space.dart';
import 'package:lets_park/models/review.dart';
import 'package:lets_park/screens/popups/notice_dialog.dart';

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

  static void updateParkingReviews(
    String spaceId,
    Review review,
  ) async {
    final docUser = FirebaseFirestore.instance
        .collection('parking-spaces')
        .doc(spaceId)
        .collection("parking-reviews")
        .doc();

    await docUser.set(review.toJson());
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getParkingSpaceReviews(
      String spaceId) {
    return FirebaseFirestore.instance
        .collection('parking-spaces')
        .doc(spaceId)
        .collection('parking-reviews')
        .snapshots();
  }

  static void updateParkingSpaceRating(
    String spaceId,
    double newRating,
    BuildContext context,
  ) async {
    int reviewsLength = 0;
    final Map<double, double> rates = {
      1: 0,
      2: 0,
      3: 0,
      4: 0,
      5: 0,
    };
    double value = 0;
    var reviews = FirebaseFirestore.instance
        .collection('parking-spaces')
        .doc(spaceId)
        .collection('parking-reviews')
        .snapshots();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: const NoticeDialog(
          imageLink: "assets/logo/lets-park-logo.png",
          message: "Saving review...",
          forLoading: true,
        ),
      ),
    );
    await reviews.forEach((documents) async {
      reviewsLength = documents.size;
      documents.docs.forEach((element) {
        value = rates[element.data()["rating"]]!;
        rates[element.data()["rating"]] = value + 1;
      });
      value = rates[newRating]!;
      rates[newRating] = value + 1;
      double newSpaceRating = ((1 * rates[1]!) +
              (2 * rates[2]!) +
              (3 * rates[3]!) +
              (4 * rates[4]!) +
              (5 * rates[5]!)) /
          (reviewsLength + 1);

      await FirebaseFirestore.instance
          .collection('parking-spaces')
          .doc(spaceId)
          .update({
        'rating': newSpaceRating,
      });
      navigatorKey.currentState!.popUntil((route) => route.isFirst);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: const NoticeDialog(
            imageLink: "assets/logo/lets-park-logo.png",
            message:
                "Thanks for reviewing!\nYour review will help others to choose a better parking.",
            forLoading: false,
          ),
        ),
      );
    });
  }

  static Row getStars(double stars) {
    List<Widget> newChildren = [];
    double length = stars;
    Color? color = Colors.amber;

    if (stars == 0) {
      length = 5;
      color = Colors.grey[400];
    }

    for (int i = 0; i < length.toInt(); i++) {
      newChildren.add(
        Icon(
          Icons.star_rounded,
          color: color,
          size: 16,
        ),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: newChildren,
    );
  }
}
