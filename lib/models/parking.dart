class Parking {
  String? _parkingId;
  String? _imageUrl;
  String? _driver;
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
    String? parkingId,
    String? imageUrl,
    String? driver,
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
    _parkingId = parkingId;
    _imageUrl = imageUrl;
    _driver = driver;
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

  String? get getParkingId => _parkingId;

  String? get getImageUrl => _imageUrl;

  String? get getDriver => _driver;

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
        'parkingId': _parkingId,
        'imageUrl': _imageUrl,
        'driver': _driver,
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
      json['parkingId'],
      json['imageUrl'],
      json['driver'],
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
