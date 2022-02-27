import 'package:flutter/material.dart';

class NoticeDialog extends StatelessWidget {
  final String message;
  final String imageLink;
  final bool forLoading;
  const NoticeDialog({
    Key? key,
    required this.imageLink,
    required this.message,
    this.forLoading = false,
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
        child: Center(child: CircularProgressIndicator(color: Colors.green,)),
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
