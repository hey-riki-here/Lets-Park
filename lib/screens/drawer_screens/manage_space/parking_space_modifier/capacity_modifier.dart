import 'package:flutter/material.dart';
import 'package:lets_park/models/parking_space.dart';
import 'package:lets_park/screens/popups/notice_dialog.dart';
import 'package:lets_park/services/parking_space_services.dart';

class CapacityModifier extends StatefulWidget {
  final ParkingSpace space;
  const CapacityModifier({
    Key? key,
    required this.space,
  }) : super(key: key);

  @override
  State<CapacityModifier> createState() => _CapacityModifierState();
}

class _CapacityModifierState extends State<CapacityModifier> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController capacityController;

  @override
  void initState() {
    capacityController =
        TextEditingController(text: widget.space.getCapacity.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text("Edit space capacity"),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset("assets/logo/app_icon.png"),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: const [
                Text(
                  "Update parking space capacity",
                  style: TextStyle(
                    fontSize: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Form(
              key: formKey,
              child: TextFormField(
                controller: capacityController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "This field is required.";
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.save,
        ),
        onPressed: () async {
          if (formKey.currentState!.validate()) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => WillPopScope(
                onWillPop: () async => false,
                child: const NoticeDialog(
                  imageLink: "assets/logo/lets-park-logo.png",
                  message:
                      "We are now updating the parking space. Please wait.",
                  forLoading: true,
                ),
              ),
            );

            int newCapacity = int.parse(capacityController.text);
            widget.space.setCapacity = newCapacity;

            await Future.delayed(const Duration(seconds: 1));
            ParkingSpaceServices.updateSpaceCapacity(
                widget.space.getSpaceId!, newCapacity);

            Navigator.pop(context);
            Navigator.pop(context, widget.space);
          }
        },
      ),
    );
  }
}
