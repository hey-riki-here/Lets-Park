class Car {
  String? _carId;
  String? _plateNumber;
  String? _carMake;
  String? _carModel;

  Car(
    String? carId,
    String? plateNumber,
    String? carMake,
    String? carModel,
  ) {
    _carId = carId;
    _plateNumber = plateNumber;
    _carMake = carMake;
    _carModel = carModel;
  }

  Car.fromDatabase(
    String? carId,
    String? plateNumber,
    String? carMake,
    String? carModel,
  ) {
    _carId = carId;
    _plateNumber = plateNumber;
    _carMake = carMake;
    _carModel = carModel;
  }

  String? get getCarId => _carId;

  set setCarId(String? carId) => _carId = carId;

  String? get getPlateNumber => _plateNumber;

  set setPlateNumber(String? plateNumber) => _plateNumber = plateNumber;

  String? get getCarMake => _carMake;

  set setCarMake(String? carMake) => _carMake = carMake;

  String? get getCarModel => _carModel;

  set setCarModel(String? carModel) => _carModel = carModel;

  Map<String, dynamic> toJson() => {
        'carId': _carId,
        'plateNumber': _plateNumber,
        'carMake': _carMake,
        'carModel': _carModel,
      };

  static Car fromJson(Map<String, dynamic> json) {
    return Car.fromDatabase(
      json['carId'],
      json['plateNumber'],
      json['carMake'],
      json['carModel'],
    );
  }
}
