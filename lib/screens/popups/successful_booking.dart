import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lets_park/main.dart';
import 'package:lets_park/models/notification.dart';
import 'package:lets_park/models/parking.dart';
import 'package:lets_park/models/parking_space.dart';
import 'package:lets_park/screens/popups/notice_dialog.dart';
import 'package:lets_park/services/parking_space_services.dart';
import 'package:lets_park/services/user_services.dart';
import 'package:lets_park/services/world_time_api.dart';
import 'package:lets_park/globals/globals.dart' as globals;

class SuccessfulBooking extends StatelessWidget {
  final Parking newParking;
  final ParkingSpace parkingSpace;
  const SuccessfulBooking({
    Key? key,
    required this.newParking,
    required this.parkingSpace,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset("assets/logo/app_icon.png"),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 50,
              ),
              SizedBox(height: 30),
              Text(
                "Booking successful! You will get your booking information shortly through email. You can always check your bookings \nby going to My Parkings.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => WillPopScope(
                  onWillPop: () async => false,
                  child: const NoticeDialog(
                    imageLink: "assets/logo/lets-park-logo.png",
                    message: "Checking and verifying your booking...",
                    forLoading: true,
                  ),
                ),
              );
              UserServices.parkingSessionsStreams.pause();
              UserServices.ownedParkingSessionsStreams.pause();
              ParkingSpaceServices.updateParkingSpaceData(
                parkingSpace,
                newParking,
              );

              DateTime now = DateTime(0, 0, 0, 0, 0);
              await WorldTimeServices.getDateTimeNow().then((time) {
                now = DateTime(
                  time.year,
                  time.month,
                  time.day,
                  time.hour,
                  time.minute,
                );
              });

              UserServices.updateUserParkingData(newParking);

              UserServices.notifyUser(
                "NOTIF" +
                    globals.userData.getUserNotifications!.length.toString(),
                parkingSpace.getOwnerId!,
                UserNotification(
                  "NOTIF" +
                      globals.userData.getUserNotifications!.length.toString(),
                  parkingSpace.getSpaceId!,
                  FirebaseAuth.instance.currentUser!.photoURL!,
                  FirebaseAuth.instance.currentUser!.displayName!,
                  "just booked on your parking space. Tap to view details.",
                  true,
                  false,
                  now.millisecondsSinceEpoch,
                  false,
                  false,
                ),
              );
              navigatorKey.currentState!.popUntil((route) => route.isFirst);
              UserServices.parkingSessionsStreams.resume();
              UserServices.ownedParkingSessionsStreams.resume();
              // Navigator.pop(context);
            },
            child: const Text(
              "Confirm",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
            style: ElevatedButton.styleFrom(
              primary: Colors.lightBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
