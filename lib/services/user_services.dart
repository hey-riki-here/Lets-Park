// ignore_for_file: avoid_function_literals_in_foreach_calls, unused_catch_clause, empty_catches

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lets_park/models/car.dart';
import 'package:lets_park/models/notification.dart';
import 'package:lets_park/models/parking.dart';
import 'package:lets_park/globals/globals.dart' as globals;
import 'package:lets_park/models/parking_space.dart';
import 'package:lets_park/services/notif_services.dart';
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

  final Stream checkPayed =
      Stream.periodic(const Duration(milliseconds: 1000), (int count) {
    return count;
  });

  static late StreamSubscription parkingSessionsStreams;
  static late StreamSubscription ownedParkingSessionsStreams;
  late StreamSubscription checkPayedStream;

  void startSessionsStream(BuildContext context) {
    parkingSessionsStreams = checkParkingSessionsStream.listen((event) {
      distributeParkingSessions(context);
    });

    ownedParkingSessionsStreams =
        checkOwnedParkingSessionsStream.listen((event) {
      checkParkingSessionsOnOwnedSpaces(context);
    });
  }

  void startCheckPayedStream() {}

  static Future registerNewUserData(
    String firstName,
    String lastName,
    String phoneNumber,
    String imageURL,
  ) async {
    String id = FirebaseAuth.instance.currentUser!.uid;
    final docUser = FirebaseFirestore.instance.collection('user-data').doc(id);

    globals.userData.setUserId = id;
    globals.userData.setFirstName = firstName;
    globals.userData.setLastName = lastName;
    globals.userData.setPhoneNumber = phoneNumber;
    globals.userData.setImageURL = imageURL;
    globals.userData.setUserFavories = [];

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
          parkingSessionsStreams.pause();
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

          NotificationServices.showNotification(
            "Parking session started",
            "Your parking session has started. Click View Parking to view parking session details.",
          );
          parkingSessionsStreams.resume();
        } else if (_getDateTimeFromMillisecondEpoch(parking.getArrival!)
                    .compareTo(now) ==
                1 &&
            parking.isUpcoming == false) {
          parkingSessionsStreams.pause();
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
          parkingSessionsStreams.resume();
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
          parkingSessionsStreams.pause();
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

          NotificationServices.showNotification(
            "Parking session ended",
            "Your parking session has ended. Click View Parking to view parking session details.",
          );
          parkingSessionsStreams.resume();
        }
      }
    } on Exception catch (e) {}
  }

  void checkParkingSessionsOnOwnedSpaces(BuildContext context) async {
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
            ownedParkingSessionsStreams.pause();
            await parkingSpacesDb
                .doc(parking.getParkingSpaceId)
                .collection("parking-sessions")
                .doc(parking.getParkingId)
                .update({
              'inProgress': true,
              'upcoming': false,
              'inHistory': false,
            });
            ownedParkingSessionsStreams.resume();
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
            ownedParkingSessionsStreams.pause();
            await parkingSpacesDb
                .doc(parking.getParkingSpaceId)
                .collection("parking-sessions")
                .doc(parking.getParkingId)
                .update({
              'inProgress': false,
              'upcoming': false,
              'inHistory': true,
            });
            ownedParkingSessionsStreams.resume();
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

  static void getFavorites(String uid) async {
    try {
      FirebaseFirestore.instance
          .collection('user-data')
          .doc(uid)
          .get()
          .then((value) {
        List fromDatabaseFavs = value.data()!['favorites'];
        globals.favorites = fromDatabaseFavs.cast<String>();
      });
    } on Exception catch (e) {}
  }

  static void addSpaceonFavorites(String uid, String spaceId) async {
    List<String> newFavList = globals.favorites;
    newFavList.add(spaceId);
    await FirebaseFirestore.instance.collection('user-data').doc(uid).update({
      'favorites': newFavList,
    });
    getFavorites(uid);
  }

  static void removeSpaceonFavorites(String uid, String spaceId) async {
    List<String> newFavList = globals.favorites;
    newFavList.remove(spaceId);
    await FirebaseFirestore.instance.collection('user-data').doc(uid).update({
      'favorites': newFavList,
    });
  }

  static Future<int> _getRegisteredCarsQuantity() async {
    int size = 0;
    await FirebaseFirestore.instance
        .collection('user-data')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('cars')
        .snapshots()
        .first
        .then((value) {
      size = value.size;
    });
    return size;
  }

  static void registerCar(Car car) async {
    int number = 0;
    await _getRegisteredCarsQuantity().then((value) {
      number = value;
    });
    String dateAdded = DateTime.now().day.toString() +
        DateTime.now().month.toString() +
        DateTime.now().year.toString() +
        DateTime.now().hour.toString() +
        DateTime.now().minute.toString() +
        DateTime.now().second.toString() +
        DateTime.now().microsecond.toString();

    car.setCarId = "CAR$dateAdded$number";

    final newCarDoc = FirebaseFirestore.instance
        .collection('user-data')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('cars')
        .doc(car.getCarId);

    await newCarDoc.set(car.toJson());
  }

  static void removeCar(Car car) async {
    await FirebaseFirestore.instance
        .collection('user-data')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('cars')
        .doc(car.getCarId)
        .delete();
  }

  static Future<bool> isPayed(String uid) async {
    return await FirebaseFirestore.instance
        .collection('user-data')
        .doc(uid)
        .get()
        .then((value) {
      return value.data()!['isPayed'];
    });
  }

  static void setPayedToFalse(String uid) async {
    return await FirebaseFirestore.instance
        .collection('user-data')
        .doc(uid)
        .update({
      'isPayed': false,
    });
  }

  static void setPaymentParams(String uid, String params) async {
    return await FirebaseFirestore.instance
        .collection('user-data')
        .doc(uid)
        .update({
      'paymentParams': params,
    });
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

  StreamSubscription get getParkingSessionsStream => parkingSessionsStreams;

  StreamSubscription get getOwnedParkingSessionsStream =>
      ownedParkingSessionsStreams;
}
