// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:lets_park/models/parking_space.dart';
import 'package:lets_park/models/review.dart';
import 'package:lets_park/screens/popups/checkout.dart';
import 'package:lets_park/services/firebase_api.dart';
import 'package:lets_park/services/parking_space_services.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:location/location.dart';

class ParkingAreaInfo extends StatefulWidget {
  final ParkingSpace parkingSpace;
  const ParkingAreaInfo({Key? key, required this.parkingSpace})
      : super(key: key);

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
              height: 365,
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
                      stars: widget.parkingSpace.getRating!,
                      isLocationEnabled: isLocationEnabled,
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
            preferredSize: const Size.fromHeight(365),
          ),
        ),
        body: InfoAndReviews(
          spaceId: widget.parkingSpace.getSpaceId!,
          info: widget.parkingSpace.getInfo!,
          features: widget.parkingSpace.getFeatures!,
          capacity: widget.parkingSpace.getCapacity!,
          verticalClearance: widget.parkingSpace.getVerticalClearance!,
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 80,
          ),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (context) =>
                      Checkout(parkingSpace: widget.parkingSpace),
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
      setState(() {
        destinationDistance = getDistance(distance);
        isLocationEnabled = true;
      });
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

class Header extends StatelessWidget {
  final String imageUrl;
  final String address;
  final String type;
  final double stars;
  final bool isLocationEnabled;
  const Header({
    Key? key,
    required this.imageUrl,
    required this.address,
    required this.type,
    required this.stars,
    required this.isLocationEnabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          address,
          style: const TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.w400,
          ),
        ),
        ParkingSpaceServices.getStars(stars),
        Text(
          type,
          style: const TextStyle(
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Container(
            width: 250,
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(width: 1),
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        !isLocationEnabled
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
  final List<String> features;
  final int capacity;
  final double verticalClearance;
  const InfoAndReviews({
    Key? key,
    required this.spaceId,
    required this.info,
    required this.features,
    required this.capacity,
    required this.verticalClearance,
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
                Text(
                  info,
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
              }),
        ),
      ],
    );
  }

  Row getFeatures() {
    List<Widget> newChildren = [];

    for (String feature in features) {
      if (feature.compareTo("With gate") == 0) {
        newChildren.add(
          Row(
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
      } else {
        newChildren.add(
          Row(
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
      }
    }
    return Row(children: newChildren);
  }
}
