import 'package:google_maps_flutter/google_maps_flutter.dart';

class Parking {
  String? _parkingSpaceId;
  String? _type;
  String? _dailyOrMonthly;
  String? _parkingId;
  String? _imageUrl;
  String? _ownerId;
  String? _ownerName;
  String? _driver;
  String? _driverId;
  String? _driverImage;
  int? _stars;
  String? _address;
  LatLng? _latLng;
  String? _plateNumber;
  int? _arrival;
  int? _departure;
  int? _paymentDate;
  String? _duration;
  num? _price;
  bool? _inProgress;
  bool? _upcoming;
  bool? _inHistory;
  bool? _reported = false;

  Parking(
    String? parkingSpaceId,
    String? type,
    String? dailyOrMonthly,
    String? parkingId,
    String? imageUrl,
    String? ownerId,
    String? ownerName,
    String? driver,
    String? driverId,
    String? driverImage,
    int? stars,
    String? address,
    List geoposition,
    String? plateNumber,
    int? arrival,
    int? departure,
    int? paymentDate,
    String? duration,
    num? price,
    bool? inProgress,
    bool? upcoming,
    bool? inHistory,
    bool? reported,
  ) {
    _parkingSpaceId = parkingSpaceId;
    _type = type;
    _dailyOrMonthly = dailyOrMonthly;
    _parkingId = parkingId;
    _imageUrl = imageUrl;
    _ownerId = ownerId;
    _ownerName = ownerName;
    _driver = driver;
    _driverId = driverId;
    _driverImage = driverImage;
    _stars = stars;
    _address = address;
    _latLng = LatLng(geoposition[0], geoposition[1]);
    _plateNumber = plateNumber;
    _arrival = arrival;
    _departure = departure;
    _paymentDate = paymentDate;
    _duration = duration;
    _price = price;
    _inProgress = inProgress;
    _upcoming = upcoming;
    _inHistory = inHistory;
    _reported = reported;
  }

  String? get getParkingSpaceId => _parkingSpaceId;

  String? get getType => _type;

  String? get getDailyOrMonthly => _dailyOrMonthly;

  String? get getParkingId => _parkingId;

  String? get getImageUrl => _imageUrl;

  String? get getParkingOwner => _ownerId;

  String? get getParkingOwnerName => _ownerName;

  String? get getDriver => _driver;
  
  String? get getDriverId => _driverId;

  String? get getDriverImage => _driverImage;

  int? get getStars => _stars;

  set setStars(int? stars) {
    _stars = stars;
  }

  String? get getAddress => _address;

  set setAddress(String? address) {
    _address = address;
  }

  LatLng? get getLatLng => _latLng;

  set setLatLng(LatLng? latLng) {
    _latLng = latLng;
  }

  String? get getPlateNumber => _plateNumber;

  set setPlateNumber(String plateNumber) {
    _plateNumber = plateNumber;
  }

  int? get getArrival => _arrival;

  set setArrival(int arrival) {
    _arrival = arrival;
  }

  int? get getDeparture => _departure;

  set setDeparture(int departure) {
    _departure = departure;
  }

  String? get getDuration => _duration;

  set setDuration(String? duration) {
    _duration = duration;
  }

  int? get getPaymentDate => _paymentDate;

  set setPaymentDate(int? paymentDate) {
    _paymentDate = paymentDate;
  }

  num? get getPrice => _price;

  set setPrice(num price) {
    _price = price;
  }

  bool? get isInProgress => _inProgress;

  set setIsInProgress(bool? inProgress) {
    _inProgress = inProgress;
  }

  bool? get isUpcoming => _upcoming;

  set setIsUpcoming(bool? upcoming) {
    _upcoming = upcoming;
  }

  bool? get isInHistory => _inHistory;

  set setIsInHistoryg(bool? inHistory) {
    _inHistory = inHistory;
  }

  bool? get isReported => _reported;

  set setReported(bool? reported) {
    _reported = reported;
  }

  @override
  String toString() {
    return "Parking[$_parkingId, $_driver, $_stars, $_address, $_plateNumber, $_arrival, $_departure, $_duration, $_price, $_inProgress]";
  }

  Map<String, dynamic> toJson() => {
        'parkingSpaceId': _parkingSpaceId,
        'type': _type,
        'dailyOrMonthly': _dailyOrMonthly,
        'parkingId': _parkingId,
        'imageUrl': _imageUrl,
        'ownerId': _ownerId,
        'ownerName': _ownerName,
        'driver': _driver,
        'driverId': _driverId,
        'driverImage': _driverImage,
        'stars': _stars,
        'address': _address,
        'geoposition': [_latLng!.latitude, _latLng!.longitude],
        'plateNumber': _plateNumber,
        'arrival': _arrival,
        'departure': _departure,
        'paymentDate': _paymentDate,
        'duration': _duration,
        'price': _price,
        'inProgress': _inProgress,
        'upcoming': _upcoming,
        'inHistory': _inHistory,
        'reported': _reported,
      };

  static Parking fromJson(Map<String, dynamic> json) {
    return Parking(
      json['parkingSpaceId'],
      json['type'],
      json['dailyOrMonthly'],
      json['parkingId'],
      json['imageUrl'],
      json['ownerId'],
      json['ownerName'],
      json['driver'],
      json['driverId'],
      json['driverImage'],
      json['stars'],
      json['address'],
      json['geoposition'],
      json['plateNumber'],
      json['arrival'],
      json['departure'],
      json['paymentDate'],
      json['duration'],
      json['price'],
      json['inProgress'],
      json['upcoming'],
      json['inHistory'],
      json['reported'],
    );
  }
}
