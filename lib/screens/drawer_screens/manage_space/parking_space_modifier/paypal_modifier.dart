import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:lets_park/models/parking_space.dart';
import 'package:lets_park/screens/popups/notice_dialog.dart';
import 'package:lets_park/services/parking_space_services.dart';

class PaypalModifier extends StatefulWidget {
  final ParkingSpace space;
  const PaypalModifier({
    Key? key,
    required this.space,
  }) : super(key: key);

  @override
  State<PaypalModifier> createState() => _PaypalModifierState();
}

class _PaypalModifierState extends State<PaypalModifier> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController paypalController;

  @override
  void initState() {
    paypalController = TextEditingController(text: widget.space.getPaypalEmail);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text("Edit paypal email"),
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
                  "Update paypal email",
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
                controller: paypalController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) => EmailValidator.validate(value!) ? null : "Please enter a valid email",
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

            widget.space.setPaypalEmail = paypalController.text.trim();

            await Future.delayed(const Duration(seconds: 1));

            ParkingSpaceServices.updateSpacePaypalEmail(
              widget.space.getSpaceId!,
              paypalController.text.trim(),
            );

            Navigator.pop(context);
            Navigator.pop(context, widget.space);
          }
        },
      ),
    );
  }
}
