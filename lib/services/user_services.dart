// ignore_for_file: avoid_function_literals_in_foreach_calls, unused_catch_clause, empty_catches

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lets_park/models/notification.dart';
import 'package:lets_park/models/parking.dart';
import 'package:lets_park/globals/globals.dart' as globals;
import 'package:lets_park/models/parking_space.dart';
import 'package:lets_park/services/world_time_api.dart';

class UserServices {
  var userParkings = FirebaseFirestore.instance
      .collection('user-data')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection("user-parkings");

  var parkingSpacesDb = FirebaseFirestore.instance.collection('parking-spaces');

  List<Parking> parkings = [];

  DateTime now = DateTime(0, 0, 0, 0, 0);

  List<ParkingSpace> spaces = [];

  final Stream checkParkingSessionsStream =
      Stream.periodic(const Duration(milliseconds: 1000), (int count) {
    return count;
  });

  final Stream checkOwnedParkingSessionsStream =
      Stream.periodic(const Duration(milliseconds: 1000), (int count) {
    return count;
  });

  late StreamSubscription _parkingSessionsStreams;
  late StreamSubscription _ownedParkingSessionsStreams;

  void startSessionsStream(BuildContext context) {
    _parkingSessionsStreams = checkParkingSessionsStream.listen((event) {
      if (globals.goCheck) {
        distributeParkingSessions(context);
      }
    });

    _ownedParkingSessionsStreams =
        checkOwnedParkingSessionsStream.listen((event) {
      if (globals.goCheck) {
        checkParkingSessionsOnOwnedSpaces(context);
      }
    });
  }

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
    parkings = globals.userData.getUserParkings!;

    try {
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
          _parkingSessionsStreams.pause();
          await userParkings.doc(parking.getParkingId).update({
            'inProgress': true,
            'upcoming': false,
            'inHistory': false,
          });

          await parkingSpacesDb
              .doc(parking.getParkingSpaceId)
              .collection("parking-sessions")
              .doc(parking.getParkingId)
              .update({
            'inProgress': true,
            'upcoming': false,
            'inHistory': false,
          });
          _parkingSessionsStreams.resume();
        } else if (_getDateTimeFromMillisecondEpoch(parking.getArrival!)
                    .compareTo(now) ==
                1 &&
            parking.isUpcoming == false) {
          _parkingSessionsStreams.pause();
          await userParkings.doc(parking.getParkingId).update({
            'inProgress': false,
            'upcoming': true,
            'inHistory': false,
          });

          await parkingSpacesDb
              .doc(parking.getParkingSpaceId)
              .collection("parking-sessions")
              .doc(parking.getParkingId)
              .update({
            'inProgress': false,
            'upcoming': true,
            'inHistory': false,
          });
          _parkingSessionsStreams.resume();
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
          _parkingSessionsStreams.pause();
          await userParkings.doc(parking.getParkingId).update({
            'inProgress': false,
            'upcoming': false,
            'inHistory': true,
          }).then((_) {
            UserServices.notifyUser(
              "NOTIF" +
                  globals.userData.getUserNotifications!.length.toString(),
              parking.getParkingOwner!,
              UserNotification(
                "NOTIF" +
                    globals.userData.getUserNotifications!.length.toString(),
                parking.getParkingSpaceId!,
                FirebaseAuth.instance.currentUser!.photoURL!,
                FirebaseAuth.instance.currentUser!.displayName!,
                "finished parking in your parking space. Give him a rate now.",
                false,
                true,
                now.millisecondsSinceEpoch,
                false,
                false,
              ),
            );

            UserServices.notifyUser(
              "NOTIF" +
                  globals.userData.getUserNotifications!.length.toString(),
              FirebaseAuth.instance.currentUser!.uid,
              UserNotification(
                "NOTIF" +
                    globals.userData.getUserNotifications!.length.toString(),
                parking.getParkingSpaceId!,
                FirebaseAuth.instance.currentUser!.photoURL!,
                FirebaseAuth.instance.currentUser!.displayName!,
                "How did the parking went? Share your thoughts now.",
                false,
                false,
                now.millisecondsSinceEpoch,
                false,
                false,
              ),
            );
          });

          await parkingSpacesDb
              .doc(parking.getParkingSpaceId)
              .collection("parking-sessions")
              .doc(parking.getParkingId)
              .update({
            'inProgress': false,
            'upcoming': false,
            'inHistory': true,
          });
          _parkingSessionsStreams.resume();
        }
      }
    } on Exception catch (e) {}
  }

  void checkParkingSessionsOnOwnedSpaces(BuildContext context) async {
    if (globals.goCheckOwnedSpaces) {
      spaces = globals.userData.getOwnedParkingSpaces!;

      spaces.forEach((space) async {
        await parkingSpacesDb
            .doc(space.getSpaceId)
            .collection('parking-sessions')
            .snapshots()
            .forEach((sessions) {
          sessions.docs.forEach((session) async {
            Parking parking = Parking.fromJson(session.data());

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
              _ownedParkingSessionsStreams.pause();
              await parkingSpacesDb
                  .doc(parking.getParkingSpaceId)
                  .collection("parking-sessions")
                  .doc(parking.getParkingId)
                  .update({
                'inProgress': true,
                'upcoming': false,
                'inHistory': false,
              });
              _ownedParkingSessionsStreams.resume();
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
              _ownedParkingSessionsStreams.pause();
              await parkingSpacesDb
                  .doc(parking.getParkingSpaceId)
                  .collection("parking-sessions")
                  .doc(parking.getParkingId)
                  .update({
                'inProgress': false,
                'upcoming': false,
                'inHistory': true,
              });
              _ownedParkingSessionsStreams.resume();
              UserServices.notifyUser(
                "NOTIF" +
                    globals.userData.getUserNotifications!.length.toString(),
                parking.getParkingOwner!,
                UserNotification(
                  "NOTIF" +
                      globals.userData.getUserNotifications!.length.toString(),
                  parking.getParkingSpaceId!,
                  parking.getDriverImage!,
                  parking.getDriver!,
                  "finished parking in your parking space. Give him a rate now.",
                  false,
                  true,
                  now.millisecondsSinceEpoch,
                  false,
                  false,
                ),
              );
            }
          });
        });
      });
    }
  }

  static void notifyUser(
      String notifId, String userId, UserNotification notif) async {
    final docUser = FirebaseFirestore.instance
        .collection('user-data')
        .doc(userId)
        .collection("notifications")
        .doc(notifId);

    await docUser.set(notif.toJson());
  }

  static void updateNotificationStatus(
    String userId,
    String notificationId,
  ) async {
    await FirebaseFirestore.instance
        .collection('user-data')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({
      'hasRead': true,
    });
  }

  static void updateReviewNotificationStatus(
    String userId,
    String notificationId,
  ) async {
    await FirebaseFirestore.instance
        .collection('user-data')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({
      'hasFinishedReview': true,
    });
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

  // void showNotice(BuildContext context, String message) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(message),
  //       behavior: SnackBarBehavior.floating,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(12),
  //       ),
  //       backgroundColor: Colors.blue,
  //       duration: const Duration(seconds: 5),
  //     ),
  //   );
  // }

  StreamSubscription get getParkingSessionsStream => _parkingSessionsStreams;

  StreamSubscription get getOwnedParkingSessionsStream =>
      _ownedParkingSessionsStreams;
}
