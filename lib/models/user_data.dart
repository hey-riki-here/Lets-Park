// ignore_for_file: prefer_final_fields, avoid_function_literals_in_foreach_calls

import 'package:lets_park/models/notification.dart';
import 'package:lets_park/models/parking.dart';
import 'package:lets_park/models/parking_space.dart';

class UserData {
  String? _id;
  String? _firstName = "";
  String? _lastName;
  String? _phoneNumber;
  String? _imageUrl;
  List<ParkingSpace>? _ownedParkingSpace = [];
  int? _stars = 0;
  List<Parking>? _userParkings = [];
  List<UserNotification>? _notifications = [];
  List<String>? _favorites = [];

  UserData();

  UserData.fromDatabase(
    String? id,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? imageUrl,
    int? stars,
    List<String>? favorites,
  ) {
    _id = id;
    _firstName = firstName;
    _lastName = lastName;
    _phoneNumber = phoneNumber;
    _imageUrl = imageUrl;
    _stars = stars;
    _favorites = favorites;
  }

  String? get getUserId => _id;

  set setUserId(String? id) => _id = id;

  String? get getFirstName => _firstName;

  set setFirstName(String? firstName) => _firstName = firstName;

  String? get getLastName => _lastName;

  set setLastName(String? lastName) => _lastName = lastName;

  String? get getPhoneNumber => _phoneNumber;

  set setPhoneNumber(String? phoneNumber) => _phoneNumber = phoneNumber;

  String? get getImageURL => _imageUrl;

  set setImageURL(String? imageUrl) => _imageUrl = imageUrl;

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

  List<String>? get getUserFavorites => _favorites;

  set setUserFavories(List<String>? favorites) {
    _favorites = favorites;
  }

  @override
  String toString() {
    return "UserData [ $_id , $_stars , $_firstName , $_userParkings]";
  }

  Map<String, dynamic> toJson() => {
        'id': _id,
        'firstName': _firstName,
        'lastName': _lastName,
        'phoneNumber': _phoneNumber,
        'imageUrl': _imageUrl,
        'stars': _stars,
        'favorites': _favorites,
      };

  static UserData fromJson(Map<String, dynamic> json) {
    List fromDatabaseFavorites = json['favorites'];
    List<String>? favorites = [];
    favorites = fromDatabaseFavorites.cast<String>();

    return UserData.fromDatabase(
      json['id'],
      json['firstName'],
      json['lastName'],
      json['phoneNumber'],
      json['imageUrl'],
      json['stars'],
      favorites,
    );
  }
}
