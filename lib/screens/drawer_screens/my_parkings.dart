// ignore_for_file: empty_catches, unused_catch_clause, avoid_function_literals_in_foreach_calls

import 'package:android_intent_plus/android_intent.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lets_park/globals/globals.dart' as globals;
import 'package:lets_park/models/parking.dart';
import 'package:lets_park/models/user_data.dart';
import 'package:lets_park/services/user_services.dart';
import 'package:lets_park/shared/navigation_drawer.dart';

class MyParkings extends StatefulWidget {
  final int _pageId = 3;
  final int initialIndex;
  const MyParkings({Key? key, required this.initialIndex}) : super(key: key);

  @override
  _MyParkingsState createState() => _MyParkingsState();
}

class _MyParkingsState extends State<MyParkings> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final UserServices _userServices = UserServices();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: widget.initialIndex,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.stop,
                color: Colors.black,
              ),
            ),
          ],
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
              height: 120,
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
            preferredSize: const Size.fromHeight(120),
          ),
        ),
        backgroundColor: Colors.grey.shade300,
        drawer: NavigationDrawer(currentPage: widget._pageId),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _userServices.getUserParkingData()!,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Parking> inProgress = [];
                List<Parking> upcoming = [];
                List<Parking> history = [];

                List<Parking> parkings = [];
                snapshot.data!.docs.forEach((parking) {
                  parkings.add(Parking.fromJson(parking.data()));
                });

                for (var parking in parkings) {
                  if (parking.isInProgress == true) {
                    inProgress.add(parking);
                  } else if (parking.isUpcoming == true) {
                    upcoming.add(parking);
                  } else {
                    history.add(parking);
                  }
                }
                return TabBarView(
                  children: [
                    Center(
                      child: InProgress(inProgressParkings: inProgress),
                    ),
                    Center(
                      child: Upcoming(upcomingParkings: upcoming),
                    ),
                    Center(
                      child: History(parkingHistory: history),
                    ),
                  ],
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
      ),
    );
  }

  void showNotice(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class InProgress extends StatefulWidget {
  final List<Parking> inProgressParkings;
  const InProgress({Key? key, required this.inProgressParkings})
      : super(key: key);

  @override
  State<InProgress> createState() => InProgressState();
}

class InProgressState extends State<InProgress> {
  final textStyle = const TextStyle(
    fontSize: 16,
  );
  final UserData userData = globals.userData;

  @override
  Widget build(BuildContext context) {
    final List<Parking>? parkings = widget.inProgressParkings;

    parkings!.sort((parkingA, parkingB) {
      int timeA = parkingA.getArrival! + parkingA.getDeparture!;
      int timeB = parkingB.getArrival! + parkingB.getDeparture!;
      return timeA.compareTo(timeB);
    });

    return ListView.builder(
      padding: const EdgeInsets.all(8),
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
              vertical: 15,
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            parkings[index].getAddress!,
                            overflow: TextOverflow.fade,
                            maxLines: 1,
                            softWrap: false,
                            style: textStyle,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            parkings[index].getPrice!.toString(),
                            style: textStyle,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        showModalBottomSheet<void>(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (BuildContext context) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              height: 320,
                              margin: const EdgeInsets.all(12),
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Center(
                                    child: Container(
                                      width: 200,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        border: Border.all(width: 1),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(12)),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          parkings[index].getImageUrl!,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    parkings[index].getAddress!,
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Text(
                                        "Parking space owner",
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        "Ricky Eredillas Jr.",
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  const Divider(),
                                  const SizedBox(height: 10),
                                  Card(
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Column(
                                            children: [
                                              IconButton(
                                                onPressed: () {},
                                                icon: Icon(
                                                  Icons.stop_circle_outlined,
                                                  color: Colors.red.shade300,
                                                ),
                                              ),
                                              const Text(
                                                "Stop",
                                                style: TextStyle(
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              IconButton(
                                                onPressed: () {},
                                                icon: Icon(
                                                  Icons.message_outlined,
                                                  color: Colors.blue.shade300,
                                                ),
                                              ),
                                              const Text(
                                                "Message",
                                                style: TextStyle(
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              IconButton(
                                                onPressed: () {},
                                                icon: Icon(
                                                  Icons.more_time_rounded,
                                                  color: Colors.green.shade300,
                                                ),
                                              ),
                                              const Text(
                                                "Extend",
                                                style: TextStyle(
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              IconButton(
                                                onPressed: () {},
                                                icon: const Icon(
                                                  Icons.location_on_outlined,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                              const Text(
                                                "Location",
                                                style: TextStyle(
                                                  color: Colors.black54,
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
                          },
                        );
                      },
                      icon: const Icon(
                        Icons.more_horiz_rounded,
                        color: Colors.black54,
                      ),
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
                                _getFormattedTime(
                                  DateTime.fromMillisecondsSinceEpoch(
                                    parkings[index].getArrival!,
                                  ),
                                ),
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
                                _getFormattedTime(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      parkings[index].getDeparture!),
                                ),
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
                                "Duration:",
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
              ],
            ),
          ),
        );
      },
    );
  }

  String _getFormattedTime(DateTime time) {
    String formattedTime = "";
    DateTime arrival = DateTime(
      time.year,
      time.month,
      time.day,
    );

    arrival.compareTo(_getDateTimeNow()) == 0
        ? formattedTime += "Today at "
        : formattedTime += DateFormat('MMM. dd, yyyy ').format(arrival) + "at ";
    formattedTime += DateFormat("h:mm a").format(time);
    return formattedTime;
  }

  DateTime _getDateTimeNow() {
    return DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
  }
}

class Upcoming extends StatefulWidget {
  final List<Parking> upcomingParkings;
  const Upcoming({Key? key, required this.upcomingParkings}) : super(key: key);

  @override
  State<Upcoming> createState() => _UpcomingState();
}

class _UpcomingState extends State<Upcoming> {
  final textStyle = const TextStyle(
    fontSize: 16,
  );
  final UserData userData = globals.userData;

  @override
  Widget build(BuildContext context) {
    final List<Parking>? parkings = widget.upcomingParkings;

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
                    Expanded(
                      child: Column(
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
                    ),
                    IconButton(
                      onPressed: () {
                        showModalBottomSheet<void>(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (BuildContext context) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              height: 320,
                              margin: const EdgeInsets.all(12),
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Center(
                                    child: Container(
                                      width: 200,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        border: Border.all(width: 1),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(12)),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          parkings[index].getImageUrl!,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    parkings[index].getAddress!,
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Parking space owner",
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        parkings[index].getParkingOwner!,
                                        style: const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  const Divider(),
                                  const SizedBox(height: 10),
                                  Card(
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Column(
                                            children: [
                                              IconButton(
                                                onPressed: () {},
                                                icon: Icon(
                                                  Icons.stop_circle_outlined,
                                                  color: Colors.red.shade300,
                                                ),
                                              ),
                                              const Text(
                                                "Stop",
                                                style: TextStyle(
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              IconButton(
                                                onPressed: () {},
                                                icon: Icon(
                                                  Icons.message_outlined,
                                                  color: Colors.blue.shade300,
                                                ),
                                              ),
                                              const Text(
                                                "Message",
                                                style: TextStyle(
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              IconButton(
                                                onPressed: () {},
                                                icon: Icon(
                                                  Icons.more_time_rounded,
                                                  color: Colors.green.shade300,
                                                ),
                                              ),
                                              const Text(
                                                "Extend",
                                                style: TextStyle(
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  final intent = AndroidIntent(
                                                      action: 'action_view',
                                                      data: Uri.encodeFull(
                                                          'google.navigation:q=14.70079467891017,+120.98280418664218&avoid=tf'),
                                                      package:
                                                          'com.google.android.apps.maps');
                                                  intent.launch();
                                                },
                                                icon: const Icon(
                                                  Icons.location_on_outlined,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                              const Text(
                                                "Location",
                                                style: TextStyle(
                                                  color: Colors.black54,
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
                          },
                        );
                      },
                      icon: const Icon(
                        Icons.more_horiz_rounded,
                        color: Colors.black54,
                      ),
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
                                "Arrival:",
                                style: textStyle,
                              ),
                              Text(
                                _getFormattedTime(
                                  DateTime.fromMillisecondsSinceEpoch(
                                    parkings[index].getArrival!,
                                  ),
                                ),
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
                                _getFormattedTime(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      parkings[index].getDeparture!),
                                ),
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
              ],
            ),
          ),
        );
      },
    );
  }

  String _getFormattedTime(DateTime time) {
    String formattedTime = "";
    DateTime arrival = DateTime(
      time.year,
      time.month,
      time.day,
    );

    arrival.compareTo(_getDateTimeNow()) == 0
        ? formattedTime += "Today at "
        : formattedTime += DateFormat('MMM. dd, yyyy ').format(arrival) + "at ";
    formattedTime += DateFormat("h:mm a").format(time);
    return formattedTime;
  }

  DateTime _getDateTimeNow() {
    return DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
  }
}

class History extends StatefulWidget {
  final List<Parking> parkingHistory;
  const History({Key? key, required this.parkingHistory}) : super(key: key);

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  final textStyle = const TextStyle(
    fontSize: 16,
  );
  final UserData userData = globals.userData;

  @override
  Widget build(BuildContext context) {
    final List<Parking>? parkings = widget.parkingHistory;

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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
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
                  ],
                ),
                Center(
                  child: IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (context) => InfoPopup(
                          parking: parkings[index],
                        ),
                      ),
                    ),
                    icon: const Icon(
                      Icons.info_outline,
                      color: Colors.black54,
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class InfoPopup extends StatelessWidget {
  final Parking parking;
  const InfoPopup({Key? key, required this.parking}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const _labelStyle = TextStyle(
      fontSize: 19,
      color: Colors.grey,
    );

    const _infoStyle = TextStyle(
      fontSize: 16,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Parking Information"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    parking.getImageUrl!,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Location",
              style: _labelStyle,
            ),
            const SizedBox(height: 10),
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
                      parking.getAddress!,
                      style: _infoStyle,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              "Car",
              style: _labelStyle,
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
                  parking.getPlateNumber!,
                  style: _infoStyle,
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              "Duration",
              style: _labelStyle,
            ),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Arrived:",
                      style: _infoStyle,
                    ),
                    Text(
                      _getFormattedTime(
                        DateTime.fromMillisecondsSinceEpoch(
                          parking.getArrival!,
                        ),
                      ),
                      style: _infoStyle,
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Departed:",
                      style: _infoStyle,
                    ),
                    Text(
                      _getFormattedTime(
                        DateTime.fromMillisecondsSinceEpoch(
                          parking.getDeparture!,
                        ),
                      ),
                      style: _infoStyle,
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Duration:",
                      style: _infoStyle,
                    ),
                    Text(
                      parking.getDuration!,
                      style: _infoStyle,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              "Paid",
              style: _labelStyle,
            ),
            const SizedBox(height: 10),
            Text(
              parking.getPrice.toString(),
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFormattedTime(DateTime time) {
    String formattedTime = "";
    DateTime arrival = DateTime(
      time.year,
      time.month,
      time.day,
    );

    formattedTime += DateFormat('MMM. dd, yyyy ').format(arrival) + "at ";
    formattedTime += DateFormat("h:mm a").format(time);
    return formattedTime;
  }
}
