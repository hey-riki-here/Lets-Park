import 'package:flutter/material.dart';
import 'package:lets_park/globals/globals.dart' as globals;
import 'package:lets_park/models/parking_space.dart';
import 'package:lets_park/screens/drawer_screens/manage_space/earnings_menu.dart';
import 'package:lets_park/screens/drawer_screens/manage_space/parking_history_menu.dart';
import 'package:lets_park/screens/drawer_screens/manage_space/upcoming_parkings_menu.dart';
import 'package:lets_park/screens/drawer_screens/manage_space/your_space.dart';
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
      backgroundColor: Colors.grey.shade300,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: const [
              Header(),
              AvailableSpacesList(),
              Menu(),
            ],
          ),
          const Padding(
            padding: EdgeInsets.all(4.0),
            child: Text(
              "• Let's Park!",
              style: TextStyle(
                letterSpacing: 2,
                fontSize: 20,
                color: Colors.grey,
              ),
            ),
          ),
        ],
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Center(
                    child: Text(
                      "Today",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      "P250.0",
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  Row(
                    children: [
                      Image.asset(
                        "assets/icons/parking-marker.png",
                        width: 25,
                      ),
                      const SizedBox(width: 20),
                      const Text(
                        "5 Parkings",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AvailableSpacesList extends StatefulWidget {
  const AvailableSpacesList({Key? key}) : super(key: key);

  @override
  State<AvailableSpacesList> createState() => _AvailableSpacesListState();
}

class _AvailableSpacesListState extends State<AvailableSpacesList> {
  List<ParkingSpace>? parkingSpaces = globals.userData.getOwnedParkingSpaces;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        scrollDirection: Axis.horizontal,
        itemCount: 10,
        itemBuilder: (BuildContext context, int index) {
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Space $index",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Center(
                        child: Container(
                          child: const Center(
                            child: Text(
                              "Test",
                              style: TextStyle(
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
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
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
                    goToRoute(context, YourSpace());
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
