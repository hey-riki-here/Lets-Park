class Parking {
  String? _driver;
  int? _stars;
  String? _address;
  String? _plateNumber;
  int? _arrival;
  int? _departure;
  String? _duration;
  double? _price;

  Parking(
    String? driver,
    int? stars,
    String? address,
    String? plateNumber,
    int? arrival,
    int? departure,
    String? duration,
    double? price,
  ) {
    _driver = driver;
    _stars = stars;
    _address = address;
    _plateNumber = plateNumber;
    _arrival = arrival;
    _departure = departure;
    _duration = duration;
    _price = price;
  }

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

  @override
  String toString() {
    return "Parking[$_driver, $_stars, $_address, $_plateNumber, $_arrival, $_departure, $_duration, $_price]";
  }

  Map<String, dynamic> toJson() => {
        'driver': _driver,
        'stars': _stars,
        'address': _address,
        'plateNumber': _plateNumber,
        'arrival': _arrival,
        'departure': _departure,
        'duration': _duration,
        'price': _price,
      };
}
