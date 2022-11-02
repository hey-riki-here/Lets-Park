// ignore_for_file: prefer_generic_function_type_aliases

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lets_park/screens/popups/notice_dialog.dart';
import 'package:lets_park/services/parking_space_services.dart';
import 'package:lets_park/models/report.dart';
import 'package:lets_park/services/world_time_api.dart';

class ReportSpace extends StatefulWidget {
  final String spaceId;
  final String parkingId;
  const ReportSpace({
    Key? key,
    required this.spaceId,
    required this.parkingId,
  }) : super(key: key);

  @override
  State<ReportSpace> createState() => _ReportSpaceState();
}

class _ReportSpaceState extends State<ReportSpace> {
  String address = "";
  String imageUrl = "";
  double spaceRating = 0;
  double rate = 0;
  int reviewsQty = 0;
  List<String> reasons = [
    "Space does not follow guidelines",
    "No parking attendant",
    "Attendant is piling may-ari ng parking space",
    "Reason 4",
    "Reason 5"
  ];
  String selectedReason = "";

  @override
  void initState() {
    FirebaseFirestore.instance
        .collection('parking-spaces')
        .doc(widget.spaceId)
        .get()
        .then((value) {
      setState(() {
        address = value.data()!["address"];
        imageUrl = value.data()!["imageUrl"];
        spaceRating = value.data()!["rating"];
      });
    });

    getParkingReviews();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Report Parking Area"),
        backgroundColor: Colors.red.shade400,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    address.isEmpty
                        ? const SizedBox(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            address,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        ParkingSpaceServices.getStars(spaceRating),
                        const SizedBox(width: 5),
                        Text("($reviewsQty)"),
                      ],
                    ),
                    const Text(
                      "Reservable",
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                imageUrl.isEmpty
                    ? const SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 4,
                        ),
                      )
                    : SizedBox(
                        width: 100,
                        height: 80,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Tell us the reason why you want to report this parking space",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            Column(
              children: reasons.map(buildRadioItem).toList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 80,
        ),
        child: ElevatedButton(
          onPressed: selectedReason.isEmpty
              ? null
              : () async {
                  submitReport();
                },
          child: const Text(
            "Submit report",
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 18,
            ),
          ),
          style: ElevatedButton.styleFrom(
            primary: Colors.red.shade400,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50.0),
            ),
          ),
        ),
      ),
    );
  }

  void getParkingReviews() async {
    int qty =
        await ParkingSpaceServices.getParkingReviewsQuantity(widget.spaceId)
            .then((value) => value);
    setState(() {
      reviewsQty = qty;
    });
  }

  RadioListTile buildRadioItem(String label) {
    return RadioListTile(
      title: Text(label),
      value: label,
      groupValue: selectedReason,
      onChanged: (value) {
        setState(() {
          selectedReason = value.toString();
        });
      },
    );
  }

  void submitReport() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: const NoticeDialog(
          imageLink: "assets/logo/lets-park-logo.png",
          message: "Submitting your report. Please wait.",
          forLoading: true,
        ),
      ),
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

    Report report = Report("", FirebaseAuth.instance.currentUser!.displayName!,
        selectedReason, now.millisecondsSinceEpoch, "Demerit");

    await ParkingSpaceServices.addReport(widget.spaceId, report);

    await ParkingSpaceServices.setSpaceReported(
        FirebaseAuth.instance.currentUser!.uid,
        widget.spaceId,
        widget.parkingId);

    await ParkingSpaceServices.updateCreditScore(widget.spaceId, -1);

    Navigator.pop(context);

    Navigator.pop(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: const NoticeDialog(
          imageLink: "assets/logo/lets-park-logo.png",
          message:
              "Thank you for your time on reporting this space.\nAny violations will not be tolerated.",
          forLoading: false,
        ),
      ),
    );
  }
}
