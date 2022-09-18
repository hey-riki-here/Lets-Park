import 'package:flutter/material.dart';
import 'package:lets_park/globals/globals.dart' as globals;
import 'package:lets_park/screens/popups/checkout_non_reservable.dart';

class NoticeDialog extends StatelessWidget {
  final String message;
  final String header;
  final String imageLink;
  final bool forLoading;
  final bool forConfirmation;
  final bool forNonreservableConfirmation;
  final String parkingAreaAddress;
  final bool forWarning;
  const NoticeDialog({
    Key? key,
    required this.imageLink,
    required this.message,
    this.header = "",
    this.forLoading = false,
    this.forConfirmation = false,
    this.forNonreservableConfirmation = false,
    this.parkingAreaAddress = "",
    this.forWarning = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildImageAndMessage(imageLink, message),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildImageAndMessage(String image, String message) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          forWarning
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.warning_rounded,
                      color: Colors.amber,
                      size: 50,
                    ),
                    Text(
                      "Warning",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              : Image.asset(
                  image,
                  width: 40,
                ),
          const SizedBox(height: 15),
          Text(
            header,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          forNonreservableConfirmation
              ? Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              message,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Parking space address",
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            parkingAreaAddress,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Text(
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
    } else if (forNonreservableConfirmation == true) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              child: Text(
                "Cancel".toUpperCase(),
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
              onPressed: () {
                globals.popWindow = false;
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
            TextButton(
              child: Text(
                "Yes, I'm at the parking location".toUpperCase(),
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
              onPressed: () {
                globals.popWindow = true;
                Navigator.of(context, rootNavigator: true).pop();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (context) => NonReservableCheckout(
                      parkingSpace: globals.nonReservable,
                    ),
                  ),
                );
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
