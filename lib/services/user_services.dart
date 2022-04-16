// ignore_for_file: avoid_function_literals_in_foreach_calls, unused_catch_clause, empty_catches

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lets_park/models/notification.dart' as notif;
import 'package:lets_park/models/notification.dart';
import 'package:lets_park/models/parking.dart';
import 'package:lets_park/globals/globals.dart' as globals;
import 'package:lets_park/services/world_time_api.dart';

class UserServices {
  final Stream checkSessionsStream =
      Stream.periodic(const Duration(milliseconds: 1000), (int count) {
    return count;
  });

  static Future registerNewUserData() async {
    String id = FirebaseAuth.instance.currentUser!.uid;
    final docUser = FirebaseFirestore.instance.collection('user-data').doc(id);

    globals.userData.setUserId = id;

    await docUser.set(globals.userData.toJson());
  }

  static void updateUserParkingData(Parking parking) async {
    String docId = FirebaseAuth.instance.currentUser!.uid;

    final docUser = FirebaseFirestore.instance
        .collection('user-data')
        .doc(docId)
        .collection("user-parkings")
        .doc(parking.getParkingId);

    await docUser.set(parking.toJson());
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>>? getUserData() {
    return FirebaseFirestore.instance
        .collection('user-data')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? getUserParkingData() {
    return FirebaseFirestore.instance
        .collection('user-data')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('user-parkings')
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? getUserNotifications() {
    return FirebaseFirestore.instance
        .collection('user-data')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('notifications')
        .snapshots();
  }

  void distributeParkingSessions(BuildContext context) async {
    var userParkings = FirebaseFirestore.instance
        .collection('user-data')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("user-parkings");

    var parkingSessions =
        FirebaseFirestore.instance.collection('parking-spaces');

    List<Parking> parkings = globals.userData.getUserParkings!;

    try {
      DateTime now = DateTime(0, 0, 0, 0, 0);
      await WorldTimeServices.getDateTimeNow().then((time) {
        now = DateTime(
          time.year,
          time.month,
          time.day,
          time.hour,
          time.minute,
        );
      });
      for (var parking in parkings) {
        String address = parking.getAddress!;
        String time = _getFormattedTime(
            _getDateTimeFromMillisecondEpoch(parking.getArrival!));

        if ((_getDateTimeFromMillisecondEpoch(parking.getArrival!)
                        .compareTo(now) ==
                    0 ||
                _getDateTimeFromMillisecondEpoch(parking.getArrival!)
                        .compareTo(now) ==
                    -1) &&
            (_getDateTimeFromMillisecondEpoch(parking.getDeparture!)
                    .compareTo(now) ==
                1) &&
            parking.isInProgress == false) {
          await userParkings.doc(parking.getParkingId).update({
            'inProgress': true,
            'upcoming': false,
            'inHistory': false,
          }).then((_) => showNotice(
                context,
                "Your parking in $address at $time has started.",
              ));

          await parkingSessions
              .doc(parking.getParkingSpaceId)
              .collection("parking-sessions")
              .doc(parking.getParkingId)
              .update({
            'inProgress': true,
            'upcoming': false,
            'inHistory': false,
          });
        } else if (_getDateTimeFromMillisecondEpoch(parking.getArrival!)
                    .compareTo(now) ==
                1 &&
            parking.isUpcoming == false) {
          await userParkings.doc(parking.getParkingId).update({
            'inProgress': false,
            'upcoming': true,
            'inHistory': false,
          }).then((_) => print('Success (Upcoming)'));

          await parkingSessions
              .doc(parking.getParkingSpaceId)
              .collection("parking-sessions")
              .doc(parking.getParkingId)
              .update({
            'inProgress': false,
            'upcoming': true,
            'inHistory': false,
          });
        } else if ((_getDateTimeFromMillisecondEpoch(parking.getArrival!)
                        .compareTo(now) ==
                    -1 &&
                (_getDateTimeFromMillisecondEpoch(parking.getDeparture!)
                            .compareTo(now) ==
                        0 ||
                    _getDateTimeFromMillisecondEpoch(parking.getDeparture!)
                            .compareTo(now) ==
                        -1)) &&
            parking.isInHistory == false) {
          await userParkings.doc(parking.getParkingId).update({
            'inProgress': false,
            'upcoming': false,
            'inHistory': true,
          }).then((_) {
            showNotice(
              context,
              "Your parking in $address at $time has ended.",
            );
            UserServices.notifyUser(
              parking.getParkingOwner!,
              UserNotification(
                FirebaseAuth.instance.currentUser!.photoURL!,
                FirebaseAuth.instance.currentUser!.displayName!,
                "finished parking in your parking space. Give him a rate now.",
                false,
                true,
                now.millisecondsSinceEpoch,
              ),
            );

            UserServices.notifyUser(
              FirebaseAuth.instance.currentUser!.uid,
              UserNotification(
                FirebaseAuth.instance.currentUser!.photoURL!,
                FirebaseAuth.instance.currentUser!.displayName!,
                "How did the parking went? Share your thoughts now.",
                false,
                false,
                now.millisecondsSinceEpoch,
              ),
            );
          });

          await parkingSessions
              .doc(parking.getParkingSpaceId)
              .collection("parking-sessions")
              .doc(parking.getParkingId)
              .update({
            'inProgress': false,
            'upcoming': false,
            'inHistory': true,
          });
        }
      }
    } on Exception catch (e) {}
  }

  static void notifyUser(String userId, UserNotification notif) async {
    final docUser = FirebaseFirestore.instance
        .collection('user-data')
        .doc(userId)
        .collection("notifications")
        .doc();

    await docUser.set(notif.toJson());
  }

  DateTime _getDateTimeFromMillisecondEpoch(int time) {
    DateTime fromEpoch = DateTime.fromMillisecondsSinceEpoch(time);

    return DateTime(
      fromEpoch.year,
      fromEpoch.month,
      fromEpoch.day,
      fromEpoch.hour,
      fromEpoch.minute,
    );
  }

  void showNotice(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  String _getFormattedTime(DateTime time) {
    String formattedTime = "";
    DateTime arrival = DateTime(
      time.year,
      time.month,
      time.day,
    );

    formattedTime += DateFormat('MMM. dd, yyyy ').format(arrival) + "at ";
    formattedTime += DateFormat("h:mm a").format(time);
    return formattedTime;
  }
}
