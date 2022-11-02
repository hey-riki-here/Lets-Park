// ignore_for_file: avoid_function_literals_in_foreach_calls, import_of_legacy_library_into_null_safe

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:galleryimage/galleryimage.dart';
import 'package:lets_park/models/parking_space.dart';
import 'package:lets_park/models/review.dart';
import 'package:lets_park/screens/popups/checkout.dart';
import 'package:lets_park/screens/popups/checkout_monthly.dart';
import 'package:lets_park/screens/popups/email_verification.dart';
import 'package:lets_park/screens/popups/notice_dialog.dart';
import 'package:lets_park/services/firebase_api.dart';
import 'package:lets_park/services/parking_space_services.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:lets_park/services/user_services.dart';
import 'package:location/location.dart';
import 'package:lets_park/globals/globals.dart' as globals;
import 'package:url_launcher/url_launcher.dart' as launcher;

class ParkingAreaInfo extends StatefulWidget {
  final ParkingSpace parkingSpace;
  const ParkingAreaInfo({
    Key? key,
    required this.parkingSpace,
  }) : super(key: key);

  @override
  State<ParkingAreaInfo> createState() => _ParkingAreaInfoState();
}

class _ParkingAreaInfoState extends State<ParkingAreaInfo> {
  String destinationDistance = "";
  bool isLocationEnabled = false;

  @override
  void initState() {
    toDestination();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Parking Area Info"),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Image.asset(
                "assets/icons/marker.png",
                width: 25,
              ),
            ),
          ],
          bottom: PreferredSize(
            child: Container(
              color: Colors.white,
              height: 351,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Header(
                      imageUrl: widget.parkingSpace.getImageUrl!,
                      address: widget.parkingSpace.getAddress!,
                      type: widget.parkingSpace.getType!,
                      dailyOrMonthly: widget.parkingSpace.getDailyOrMonthly!,
                      stars: widget.parkingSpace.getRating!,
                      isLocationEnabled: isLocationEnabled,
                      spaceId: widget.parkingSpace.getSpaceId!,
                    ),
                  ),
                  PriceAndDistance(
                    distance: destinationDistance,
                    isLocationEnabled: isLocationEnabled,
                    dailyOrMonthly: widget.parkingSpace.getDailyOrMonthly!,
                  ),
                  const TabBar(
                    labelColor: Colors.black,
                    indicatorColor: Colors.black,
                    indicatorSize: TabBarIndicatorSize.label,
                    tabs: [
                      Tab(
                        child: Text(
                          "Information",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Tab(
                        child: Text(
                          "Certificates",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Tab(
                        child: Text(
                          "Attendant",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Tab(
                        child: Text(
                          "Reviews",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            preferredSize: const Size.fromHeight(351),
          ),
        ),
        body: InfoReviewsCaretaker(
          spaceId: widget.parkingSpace.getSpaceId!,
          info: widget.parkingSpace.getInfo!,
          rules: widget.parkingSpace.getRules!,
          features: widget.parkingSpace.getFeatures!,
          capacity: widget.parkingSpace.getCapacity!,
          verticalClearance: widget.parkingSpace.getVerticalClearance!,
          type: widget.parkingSpace.getType!,
          caretakerPhotoUrl: widget.parkingSpace.getCaretakerPhotoUrl!,
          caretakerName: widget.parkingSpace.getCaretakerName!,
          caretakerPhoneNumber: widget.parkingSpace.getCaretakerPhoneNumber!,
          certificatesUrl: widget.parkingSpace.getCertificates!,
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 80,
          ),
          child: ElevatedButton(
            onPressed: () async {
              if (FirebaseAuth.instance.currentUser!.emailVerified == false) {
                showAlertDialog(
                  "Looks like your email is not yet verified. Please verify the email to continue renting the parking space.",
                );
                return;
              }
              globals.nonReservable = widget.parkingSpace;
              widget.parkingSpace.getDailyOrMonthly!.compareTo("Monthly") == 0
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (context) => CheckoutMonthly(
                          parkingSpace: widget.parkingSpace,
                        ),
                      ),
                    )
                  : widget.parkingSpace.getType!.compareTo("Reservable") == 0
                      ? Navigator.push(
                          context,
                          MaterialPageRoute(
                            fullscreenDialog: true,
                            builder: (context) => Checkout(
                              parkingSpace: widget.parkingSpace,
                            ),
                          ),
                        )
                      : showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (context) => NoticeDialog(
                            imageLink: "assets/logo/lets-park-logo.png",
                            header:
                                "You're about to rent a non-reservable space...",
                            parkingAreaAddress: widget.parkingSpace.getAddress!,
                            message:
                                "Please confirm that you are currently at the parking location.",
                            forNonreservableConfirmation: true,
                          ),
                        );
            },
            child: const Text(
              "Rent parking space",
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

  void showAlertDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Center(
          child: Image.asset(
            "assets/logo/app_icon.png",
            scale: 20,
          ),
        ),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Verify Email Address",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: const BorderRadius.all(Radius.circular(8)),
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
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("MAYBE LATER"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (context) => const EmailVerification(),
                ),
              );
            },
            child: const Text("VERIFY EMAIL NOW"),
          ),
        ],
      ),
    );
  }

  void toDestination() async {
    if (mounted) {
      Location location = Location();

      bool _serviceEnabled;
      _serviceEnabled = await location.serviceEnabled();
      if (_serviceEnabled) {
        setState(() {
          isLocationEnabled = true;
        });
      }
      var position = await geolocator.Geolocator().getCurrentPosition(
          desiredAccuracy: geolocator.LocationAccuracy.high);

      double distance = FirebaseServices.calculateDistance(
        position.latitude,
        position.longitude,
        widget.parkingSpace.getLatLng!.latitude,
        widget.parkingSpace.getLatLng!.longitude,
      );
      if (mounted) {
        setState(() {
          destinationDistance = getDistance(distance);
          isLocationEnabled = true;
        });
      }
    }
  }

  String getDistance(double distance) {
    int newDistance = 0;
    if (distance < 1) {
      newDistance = (distance * 1000).toInt();
      return "$newDistance m";
    } else {
      newDistance = distance.toInt();
      return "$newDistance km";
    }
  }
}

class Header extends StatefulWidget {
  final String imageUrl;
  final String address;
  final String type;
  final String dailyOrMonthly;
  final double stars;
  final bool isLocationEnabled;
  final String spaceId;
  const Header({
    Key? key,
    required this.imageUrl,
    required this.address,
    required this.type,
    required this.dailyOrMonthly,
    required this.stars,
    required this.isLocationEnabled,
    required this.spaceId,
  }) : super(key: key);

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  Icon _favIcon = Icon(
    Icons.star_border_rounded,
    color: Colors.amber[300],
  );
  bool _added = false;
  String _label = "Add to Favorites";
  int sessionsQty = 0, reviewsQty = 0;

  @override
  void initState() {
    _favIcon = Icon(
      globals.favorites.contains(widget.spaceId)
          ? Icons.star_rounded
          : Icons.star_border_rounded,
      color: Colors.amber[300],
    );

    _added = globals.favorites.contains(widget.spaceId) ? true : false;

    _label = globals.favorites.contains(widget.spaceId)
        ? "Added to Favorites"
        : "Add to Favorites";

    getParkingReviews();
    getParkingSessions();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.address,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    ParkingSpaceServices.getStars(widget.stars),
                    const SizedBox(width: 5),
                    Text(
                      "($reviewsQty)",
                      style: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue[400],
                        borderRadius:
                            const BorderRadius.all(Radius.circular(3)),
                      ),
                      padding: const EdgeInsets.all(3),
                      child: Text(
                        widget.type,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.orange[400],
                        borderRadius:
                            const BorderRadius.all(Radius.circular(3)),
                      ),
                      padding: const EdgeInsets.all(3),
                      child: Text(
                        widget.dailyOrMonthly,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.green[400],
                        borderRadius:
                            const BorderRadius.all(Radius.circular(3)),
                      ),
                      padding: const EdgeInsets.all(3),
                      child: Text(
                        "($sessionsQty Parkings)",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  if (_added) {
                    _favIcon = Icon(
                      Icons.star_border_rounded,
                      color: Colors.amber[300],
                    );
                    _label = "Add to Favorites";
                    showNotice(
                      context,
                      "Parking space remove from My Favorites",
                    );
                    UserServices.removeSpaceonFavorites(
                      FirebaseAuth.instance.currentUser!.uid,
                      widget.spaceId,
                    );
                    _added = false;
                  } else {
                    _favIcon = Icon(
                      Icons.star_rounded,
                      color: Colors.amber[300],
                    );
                    _label = "Added to Favorites";
                    showNotice(context, "Parking space added to My Favorites");
                    UserServices.addSpaceonFavorites(
                      FirebaseAuth.instance.currentUser!.uid,
                      widget.spaceId,
                    );
                    _added = true;
                  }
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Colors.black54,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Row(
                    children: [
                      _favIcon,
                      Text(
                        _label,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Center(
          child: Container(
            width: 240,
            height: 140,
            decoration: BoxDecoration(
              border: Border.all(width: 1),
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void showNotice(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void getParkingSessions() async {
    int qty =
        await ParkingSpaceServices.getParkingSessionQuantity(widget.spaceId)
            .then((value) => value);
    setState(() {
      sessionsQty = qty;
    });
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

class PriceAndDistance extends StatefulWidget {
  final String dailyOrMonthly;
  final String distance;
  final bool isLocationEnabled;
  const PriceAndDistance({
    Key? key,
    required this.distance,
    required this.isLocationEnabled,
    required this.dailyOrMonthly,
  }) : super(key: key);

  @override
  State<PriceAndDistance> createState() => _PriceAndDistanceState();
}

class _PriceAndDistanceState extends State<PriceAndDistance> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      width: double.infinity,
      height: 50,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        widget.dailyOrMonthly.compareTo("Daily") == 0
                            ? "50.00"
                            : "1500.00",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text("Price"),
                    ],
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      showAlertDialog(
                        widget.dailyOrMonthly.compareTo("Daily") == 0
                            ? "The flat rate for parking is 50.00 and an additional 10.00 for each succeeding hour."
                            : "The fee for monthly parking is 1500.00 for each month.",
                      );
                    },
                    child: const Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                    ),
                  ),
                ],
              ),
              Container(
                color: Colors.black54,
                width: 1,
                height: 30,
              ),
              !widget.isLocationEnabled
                  ? Column(
                      children: [
                        Icon(
                          Icons.location_off_rounded,
                          color: Colors.red[300],
                        ),
                        const Text("Location service disabled."),
                      ],
                    )
                  : widget.distance.isNotEmpty
                      ? Column(
                          children: [
                            Text(
                              "About ${widget.distance}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text("To Destination"),
                          ],
                        )
                      : Column(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.grey.shade500,
                                strokeWidth: 3,
                              ),
                            ),
                            const Text("Calculating distance"),
                          ],
                        ),
            ],
          ),
        ],
      ),
    );
  }

  void showAlertDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Center(
          child: Image.asset(
            "assets/logo/app_icon.png",
            scale: 20,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Price info",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: const BorderRadius.all(Radius.circular(8)),
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
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}

class InfoReviewsCaretaker extends StatelessWidget {
  final String spaceId;
  final String info;
  final String rules;
  final List<String> features;
  final int capacity;
  final double verticalClearance;
  final String type;
  final String caretakerPhotoUrl;
  final String caretakerName;
  final String caretakerPhoneNumber;
  final List<String> certificatesUrl;
  const InfoReviewsCaretaker({
    Key? key,
    required this.spaceId,
    required this.info,
    required this.rules,
    required this.features,
    required this.capacity,
    required this.verticalClearance,
    required this.type,
    required this.caretakerPhotoUrl,
    required this.caretakerName,
    required this.caretakerPhoneNumber,
    required this.certificatesUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(
      fontSize: 20,
      color: Colors.grey,
    );

    const valueStyle = TextStyle(
      fontSize: 19,
    );

    final List<Review> reviews = [];
    return TabBarView(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 10),
                      Text("This parking space is ${type.toLowerCase()}."),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  info,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Rules",
                  style: labelStyle,
                ),
                const SizedBox(height: 12),
                Text(
                  rules,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Features",
                  style: labelStyle,
                ),
                const SizedBox(height: 12),
                getFeatures(),
                const SizedBox(height: 20),
                const Text(
                  "Capacity",
                  style: labelStyle,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      CommunityMaterialIcons.car,
                      color: Colors.blue,
                      size: 30,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "$capacity",
                      style: valueStyle,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  "Vertical Clearance",
                  style: labelStyle,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      CommunityMaterialIcons.table_row_height,
                      color: Colors.blue,
                      size: 30,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "$verticalClearance m.",
                      style: valueStyle,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 30,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              "The images below are the certificates of the owner for the parking space that shows the legality of the business as well as the legality of the parking space.",
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                GalleryImage(
                  titleGallery: "Business Certificates",
                  numOfShowImages: 3,
                  imageUrls: certificatesUrl,
                ),
              ],
            ),
          ),
        ),
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info,
                            color: Colors.green.shade700,
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              "Have queries about parking? You can always call the parking space's attendant.",
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          primary: Colors.green,
                        ),
                        onPressed: () async {
                          final url = "tel:09$caretakerPhoneNumber";
                          if (await launcher.canLaunchUrl(Uri.parse(url))) {
                            await launcher.launchUrl(Uri.parse(url));
                          } else {
                            throw 'Could not launch $url';
                          }
                        },
                        icon: const Icon(Icons.phone_in_talk_rounded),
                        label: const Text("Call attendant"),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                CircleAvatar(
                  backgroundColor: Colors.black12,
                  backgroundImage: NetworkImage(
                    caretakerPhotoUrl,
                  ),
                  radius: 40,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Name",
                  style: labelStyle,
                ),
                const SizedBox(height: 12),
                Text(
                  caretakerName,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Phone number",
                  style: labelStyle,
                ),
                const SizedBox(height: 12),
                Text(
                  "09$caretakerPhoneNumber",
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        Center(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: ParkingSpaceServices.getParkingSpaceReviews(spaceId),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                reviews.clear();
                snapshot.data!.docs.forEach((review) {
                  reviews.add(Review.fromJson(review.data()));
                });
              }
              int tag1Qty = 0,
                  tag2Qty = 0,
                  tag3Qty = 0,
                  tag4Qty = 0,
                  tag5Qty = 0;
              reviews.forEach((review) {
                review.getQuickReviews!.forEach((tag) {
                  if (tag.compareTo("Safe and Secure") == 0) {
                    tag1Qty += 1;
                  } else if (tag.compareTo("Will park again!") == 0) {
                    tag2Qty += 1;
                  } else if (tag.compareTo("Accomodating") == 0) {
                    tag3Qty += 1;
                  } else if (tag.compareTo("Clean Parking") == 0) {
                    tag4Qty += 1;
                  } else {
                    tag5Qty += 1;
                  }
                });
              });

              return reviews.isEmpty
                  ? Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.info_outline,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "No reviews yet.",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: reviews.length,
                      itemBuilder: (context, index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            index == 0
                                ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Wrap(
                                        alignment: WrapAlignment.center,
                                        direction: Axis.horizontal,
                                        runSpacing: 10,
                                        children: [
                                          "Safe and Secure ($tag1Qty)",
                                          "Will park again! ($tag2Qty)",
                                          "Accomodating ($tag3Qty)",
                                          "Clean Parking ($tag4Qty)",
                                          "Easy to find ($tag5Qty)",
                                        ]
                                            .map(
                                              (tag) => QuickReviewTile(
                                                label: tag,
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                  )
                                : const SizedBox(),
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.white,
                                  backgroundImage: NetworkImage(
                                      reviews[index].getDisplayPhoto!),
                                  radius: 15,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  reviews[index].getReviewer!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: const [
                                      Icon(
                                        Icons.more_vert_rounded,
                                        color: Colors.black54,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            ParkingSpaceServices.getStars(
                              reviews[index].getRating!,
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              alignment: WrapAlignment.start,
                              direction: Axis.horizontal,
                              runSpacing: 10,
                              children: reviews[index]
                                  .getQuickReviews!
                                  .map(
                                    (tag) => QuickReviewTile(
                                      label: tag,
                                    ),
                                  )
                                  .toList(),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              reviews[index].getReview!,
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                            ),
                            const Center(
                              child: SizedBox(
                                height: 30,
                                width: 30,
                                child: Divider(
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
            },
          ),
        ),
      ],
    );
  }

  Widget getFeatures() {
    List<Widget> newChildren = [];

    for (String feature in features) {
      if (feature.compareTo("With gate") == 0) {
        newChildren.add(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                CommunityMaterialIcons.gate,
                color: Colors.blue,
                size: 30,
              ),
              const SizedBox(width: 12),
              Text(
                feature,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 15),
            ],
          ),
        );
      } else if (feature.compareTo("CCTV") == 0) {
        newChildren.add(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                CommunityMaterialIcons.cctv,
                color: Colors.blue,
                size: 30,
              ),
              const SizedBox(width: 12),
              Text(
                feature,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 15),
            ],
          ),
        );
      } else if (feature.compareTo("Covered Parking") == 0) {
        newChildren.add(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                CommunityMaterialIcons.bus_stop_covered,
                color: Colors.blue,
                size: 30,
              ),
              const SizedBox(width: 12),
              Text(
                feature,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      } else {
        newChildren.add(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                CommunityMaterialIcons.lightbulb_on_outline,
                color: Colors.blue,
                size: 30,
              ),
              const SizedBox(width: 12),
              Text(
                feature,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      }
    }

    return Wrap(
      direction: Axis.horizontal,
      runSpacing: 10,
      children: newChildren,
    );
  }
}

class QuickReviewTile extends StatelessWidget {
  final String label;
  const QuickReviewTile({
    Key? key,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: Colors.white,
            border: Border.all(
              color: Colors.black26,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }
}
