import 'package:lets_park/models/parking_space.dart';

class UserData {
  String? _id;
  List<ParkingSpace>? _ownedParkingSpace;

  UserData();

  String? get getUserId => _id;

  set setUserId(String? id) => _id = id;

  List<ParkingSpace>? get getOwnedParkingSpaces => _ownedParkingSpace;

  set setOwnedParkingSpaces(List<ParkingSpace>? ownedParkingSpace) => _ownedParkingSpace = ownedParkingSpace;
}
