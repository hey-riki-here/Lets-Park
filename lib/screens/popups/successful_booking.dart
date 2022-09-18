import 'package:flutter/material.dart';
import 'package:lets_park/main.dart';
import 'package:lets_park/models/parking.dart';
import 'package:lets_park/models/parking_space.dart';

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
              
              navigatorKey.currentState!.popUntil((route) => route.isFirst);
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
