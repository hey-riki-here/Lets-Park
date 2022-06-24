import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:lets_park/models/review.dart';
import 'package:lets_park/screens/popups/notice_dialog.dart';
import 'package:lets_park/globals/globals.dart' as globals;
import 'package:lets_park/services/parking_space_services.dart';
import 'package:lets_park/services/user_services.dart';

class ReviewParkingArea extends StatefulWidget {
  final String spaceId;
  final String notificationId;
  const ReviewParkingArea({
    Key? key,
    required this.spaceId,
    required this.notificationId,
  }) : super(key: key);

  @override
  State<ReviewParkingArea> createState() => _ReviewParkingAreaState();
}

class _ReviewParkingAreaState extends State<ReviewParkingArea> {
  final _infoController = TextEditingController();
  String address = "";
  String imageUrl = "";
  double spaceRating = 0;
  double rate = 0;

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

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _showDialog(
          imageLink: "assets/icons/marker.png",
          message: "Are you sure you want to cancel your review?",
          forConfirmation: true,
        );
        return globals.popWindow;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Review Parking Area"),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Image.asset(
                "assets/icons/marker.png",
                width: 25,
              ),
            ),
          ],
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
                      getStars(spaceRating),
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
              Row(
                children: const [
                  Icon(
                    Icons.info_outline,
                    color: Colors.grey,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Your review will greatly help this parking space to improve. Tell us about your parking experience.",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: RatingBar.builder(
                  minRating: 1,
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (double value) {
                    setState(() {
                      rate = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _infoController,
                maxLines: 5,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  hintText: "Tell us more about your experience (Optional)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
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
            onPressed: rate == 0
                ? null
                : () {
                    UserServices.updateReviewNotificationStatus(
                      FirebaseAuth.instance.currentUser!.uid,
                      widget.notificationId,
                    );

                    ParkingSpaceServices.updateParkingReviews(
                      widget.spaceId,
                      Review(
                        FirebaseAuth.instance.currentUser!.photoURL,
                        FirebaseAuth.instance.currentUser!.displayName,
                        rate,
                        _infoController.text.trim(),
                      ),
                    );
                    ParkingSpaceServices.updateParkingSpaceRating(
                      widget.spaceId,
                      rate,
                      context,
                    );
                  },
            child: const Text(
              "Submit",
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 18,
              ),
            ),
            style: ElevatedButton.styleFrom(
              primary: Colors.lightBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50.0),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future _showDialog(
      {required String imageLink,
      required String message,
      bool? forConfirmation = false}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return NoticeDialog(
          imageLink: imageLink,
          message: message,
          forConfirmation: forConfirmation!,
        );
      },
    );
  }

  Row getStars(double stars) {
    List<Widget> newChildren = [];
    double length = stars;
    Color? color = Colors.amber;

    if (stars == 0) {
      length = 5;
      color = Colors.grey[400];
    }

    for (int i = 0; i < length.toInt(); i++) {
      newChildren.add(
        Icon(
          Icons.star_rounded,
          color: color,
          size: 16,
        ),
      );
    }
    return Row(children: newChildren);
  }
}
