// ignore_for_file: prefer_final_fields, avoid_function_literals_in_foreach_calls

import 'package:lets_park/models/notification.dart';
import 'package:lets_park/models/parking.dart';
import 'package:lets_park/models/parking_space.dart';

class UserData {
  String? _id;
  List<ParkingSpace>? _ownedParkingSpace;
  int? _stars = 0;
  List<Parking>? _userParkings = [];
  List<UserNotification>? _notifications = [];

  UserData();

  UserData.fromDatabase(
    String? id,
    int? stars,
  ) {
    _id = id;
    _stars = stars;
  }

  String? get getUserId => _id;

  set setUserId(String? id) => _id = id;

  List<ParkingSpace>? get getOwnedParkingSpaces => _ownedParkingSpace;

  set setOwnedParkingSpaces(List<ParkingSpace>? ownedParkingSpace) =>
      _ownedParkingSpace = ownedParkingSpace;

  int? get getStars => _stars;

  set setStars(int? stars) => _stars = stars;

  List<Parking>? get getUserParkings => _userParkings;

  set setParkings(List<Parking>? parkings) {
    _userParkings = parkings;
  }

  List<UserNotification>? get getUserNotifications => _notifications;

  set setUserNotifications(List<UserNotification>? notifications) {
    _notifications = notifications;
  }

  @override
  String toString() {
    return "UserData [ $_id , $_stars , $_userParkings]";
  }

  Map<String, dynamic> toJson() => {
        'id': _id,
        'stars': _stars,
      };

  static UserData fromJson(Map<String, dynamic> json) {
    return UserData.fromDatabase(
      json['id'],
      json['stars'],
    );
  }
}
