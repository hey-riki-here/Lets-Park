// ignore_for_file: prefer_generic_function_type_aliases

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:lets_park/models/review.dart';
import 'package:lets_park/screens/popups/notice_dialog.dart';
import 'package:lets_park/globals/globals.dart' as globals;
import 'package:lets_park/services/parking_space_services.dart';
import 'package:lets_park/services/user_services.dart';
import 'package:lets_park/main.dart';

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
  int reviewsQty = 0;
  bool tagSelected = false;
  List<String> selectedTags = [];

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
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  direction: Axis.horizontal,
                  runSpacing: 10,
                  children: [
                    "Safe and Secure",
                    "Will park again!",
                    "Accomodating",
                    "Clean Parking",
                    "Easy to find",
                  ]
                  .map(
                    (tag) => QuickReviewTile(
                      label: tag,
                      onTagSelected: (tagSelected) {
                        if (tagSelected) {
                          selectedTags.add(tag);
                        } else {
                          selectedTags.remove(tag);
                        }
                      },
                    ),
                  )
                  .toList(),
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
            onPressed: rate == 0 ? null : () async {
                    int points = 0;

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => WillPopScope(
                        onWillPop: () async => false,
                        child: const NoticeDialog(
                          imageLink: "assets/logo/lets-park-logo.png",
                          message: "Saving review...",
                          forLoading: true,
                        ),
                      ),
                    );

                    if (rate == 5){
                      selectedTags.isNotEmpty ? points = 3 : points = 2;
                      
                    } else if (rate == 4){
                      selectedTags.isNotEmpty ? points = 2 : points = 1;
                    }

                    UserServices.updateReviewNotificationStatus(
                      FirebaseAuth.instance.currentUser!.uid,
                      widget.notificationId,
                    );

                    await ParkingSpaceServices.updateParkingReviews(
                      widget.spaceId,
                      Review(
                        FirebaseAuth.instance.currentUser!.photoURL,
                        FirebaseAuth.instance.currentUser!.displayName,
                        rate,
                        _infoController.text.trim(),
                        selectedTags,
                      ),
                    );

                    await ParkingSpaceServices.updateParkingSpaceRating(
                      widget.spaceId,
                      rate,
                    );

                    await ParkingSpaceServices.updatePoints(
                      widget.spaceId,
                      points,
                    );
                    
                    navigatorKey.currentState!.popUntil((route) => route.isFirst);
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => WillPopScope(
                        onWillPop: () async => false,
                        child: const NoticeDialog(
                          imageLink: "assets/logo/lets-park-logo.png",
                          message:
                              "Thanks for reviewing!\nYour review will help others to choose a better parking.",
                          forLoading: false,
                        ),
                      ),
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

  void getParkingReviews() async {
    int qty =
        await ParkingSpaceServices.getParkingReviewsQuantity(widget.spaceId)
            .then((value) => value);
    setState(() {
      reviewsQty = qty;
    });
  }
}

typedef void OnTagSelected(bool selected);

class QuickReviewTile extends StatefulWidget {
  final String label;
  final OnTagSelected onTagSelected;
  const QuickReviewTile(
      {Key? key, required this.label, required this.onTagSelected})
      : super(key: key);

  @override
  State<QuickReviewTile> createState() => _QuickReviewTileState();
}

class _QuickReviewTileState extends State<QuickReviewTile> {
  bool tagSelected = false;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              tagSelected = !tagSelected;
              widget.onTagSelected(tagSelected);
            });
          },
          child: Container(
            height: 35,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: tagSelected ? Colors.blue[400] : Colors.white,
              border: Border.all(
                color: tagSelected ? Colors.white : Colors.black26,
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.label,
                style: TextStyle(
                  color: tagSelected ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }
}
