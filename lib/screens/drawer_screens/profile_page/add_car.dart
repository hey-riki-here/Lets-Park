import 'package:flutter/material.dart';
import 'package:lets_park/models/car.dart';
import 'package:lets_park/services/user_services.dart';

class AddCar extends StatelessWidget {
  const AddCar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _plateNumberController = TextEditingController();
    final _carMakeController = TextEditingController();
    final _carModelController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add Car",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Form(
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
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {},
                  child: const Text("Discard"),
                ),
                ElevatedButton(
                  onPressed: () {
                    UserServices.registerCar(
                      Car(
                        "",
                        _plateNumberController.text.toUpperCase(),
                        _carMakeController.text.toUpperCase(),
                        _carModelController.text.toUpperCase(),
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text("Add"),
                ),
              ],
            ),
          ],
        ),
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
