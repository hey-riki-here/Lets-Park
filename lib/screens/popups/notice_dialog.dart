import 'package:flutter/material.dart';
import 'package:lets_park/globals/globals.dart' as globals;

class NoticeDialog extends StatelessWidget {
  final String message;
  final String imageLink;
  final bool forLoading;
  final bool forConfirmation;
  const NoticeDialog({
    Key? key,
    required this.imageLink,
    required this.message,
    this.forLoading = false,
    this.forConfirmation = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 200,
        height: 207,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildImageAndMessage(imageLink, message),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildImageAndMessage(String image, String message) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            image,
            width: 40,
          ),
          const SizedBox(height: 15),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    if (forLoading == true) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
            child: CircularProgressIndicator(
          color: Colors.green,
        )),
      );
    } else if (forConfirmation == true) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              child: const Text(
                "Cancel",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
              ),
              onPressed: () {
                globals.popWindow = false;
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
            TextButton(
              child: const Text(
                "Confirm",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
              ),
              onPressed: () {
                globals.popWindow = true;
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
          ],
        ),
      );
    } else {
      return ElevatedButton(
        child: const Text(
          "GOT IT!",
          style: TextStyle(
            fontSize: 18,
          ),
        ),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          minimumSize: const Size(double.infinity, 45),
        ),
        onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
      );
    }
  }
}
