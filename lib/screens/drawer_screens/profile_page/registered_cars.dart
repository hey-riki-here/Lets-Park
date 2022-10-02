// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lets_park/models/car.dart';
import 'package:lets_park/services/user_services.dart';
import 'package:lets_park/shared/shared_widgets.dart';

class RegisteredCars extends StatefulWidget {
  const RegisteredCars({Key? key}) : super(key: key);

  @override
  State<RegisteredCars> createState() => _RegisteredCarsState();
}

class _RegisteredCarsState extends State<RegisteredCars> {
  final _formKey = GlobalKey<FormState>();
  final _plateNumberController = TextEditingController();
  final _carMakeController = TextEditingController();
  final _carModelController = TextEditingController();
  final _sharedWidgets = SharedWidget();
  final _headerStyle = const TextStyle(
    fontSize: 12,
    color: Colors.blue,
  );
  final _valueStyle = const TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 15,
  );
  List<Car> cars = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _sharedWidgets.manageSpaceAppBar("My Cars"),
      backgroundColor: Colors.grey.shade100,
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection("user-data")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection("cars")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            cars.clear();
            snapshot.data!.docs.forEach((car) {
              cars.add(Car.fromJson(car.data()));
            });
          }
          return cars.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: cars.length,
                    itemBuilder: (context, index) {
                      return Card(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(12),
                          ),
                        ),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(
                                FontAwesomeIcons.car,
                                color: Colors.blue,
                              ),
                              Column(
                                children: [
                                  Text(
                                    "PLATE NO.",
                                    style: _headerStyle,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    cars[index].getPlateNumber!,
                                    style: _valueStyle,
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    "CAR MAKE",
                                    style: _headerStyle,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    cars[index].getCarMake!,
                                    style: _valueStyle,
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    "CAR MODEL",
                                    style: _headerStyle,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    cars[index].getCarModel!,
                                    style: _valueStyle,
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  UserServices.removeCar(
                                    cars[index],
                                  );
                                },
                                child: Icon(
                                  FontAwesomeIcons.trashAlt,
                                  color: Colors.red[400],
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              : Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.info_outline,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 10),
                      Text(
                        "No added cars.",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text("Add Car"),
        icon: const Icon(
          FontAwesomeIcons.car,
        ),
        onPressed: () {
          showDialog<int>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Center(
                  child: Text(
                    "Add new car",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
                content: StatefulBuilder(
                  builder: (context, sbSetState) {
                    return Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Plate number"),
                          _buildFormField(
                            controller: _plateNumberController,
                            hint: "AKA1 10124",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter plate number";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          const Text("Car make"),
                          _buildFormField(
                            controller: _carMakeController,
                            hint: "Honda",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter car make";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          const Text("Car model"),
                          _buildFormField(
                            controller: _carModelController,
                            hint: "Civic",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter car model";
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Discard"),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        UserServices.registerCar(
                          Car(
                            "",
                            _plateNumberController.text.toUpperCase(),
                            _carMakeController.text.toUpperCase(),
                            _carModelController.text.toUpperCase(),
                          ),
                        );

                        Navigator.pop(context);
                      }
                    },
                    child: const Text("Add"),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFormField({
    required String hint,
    required String? Function(String?)? validator,
    required TextEditingController controller,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
      ),
      validator: validator,
    );
  }
}
