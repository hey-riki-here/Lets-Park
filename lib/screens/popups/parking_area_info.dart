import 'package:flutter/material.dart';
import 'package:lets_park/models/parking_space.dart';
import 'package:lets_park/screens/popups/checkout.dart';

class ParkingAreaInfo extends StatelessWidget {
  final ParkingSpace parkingSpace;
  const ParkingAreaInfo({Key? key, required this.parkingSpace})
      : super(key: key);

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
              height: 350,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Header(
                      imageUrl: parkingSpace.getImageUrl!,
                      address: parkingSpace.getAddress!,
                      type: parkingSpace.getType!,
                    ),
                  ),
                  const PriceAndDistance(),
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
            preferredSize: const Size.fromHeight(350),
          ),
        ),
        body: InfoAndReviews(
          info: parkingSpace.getInfo!,
          features: parkingSpace.getFeatures!,
          capacity: parkingSpace.getCapacity!,
          verticalClearance: parkingSpace.getVerticalClearance!,
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
                  builder: (context) => Checkout(parkingSpace: parkingSpace),
                ),
              );
            },
            child: const Text(
              "Checkout",
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
}

class Header extends StatelessWidget {
  final String imageUrl;
  final String address;
  final String type;
  const Header(
      {Key? key,
      required this.imageUrl,
      required this.address,
      required this.type})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          address,
          style: const TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        Row(
          children: [
            Icon(
              Icons.star,
              color: Colors.yellow.shade600,
              size: 15,
            ),
            Icon(
              Icons.star,
              color: Colors.yellow.shade600,
              size: 15,
            ),
            Icon(
              Icons.star,
              color: Colors.yellow.shade600,
              size: 15,
            ),
            Icon(
              Icons.star,
              color: Colors.yellow.shade600,
              size: 15,
            ),
            Icon(
              Icons.star,
              color: Colors.yellow.shade600,
              size: 15,
            ),
          ],
        ),
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
      ],
    );
  }
}

class PriceAndDistance extends StatelessWidget {
  const PriceAndDistance({Key? key}) : super(key: key);

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
              Column(
                children: const [
                  Text(
                    "1 km",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text("To Destination"),
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
  final String info;
  final List<String> features;
  final int capacity;
  final double verticalClearance;
  const InfoAndReviews({
    Key? key,
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

    return SingleChildScrollView(
      child: SizedBox(
        height: 400,
        child: TabBarView(
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
                    Text(
                      formatFeatures(),
                      style: valueStyle,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Capacity",
                      style: labelStyle,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "$capacity",
                      style: valueStyle,
                    ),
                    const SizedBox(height: 20),
                    const Text("Vertical Clearance", style: labelStyle),
                    const SizedBox(height: 12),
                    Text(
                      "$verticalClearance m.",
                      style: valueStyle,
                    ),
                  ],
                ),
              ),
            ),
            const Center(
              child: Text("Tab 2"),
            ),
          ],
        ),
      ),
    );
  }

  String formatFeatures() {
    String formattedFeatures = "";
    for (String feature in features) {
      formattedFeatures += " - " + feature + "\n";
    }
    return formattedFeatures;
  }
}
