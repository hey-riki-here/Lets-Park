// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lets_park/models/parking_space.dart';
import 'package:lets_park/screens/drawer_screens/manage_space/earnings_menu.dart';
import 'package:lets_park/screens/drawer_screens/manage_space/parking_history_menu.dart';
import 'package:lets_park/screens/drawer_screens/manage_space/space.dart';
import 'package:lets_park/screens/drawer_screens/manage_space/upcoming_parkings_menu.dart';
import 'package:lets_park/screens/drawer_screens/manage_space/your_space.dart';
import 'package:lets_park/screens/drawer_screens/register_screens/register_area.dart';
import 'package:lets_park/services/parking_space_services.dart';
import 'package:lets_park/shared/navigation_drawer.dart';
import 'package:lets_park/shared/shared_widgets.dart';

class ManageSpace extends StatelessWidget {
  final int _pageId = 6;
  const ManageSpace({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _scaffoldKey = GlobalKey<ScaffoldState>();
    final SharedWidget _sharedWidgets = SharedWidget();
    return Scaffold(
      key: _scaffoldKey,
      appBar: _sharedWidgets.appbarDrawer(
        title: "Manage your space",
        onPressed: () {
          _scaffoldKey.currentState!.openDrawer();
        },
      ),
      drawer: NavigationDrawer(currentPage: _pageId),
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Header(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 9.0, vertical: 1.0),
              child: Text(
                "Spaces and Earnings",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
            ),
            SpacesAndEarningsWiget(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 9.0, vertical: 1.0),
              child: Text(
                "Menu",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
            ),
            Menu(),
          ],
        ),
      ),
    );
  }
}

class Header extends StatelessWidget {
  const Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Card(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(12),
              ),
            ),
            elevation: 5,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade900,
                    Colors.blue.shade300,
                  ],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  stops: const [0.0, 1.0],
                  tileMode: TileMode.clamp,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Center(
                      child: Text(
                        "Let's Park!",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade200,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Card(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              "assets/logo/app_icon.png",
                              width: 50,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla dapibus ex nulla, ac pharetra tellus blandit non. Integer pretium blandit interdum. Vivamus sit amet enim ante. Sed vitae volutpat nisi, sit amet dapibus ipsum.",
                            style: TextStyle(
                              color: Colors.grey.shade200,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: ((context) => const RegisterArea()),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Want to earn more?",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade200,
                            ),
                          ),
                          Card(
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                            color: Colors.blue.shade400,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 3,
                              ),
                              child: Text(
                                "+ Add more space",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SpacesAndEarningsWiget extends StatefulWidget {
  const SpacesAndEarningsWiget({Key? key}) : super(key: key);

  @override
  State<SpacesAndEarningsWiget> createState() => _SpacesAndEarningsWigetState();
}

class _SpacesAndEarningsWigetState extends State<SpacesAndEarningsWiget> {
  List<ParkingSpace>? activeParkingSpaces = [];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: ParkingSpaceServices.getActiveParkingSpaces(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            activeParkingSpaces = [];
            snapshot.data!.docs.forEach((space) {
              activeParkingSpaces!.add(ParkingSpace.fromJson(space.data()));
            });
          }
          return SizedBox(
            height: activeParkingSpaces!.isEmpty ? 100 : 275,
            child: activeParkingSpaces!.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(12),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: Text(
                            "There are no currently active parking spaces.",
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    scrollDirection: Axis.horizontal,
                    itemCount: activeParkingSpaces!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return SpaceCard(
                        index: index,
                        space: activeParkingSpaces![index],
                      );
                    },
                  ),
          );
        });
  }
}

class SpaceCard extends StatefulWidget {
  final ParkingSpace space;
  final int index;
  const SpaceCard({
    Key? key,
    required this.index,
    required this.space,
  }) : super(key: key);

  @override
  State<SpaceCard> createState() => _SpaceCardState();
}

class _SpaceCardState extends State<SpaceCard> {
  final colors = [
    {'fore': Colors.blue.shade600, 'back': Colors.blue.shade100},
    {'fore': Colors.red.shade600, 'back': Colors.red.shade100},
    {'fore': Colors.amber.shade600, 'back': Colors.amber.shade100},
  ];

  @override
  Widget build(BuildContext context) {
    final space = widget.space;
    final index = widget.index;

    return Card(
      elevation: 2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(12),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: colors[index]['back'],
                  ),
                ),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: colors[index]['fore'],
                  ),
                  child: Center(
                    child: Text(
                      "${index + 1}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.red[400],
                  size: 17,
                ),
                const SizedBox(width: 8),
                space.getAddress!.length <= 30
                    ? Text(
                        space.getAddress!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : Text(
                        space.getAddress!.substring(0, 29) + "...",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ],
            ),
            const SizedBox(height: 10),
            Center(
              child: Row(
                children: [
                  AvailableSpaceWidget(space: space),
                  const SizedBox(width: 10),
                  EarningsWidget(space: space),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Space(
                          space: space,
                          title: "${index + 1}",
                        ),
                      ),
                    );
                  },
                  child: const Text("View space"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AvailableSpaceWidget extends StatefulWidget {
  final ParkingSpace space;
  const AvailableSpaceWidget({
    Key? key,
    required this.space,
  }) : super(key: key);

  @override
  State<AvailableSpaceWidget> createState() => _AvailableSpaceWidgetState();
}

class _AvailableSpaceWidgetState extends State<AvailableSpaceWidget> {
  @override
  Widget build(BuildContext context) {
    final space = widget.space;
    final capacity = space.getCapacity!;
    int availableSlot = 0;

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: ParkingSpaceServices.getParkingSessionsDocs(space.getSpaceId!),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            int occupied = 0;
            snapshot.data!.docs.forEach((parking) {
              if (parking.data()["inProgress"] == true) {
                occupied++;
              }
            });
            availableSlot = capacity - occupied;
          }

          return Column(
            children: [
              Card(
                elevation: 0,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(5),
                  ),
                ),
                color: Colors.blue.shade50,
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Available Space",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                child: Center(
                  child: Text(
                    "$availableSlot",
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(100),
                  ),
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.green,
                    width: 2,
                  ),
                ),
              ),
            ],
          );
        });
  }
}

class EarningsWidget extends StatefulWidget {
  final ParkingSpace space;
  const EarningsWidget({
    Key? key,
    required this.space,
  }) : super(key: key);

  @override
  State<EarningsWidget> createState() => _EarningsWidgetState();
}

class _EarningsWidgetState extends State<EarningsWidget> {
  @override
  Widget build(BuildContext context) {
    final space = widget.space;
    double earned = 0;
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: ParkingSpaceServices.getEearningsToday(space.getSpaceId!),
        builder: (context, snapshot) {
          earned = 0;
          if (snapshot.hasData) {
            snapshot.data!.docs.forEach((session) {
              earned += session.data()['price'];
            });
          }
          return Column(
            children: [
              Card(
                elevation: 0,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(5),
                  ),
                ),
                color: Colors.blue.shade50,
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Earnings Today",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                child: Center(
                  child: Text(
                    "$earned",
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(100),
                  ),
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.green,
                    width: 2,
                  ),
                ),
              ),
            ],
          );
        });
  }
}

class Menu extends StatelessWidget {
  const Menu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Card(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(12),
              ),
            ),
            elevation: 5,
            child: Column(
              children: [
                buildMenuItem(
                  label: "Your spaces",
                  insets: const EdgeInsets.all(10),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    topLeft: Radius.circular(12),
                  ),
                  subLabel: "View all your spaces",
                  onTap: () {
                    goToRoute(context, const YourSpace());
                  },
                ),
                Container(
                  height: 1,
                  color: Colors.black26,
                ),
                buildMenuItem(
                  label: "Earnings",
                  insets: const EdgeInsets.all(10),
                  borderRadius: const BorderRadius.all(Radius.zero),
                  subLabel: "View your daily and monthly earnings",
                  onTap: () => goToRoute(context, const Earnings()),
                ),
                Container(
                  height: 1,
                  color: Colors.black26,
                ),
                buildMenuItem(
                  label: "Upcoming Parkings",
                  insets: const EdgeInsets.all(10),
                  borderRadius: const BorderRadius.all(Radius.zero),
                  subLabel: "View upcoming parkings",
                  onTap: () => goToRoute(context, const UpcomingParkingsMenu()),
                ),
                Container(
                  height: 1,
                  color: Colors.black26,
                ),
                buildMenuItem(
                  label: "Parkings History",
                  insets: const EdgeInsets.all(10),
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  subLabel: "Keep track of your space's parking session",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ParkingHistoryMenu(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMenuItem({
    required String label,
    required EdgeInsets insets,
    required BorderRadius borderRadius,
    required String subLabel,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      child: Padding(
        padding: insets,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
                Text(
                  subLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: Colors.grey.shade700,
            ),
          ],
        ),
      ),
    );
  }

  void goToRoute(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: ((context) => page),
      ),
    );
  }
}
