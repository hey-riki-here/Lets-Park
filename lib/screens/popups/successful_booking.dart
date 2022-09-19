import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lets_park/html_strings/html_string.dart';
import 'package:lets_park/main.dart';

class SuccessfulBooking extends StatelessWidget {
  final String owner;
  final String parkee;
  final String transactioDate;
  final String arrivalDate;
  final String departureDate;
  final String duration;
  final double parkingFee;
  final String spaceAddress;
  final String sendTo;
  final String replyTo;
  const SuccessfulBooking({
    Key? key,
    required this.owner,
    required this.parkee,
    required this.transactioDate,
    required this.arrivalDate,
    required this.departureDate,
    required this.duration,
    required this.parkingFee,
    required this.spaceAddress,
    required this.sendTo,
    required this.replyTo,
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
              sendEmail();
              navigatorKey.currentState!.popUntil((route) => route.isFirst);
              // await 
              // print("Email sent!");
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

  Future sendEmail() async {
    final url = Uri.parse("https://api.emailjs.com/api/v1.0/email/send");
    await http.post(
      url,
      headers: {
        'origin': 'http://localhost',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'service_id': 'service_rxauo5a',
        'template_id': 'template_534vxos',
        'user_id': 'HzDnP1qQtGYpkD7DY',
        'template_params': {
          'send_to' : sendTo,
          'reply_to' : replyTo,
          'my_html': HTMLString.getHTMLReceipt(
            owner: owner,
            parkee: parkee,
            transactioDate: transactioDate,
            arrivalDate: arrivalDate,
            departureDate: departureDate,
            duration: duration,
            parkingFee: parkingFee,
            spaceAddress: spaceAddress,
          ),
        },
      }),
    );
  }
}
