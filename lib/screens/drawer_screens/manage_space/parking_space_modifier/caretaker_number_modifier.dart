import 'package:flutter/material.dart';
import 'package:lets_park/models/parking_space.dart';
import 'package:lets_park/screens/popups/notice_dialog.dart';
import 'package:lets_park/services/parking_space_services.dart';
import 'package:lets_park/shared/shared_widgets.dart';

class CaretakerNumberModifier extends StatefulWidget {
  final ParkingSpace space;
  const CaretakerNumberModifier({
    Key? key,
    required this.space,
  }) : super(key: key);

  @override
  State<CaretakerNumberModifier> createState() =>
      _CaretakerNumberModifierState();
}

class _CaretakerNumberModifierState extends State<CaretakerNumberModifier> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController caretakerNumberController;
  final SharedWidget _sharedWidget = SharedWidget();

  @override
  void initState() {
    caretakerNumberController =
        TextEditingController(text: _removeFirstTwoDigits());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text("Edit caretaker number"),
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
                  "Update caretaker number",
                  style: TextStyle(
                    fontSize: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Form(
              key: formKey,
              child: _sharedWidget.textFormField(
                action: TextInputAction.done,
                controller: caretakerNumberController,
                textInputType: TextInputType.number,
                maxLength: 10,
                hintText: "182083028",
                obscure: false,
                icon: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      "+63",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter phone number";
                  } else if (value.length < 9) {
                    return "Invalid phone number";
                  }
                  return null;
                },
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
                      "We are now updating the caretaker name. Please wait.",
                  forLoading: true,
                ),
              ),
            );

            widget.space.setCaretakerPhoneNumber =
                caretakerNumberController.text.trim();

            await Future.delayed(const Duration(seconds: 1));
            await ParkingSpaceServices.updateCaretakerPhoneNumber(
              widget.space.getSpaceId!,
              caretakerNumberController.text.trim(),
            );

            Navigator.pop(context);
            Navigator.pop(context, widget.space);
          }
        },
      ),
    );
  }

  String _removeFirstTwoDigits() {
    String number = "";

    List runes = widget.space.getCaretakerPhoneNumber!.runes.toList();

    for (int i = 0; i < runes.length; i++) {
      if (i > 1) {
        number += String.fromCharCode(runes[i]);
      }
    }
    return number;
  }
}
