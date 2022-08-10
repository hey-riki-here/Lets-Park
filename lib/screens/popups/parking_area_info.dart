// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lets_park/models/parking_space.dart';
import 'package:lets_park/models/review.dart';
import 'package:lets_park/screens/popups/checkout.dart';
import 'package:lets_park/screens/popups/checkout_monthly.dart';
import 'package:lets_park/screens/popups/notice_dialog.dart';
import 'package:lets_park/services/firebase_api.dart';
import 'package:lets_park/services/parking_space_services.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:lets_park/services/user_services.dart';
import 'package:location/location.dart';
import 'package:lets_park/globals/globals.dart' as globals;

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
      length: 2,
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
              height: 375,
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
                            fontSize: 17,
                          ),
                        ),
                      ),
                      Tab(
                        child: Text(
                          "Reviews",
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            preferredSize: const Size.fromHeight(375),
          ),
        ),
        body: InfoAndReviews(
          spaceId: widget.parkingSpace.getSpaceId!,
          info: widget.parkingSpace.getInfo!,
          rules: widget.parkingSpace.getRules!,
          features: widget.parkingSpace.getFeatures!,
          capacity: widget.parkingSpace.getCapacity!,
          verticalClearance: widget.parkingSpace.getVerticalClearance!,
          type: widget.parkingSpace.getType!,
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 80,
          ),
          child: ElevatedButton(
            onPressed: () {
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

  @override
  void initState() {
    _favIcon = Icon(
      globals.favorites.contains(widget.spaceId)
          ? Icons.star_rounded
          : Icons.star_border_rounded,
      color: Colors.amber[300],
    );

    _added = globals.favorites.contains(widget.spaceId)
        ? true
        : false;

    _label = globals.favorites.contains(widget.spaceId)
        ? "Added to Favorites"
        : "Add to Favorites";
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
                ParkingSpaceServices.getStars(widget.stars),
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
        const SizedBox(height: 10),
        !widget.isLocationEnabled
            ? Row(
                children: [
                  Icon(
                    Icons.warning_rounded,
                    size: 20,
                    color: Colors.amber[700],
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Please turn on location service to calculate estimated distance",
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                ],
              )
            : const Text(""),
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
}

class PriceAndDistance extends StatelessWidget {
  final String distance;
  final bool isLocationEnabled;
  const PriceAndDistance({
    Key? key,
    required this.distance,
    required this.isLocationEnabled,
  }) : super(key: key);

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
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Text(
                    "50.00",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text("Price"),
                ],
              ),
              Container(
                color: Colors.black54,
                width: 1,
                height: 30,
              ),
              !isLocationEnabled
                  ? Column(
                      children: [
                        Icon(
                          Icons.location_off_rounded,
                          color: Colors.red[300],
                        ),
                        const Text("Location service disabled."),
                      ],
                    )
                  : distance.isNotEmpty
                      ? Column(
                          children: [
                            Text(
                              "About $distance",
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
}

class InfoAndReviews extends StatelessWidget {
  final String spaceId;
  final String info;
  final String rules;
  final List<String> features;
  final int capacity;
  final double verticalClearance;
  final String type;
  const InfoAndReviews({
    Key? key,
    required this.spaceId,
    required this.info,
    required this.rules,
    required this.features,
    required this.capacity,
    required this.verticalClearance,
    required this.type,
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
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 30,
          ),
          child: SingleChildScrollView(
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
                            Text(reviews[index].getReview!),
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
