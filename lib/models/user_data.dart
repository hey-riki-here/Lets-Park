// ignore_for_file: prefer_final_fields, avoid_function_literals_in_foreach_calls

import 'package:lets_park/models/notification.dart';
import 'package:lets_park/models/parking.dart';
import 'package:lets_park/models/parking_space.dart';

class UserData {
  String? _id;
  String? _name;
  String? _email;
  String? _phoneNumber;
  String? _imageUrl;
  List<ParkingSpace>? _ownedParkingSpace = [];
  int? _stars = 0;
  List<Parking>? _userParkings = [];
  List<UserNotification>? _notifications = [];
  List<String>? _favorites = [];
  bool? _isPayed = false;
  String? _paymentParams = "";

  UserData();

  UserData.fromDatabase(
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? imageUrl,
    int? stars,
    List<String>? favorites,
    bool isPayed,
    String paymentParams,
  ) {
    _id = id;
    _name = name;
    _email = email;
    _phoneNumber = phoneNumber;
    _imageUrl = imageUrl;
    _stars = stars;
    _favorites = favorites;
    _isPayed = isPayed;
    _paymentParams = paymentParams;
  }

  String? get getUserId => _id;

  set setUserId(String? id) => _id = id;

  String? get getUserName => _name;

  set setUserName(String? name) => _name = name;

  String? get getEmail => _email;

  set setEmail(String? email) => _email = email;

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

  bool? get userIsPayed => _isPayed;

  set setIsPayed(bool? isPayed) {
    _isPayed = isPayed;
  }

  String? get getPaymentParams => _paymentParams;

  set setPaymentParams(String? paymentParams) {
    _paymentParams = paymentParams;
  }

  @override
  String toString() {
    return "UserData [ $_id , $_stars , $_userParkings]";
  }

  Map<String, dynamic> toJson() => {
        'id': _id,
        'name': _name,
        'email': _email,
        'phoneNumber': _phoneNumber,
        'imageUrl': _imageUrl,
        'stars': _stars,
        'favorites': _favorites,
        'isPayed': _isPayed,
        'paymentParams': _paymentParams,
      };

  static UserData fromJson(Map<String, dynamic> json) {
    List fromDatabaseFavorites = json['favorites'];
    List<String>? favorites = [];
    favorites = fromDatabaseFavorites.cast<String>();

    return UserData.fromDatabase(
      json['id'],
      json['name'],
      json['email'],
      json['phoneNumber'],
      json['imageUrl'],
      json['stars'],
      favorites,
      json['isPayed'],
      json['paymentParams'],
    );
  }
}
