import 'package:google_maps_flutter/google_maps_flutter.dart';

class ParkingSpace {
  String? _id;
  String? _ownerId;
  String? _ownerName;
  String? _imageUrl;
  String? _address;
  LatLng? _latLng;
  int? _capacity;
  double? _rating;
  String? _info;
  double? _verticalClearance;
  String? _type;
  String? _dailyOrMonthly;
  List<String>? _features = [];
  String? _rules;
  bool? _isFull;

  ParkingSpace();

  ParkingSpace.fromDatabase(
    String? id,
    String? ownerId,
    String? ownerName,
    String? imageUrl,
    String? address,
    List geoposition,
    int? capacity,
    double? rating,
    String? info,
    double? verticalClearance,
    String? type,
    String? dailyOrMonthly,
    List<String>? features,
    String? rules,
  ) {
    _id = id;
    _ownerId = ownerId;
    _ownerName = ownerName;
    _imageUrl = imageUrl;
    _address = address;
    _latLng = LatLng(geoposition[0], geoposition[1]);
    _capacity = capacity;
    _rating = rating;
    _info = info;
    _verticalClearance = verticalClearance;
    _dailyOrMonthly = dailyOrMonthly;
    _type = type;
    _features = features;
    _rules = rules;
  }

  String? get getSpaceId => _id;

  set setSpaceId(String? id) {
    _id = id;
  }

  String? get getOwnerId => _ownerId;

  set setOwnerId(String? id) {
    _ownerId = id;
  }

  String? get getOwnerName => _ownerName;

  set setOwnerName(String? name) {
    _ownerName = name;
  }


  String? get getImageUrl => _imageUrl;

  set setImageUrl(String? imageUrl) {
    _imageUrl = imageUrl;
  }

  String? get getAddress => _address;

  set setAddress(String? address) {
    _address = address;
  }

  LatLng? get getLatLng => _latLng;

  set setLatLng(LatLng? latLng) {
    _latLng = latLng;
  }

  int? get getCapacity => _capacity;

  set setCapacity(int? capacity) {
    _capacity = capacity;
  }

  double? get getRating => _rating;

  set setRating(double? rating) {
    _rating = rating;
  }

  String? get getInfo => _info;

  set setInfo(String? info) {
    _info = info;
  }

  double? get getVerticalClearance => _verticalClearance;

  set setVerticalClearance(double? verticalClearance) {
    _verticalClearance = verticalClearance;
  }

  String? get getType => _type;

  set setType(String? type) {
    _type = type;
  }

  String? get getDailyOrMonthly => _dailyOrMonthly;

  set setDailyOrMonthly (String? dailyOrMonthly) {
    _dailyOrMonthly = dailyOrMonthly;
  }

  List<String>? get getFeatures => _features;

  set setFeatures(List<String>? features) {
    _features = features;
  }

   String? get getRules => _rules;

  set setRules(String? rules) {
    _rules = rules;
  }

  bool? get isSpaceFull => _isFull;

  set setFull(bool? isFull) {
    _isFull = isFull;
  }

  @override
  String toString() {
    return "ParkingSpace [ $_ownerId , $_imageUrl , $_address, $_latLng , $_capacity , $_rating , $_info , $_verticalClearance, $_type , $_features, $_isFull]";
  }

  Map<String, dynamic> toJson() => {
        'id': _id,
        'ownerId': _ownerId,
        'ownerName': _ownerName,
        'imageUrl': _imageUrl,
        'address': _address,
        'geoposition': [_latLng!.latitude, _latLng!.longitude],
        'capacity': _capacity,
        'rating': _rating,
        'info': _info,
        'verticalClearance': _verticalClearance,
        'type': _type,
        'dailyOrMonthly' : _dailyOrMonthly,
        'features': _features,
        'rules': _rules,
      };

  static ParkingSpace fromJson(Map<String, dynamic> json) {
    List fromDatabaseFeatures = json['features'];
    List<String>? features = [];
    features = fromDatabaseFeatures.cast<String>();

    return ParkingSpace.fromDatabase(
      json['id'],
      json['ownerId'],
      json['ownerName'],
      json['imageUrl'],
      json['address'],
      json['geoposition'],
      json['capacity'],
      json['rating'],
      json['info'],
      json['verticalClearance'],
      json['type'],
      json['dailyOrMonthly'],
      features,
      json['rules'],
    );
  }
}
