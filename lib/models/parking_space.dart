import 'package:google_maps_flutter/google_maps_flutter.dart';

class ParkingSpace {
  String? _id;
  String? _ownerId;
  String? _ownerName;
  String? _imageUrl;
  String? _address;
  String? _caretakerPhotoUrl;
  String? _caretakerName;
  String? _caretakerPhoneNumber;
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
  String? _paypalEmail;
  List<String>? _certificates = [];
  bool? _disabled = false;

  ParkingSpace();

  ParkingSpace.fromDatabase(
    String? id,
    String? ownerId,
    String? ownerName,
    String? imageUrl,
    String? address,
    String? caretakerPhotoUrl,
    String? caretakerName,
    String? caretakerPhoneNumber,
    List geoposition,
    int? capacity,
    double? rating,
    String? info,
    double? verticalClearance,
    String? type,
    String? dailyOrMonthly,
    List<String>? features,
    String? rules,
    String? paypalEmail,
    bool? disabled,
    List<String>? certificates,
  ) {
    _id = id;
    _ownerId = ownerId;
    _ownerName = ownerName;
    _imageUrl = imageUrl;
    _address = address;
    _caretakerPhotoUrl = caretakerPhotoUrl;
    _caretakerName = caretakerName;
    _caretakerPhoneNumber = caretakerPhoneNumber;
    _latLng = LatLng(geoposition[0], geoposition[1]);
    _capacity = capacity;
    _rating = rating;
    _info = info;
    _verticalClearance = verticalClearance;
    _dailyOrMonthly = dailyOrMonthly;
    _type = type;
    _features = features;
    _rules = rules;
    _paypalEmail = paypalEmail;
    _disabled = disabled;
    _certificates = certificates;
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

  String? get getCaretakerPhotoUrl => _caretakerPhotoUrl;

  set setCaretakerPhotoUrl(String? photoUrl) {
    _caretakerPhotoUrl = photoUrl;
  }

  String? get getCaretakerName => _caretakerName;

  set setCaretakerName(String? caretakerName) {
    _caretakerName = caretakerName;
  }

  String? get getCaretakerPhoneNumber => _caretakerPhoneNumber;

  set setCaretakerPhoneNumber(String? caretakerPhoneNumber) {
    _caretakerPhoneNumber = caretakerPhoneNumber;
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

  set setDailyOrMonthly(String? dailyOrMonthly) {
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

  String? get getPaypalEmail => _paypalEmail;

  set setPaypalEmail(String? paypalEmail) {
    _paypalEmail = paypalEmail;
  }

  bool? get isDisabled => _disabled;

  set setDisabled(bool? disabled) {
    _disabled = disabled;
  }

  List<String>? get getCertificates => _certificates;

  set setCertificates(List<String>? certificates) {
    _certificates = certificates;
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
        'caretakerPhotoUrl': _caretakerPhotoUrl,
        'caretakerName': _caretakerName,
        'caretakerPhoneNumber': _caretakerPhoneNumber,
        'geoposition': [_latLng!.latitude, _latLng!.longitude],
        'capacity': _capacity,
        'rating': _rating,
        'info': _info,
        'verticalClearance': _verticalClearance,
        'type': _type,
        'dailyOrMonthly': _dailyOrMonthly,
        'features': _features,
        'rules': _rules,
        'paypalEmail': _paypalEmail,
        'disabled': _disabled,
        'certificates' : _certificates,
      };

  static ParkingSpace fromJson(Map<String, dynamic> json) {
    List fromDatabaseFeatures = json['features'];
    List<String>? features = [];
    features = fromDatabaseFeatures.cast<String>();

    List fromDatabaseCertificates = json['certificates'];
    List<String>? certificates = [];
    certificates = fromDatabaseCertificates.cast<String>();

    return ParkingSpace.fromDatabase(
      json['id'],
      json['ownerId'],
      json['ownerName'],
      json['imageUrl'],
      json['address'],
      json['caretakerPhotoUrl'],
      json['caretakerName'],
      json['caretakerPhoneNumber'],
      json['geoposition'],
      json['capacity'],
      json['rating'],
      json['info'],
      json['verticalClearance'],
      json['type'],
      json['dailyOrMonthly'],
      features,
      json['rules'],
      json['paypalEmail'],
      json['disabled'],
      certificates,
    );
  }
}
