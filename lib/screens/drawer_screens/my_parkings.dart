import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lets_park/globals/globals.dart' as globals;
import 'package:lets_park/models/parking.dart';
import 'package:lets_park/models/user_data.dart';
import 'package:lets_park/shared/navigation_drawer.dart';

class MyParkings extends StatefulWidget {
  final int _pageId = 3;
  const MyParkings({Key? key}) : super(key: key);

  @override
  _MyParkingsState createState() => _MyParkingsState();
}

class _MyParkingsState extends State<MyParkings> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              _scaffoldKey.currentState!.openDrawer();
            },
          ),
          elevation: 2,
          bottom: PreferredSize(
            child: Container(
              color: Colors.white,
              height: 120.0,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "My Parkings",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TabBar(
                    labelColor: Colors.black,
                    tabs: [
                      Tab(
                        child: Text(
                          "In Progress",
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),
                      ),
                      Tab(
                        child: Text(
                          "Upcoming",
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),
                      ),
                      Tab(
                        child: Text(
                          "History",
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
            preferredSize: const Size.fromHeight(120.0),
          ),
        ),
        backgroundColor: Colors.grey.shade300,
        drawer: NavigationDrawer(currentPage: widget._pageId),
        body: const TabBarView(
          children: [
            Center(
              child: InProgress(),
            ),
            Center(
              child: Text("Tab 2"),
            ),
            Center(
              child: Text("Tab 3"),
            ),
          ],
        ),
      ),
    );
  }
}

class InProgress extends StatefulWidget {
  const InProgress({Key? key}) : super(key: key);

  @override
  State<InProgress> createState() => _InProgressState();
}

class _InProgressState extends State<InProgress> {
  final textStyle = const TextStyle(
    fontSize: 16,
  );
  final UserData userData = globals.userData;

  @override
  Widget build(BuildContext context) {
    final List<Parking>? parkings = userData.getUserParkings;

    parkings!.sort((parkingA, parkingB) {
      int timeA = parkingA.getArrival! + parkingA.getDeparture!;
      int timeB = parkingB.getArrival! + parkingB.getDeparture!;
      return timeA.compareTo(timeB);
    });

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      scrollDirection: Axis.vertical,
      itemCount: parkings.length,
      itemBuilder: (context, index) {
        return Card(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(12),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(
                      "assets/icons/parking-marker.png",
                      scale: 2.7,
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          parkings[index].getAddress!,
                          style: textStyle,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          parkings[index].getPrice!.toString(),
                          style: textStyle,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      FontAwesomeIcons.carAlt,
                      color: Colors.blue,
                      size: 30,
                    ),
                    const SizedBox(width: 15),
                    Text(
                      parkings[index].getPlateNumber!,
                      style: textStyle,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: Colors.blue,
                      size: 30,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Arrived:",
                                style: textStyle,
                              ),
                              Text(
                                DateTime.fromMillisecondsSinceEpoch(
                                        parkings[index].getArrival!)
                                    .toString(),
                                style: textStyle.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Departure:",
                                style: textStyle,
                              ),
                              Text(
                                DateTime.fromMillisecondsSinceEpoch(
                                        parkings[index].getDeparture!)
                                    .toString(),
                                style: textStyle.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Time Remaining:",
                                style: textStyle,
                              ),
                              Text(
                                parkings[index].getDuration!,
                                style: textStyle.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () async {},
                      child: const Text(
                        "Extend",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.lightBlue,
                        fixedSize: const Size(85, 30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
