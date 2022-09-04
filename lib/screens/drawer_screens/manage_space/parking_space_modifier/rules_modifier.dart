import 'package:flutter/material.dart';
import 'package:lets_park/models/parking_space.dart';
import 'package:lets_park/screens/popups/notice_dialog.dart';
import 'package:lets_park/services/parking_space_services.dart';

class RulesModifier extends StatelessWidget {
  final ParkingSpace space;
  const RulesModifier({
    Key? key,
    required this.space,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final rulesController = TextEditingController(
      text: space.getRules.toString(),
    );

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text("Edit space rules"),
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
                  "Update parking space rules",
                  style: TextStyle(
                    fontSize: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            _buildInfoField(
              maxLines: 5,
              value: space.getRules!,
              controller: rulesController,
              key: formKey,
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
            space.setRules = rulesController.text.trim();

            await Future.delayed(const Duration(seconds: 1));
            ParkingSpaceServices.updateSpaceRules(
              space.getSpaceId!,
              rulesController.text.trim(),
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
