class Parking {
  String? _parkingSpaceId;
  String? _parkingId;
  String? _imageUrl;
  String? _ownerId;
  String? _driver;
  String? _driverId;
  String? _driverImage;
  int? _stars;
  String? _address;
  String? _plateNumber;
  int? _arrival;
  int? _departure;
  String? _duration;
  double? _price;
  bool? _inProgress;
  bool? _upcoming;
  bool? _inHistory;

  Parking(
    String? parkingSpaceId,
    String? parkingId,
    String? imageUrl,
    String? ownerId,
    String? driver,
    String? driverId,
    String? driverImage,
    int? stars,
    String? address,
    String? plateNumber,
    int? arrival,
    int? departure,
    String? duration,
    double? price,
    bool? inProgress,
    bool? upcoming,
    bool? inHistory,
  ) {
    _parkingSpaceId = parkingSpaceId;
    _parkingId = parkingId;
    _imageUrl = imageUrl;
    _ownerId = ownerId;
    _driver = driver;
    _driverId = driverId;
    _driverImage = driverImage;
    _stars = stars;
    _address = address;
    _plateNumber = plateNumber;
    _arrival = arrival;
    _departure = departure;
    _duration = duration;
    _price = price;
    _inProgress = inProgress;
    _upcoming = upcoming;
    _inHistory = inHistory;
  }

  String? get getParkingSpaceId => _parkingSpaceId;

  String? get getParkingId => _parkingId;

  String? get getImageUrl => _imageUrl;

  String? get getParkingOwner => _ownerId;

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

  double? get getPrice => _price;

  set setPrice(double price) {
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

  @override
  String toString() {
    return "Parking[$_parkingId, $_driver, $_stars, $_address, $_plateNumber, $_arrival, $_departure, $_duration, $_price, $_inProgress]";
  }

  Map<String, dynamic> toJson() => {
        'parkingSpaceId': _parkingSpaceId,
        'parkingId': _parkingId,
        'imageUrl': _imageUrl,
        'ownerId': _ownerId,
        'driver': _driver,
        'driverId': _driverId,
        'driverImage': _driverImage,
        'stars': _stars,
        'address': _address,
        'plateNumber': _plateNumber,
        'arrival': _arrival,
        'departure': _departure,
        'duration': _duration,
        'price': _price,
        'inProgress': _inProgress,
        'upcoming': _upcoming,
        'inHistory': _inHistory,
      };

  static Parking fromJson(Map<String, dynamic> json) {
    return Parking(
      json['parkingSpaceId'],
      json['parkingId'],
      json['imageUrl'],
      json['ownerId'],
      json['driver'],
      json['driverId'],
      json['driverImage'],
      json['stars'],
      json['address'],
      json['plateNumber'],
      json['arrival'],
      json['departure'],
      json['duration'],
      json['price'],
      json['inProgress'],
      json['upcoming'],
      json['inHistory'],
    );
  }
}
