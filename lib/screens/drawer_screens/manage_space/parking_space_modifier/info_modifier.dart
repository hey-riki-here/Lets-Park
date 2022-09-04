import 'package:flutter/material.dart';
import 'package:lets_park/models/parking_space.dart';
import 'package:lets_park/screens/popups/notice_dialog.dart';
import 'package:lets_park/services/parking_space_services.dart';

class InfoModifier extends StatelessWidget {
  final ParkingSpace space;
  const InfoModifier({
    Key? key,
    required this.space,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final infoController = TextEditingController(
      text: space.getInfo,
    );
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text("Edit space information"),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: const [
                Text(
                  "Update parking space information",
                  style: TextStyle(
                    fontSize: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            _buildInfoField(
              maxLines: 5,
              value: space.getInfo!,
              key: _formKey,
              controller: infoController,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.save,
        ),
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
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
            space.setInfo = infoController.text.trim();

            await Future.delayed(const Duration(seconds: 1));
            ParkingSpaceServices.updateSpaceInfo(
              space.getSpaceId!,
              infoController.text.trim(),
            );

            Navigator.pop(context);
            Navigator.pop(context, space);
          }
        },
      ),
    );
  }

  Widget _buildInfoField({
    required int maxLines,
    required String value,
    required GlobalKey<FormState> key,
    required TextEditingController controller,
  }) {
    return Form(
      key: key,
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        textInputAction: TextInputAction.done,
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
    );
  }
}
