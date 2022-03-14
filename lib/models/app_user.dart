import 'package:lets_park/models/parking_space.dart';

class AppUser {
  String? _id;
  List<ParkingSpace>? _ownedParkingSpace;

  AppUser();

  String? get getUserId => _id;

  set setUserId(String? id) => _id = id;

  List<ParkingSpace>? get getOwnedParkingSpaces => _ownedParkingSpace;

  set setOwnedParkingSpaces(List<ParkingSpace>? ownedParkingSpace) => _ownedParkingSpace = ownedParkingSpace;
}
