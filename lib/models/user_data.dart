// ignore_for_file: prefer_final_fields

import 'package:lets_park/models/parking.dart';
import 'package:lets_park/models/parking_space.dart';

class UserData {
  String? _id;
  List<ParkingSpace>? _ownedParkingSpace;
  int? _stars = 0;
  List<Parking>? _userParkings = [];

  UserData();

  UserData.fromDatabase(
    String? id,
    List<ParkingSpace>? ownedParkingSpace,
    List<Parking>? userParkings,
  ) {
    _id = id;
    _ownedParkingSpace = ownedParkingSpace;
    _userParkings = userParkings;
  }

  String? get getUserId => _id;

  set setUserId(String? id) => _id = id;

  List<ParkingSpace>? get getOwnedParkingSpaces => _ownedParkingSpace;

  set setOwnedParkingSpaces(List<ParkingSpace>? ownedParkingSpace) =>
      _ownedParkingSpace = ownedParkingSpace;

  List<Parking>? get getUserParkings => _userParkings;

  set setParkings(List<Parking>? parkings){
    _userParkings = parkings;
  }

  int? get getStars => _stars;

  set setStars(int? stars) => _stars = stars;

  @override
  String toString() {
    return "UserData [ $_id , $_stars , $_ownedParkingSpace , $_userParkings]";
  }

  Map<String, dynamic> toJson() => {
        'id': _id,
        'stars': _stars,
        'userParkings': _userParkings!.map((parking) => parking.toJson()).toList(),
      };
}
