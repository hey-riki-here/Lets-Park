// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lets_park/models/parking.dart';
import 'package:lets_park/models/parking_space.dart';
import 'package:lets_park/services/parking_space_services.dart';
import 'package:lets_park/shared/shared_widgets.dart';

class UpcomingParkings extends StatefulWidget {
  final ParkingSpace space;
  final int index;
  const UpcomingParkings({Key? key, required this.space, required this.index})
      : super(key: key);

  @override
  State<UpcomingParkings> createState() => _UpcomingParkingsState();
}

class _UpcomingParkingsState extends State<UpcomingParkings> {
  final _sharedWidgets = SharedWidget();
  final textStyle = const TextStyle(
    fontSize: 16,
  );
  List<Parking> upcomingParkings = [];

  @override
  Widget build(BuildContext context) {
    final int index = widget.index;
    return Scaffold(
      appBar:
          _sharedWidgets.manageSpaceAppBar("Upcoming Parkings - Space $index"),
      backgroundColor: Colors.grey.shade200,
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: ParkingSpaceServices.getParkingSessionsDocs(
              widget.space.getSpaceId!),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              upcomingParkings.clear();
              snapshot.data!.docs.forEach((parking) {
                if (parking.data()["upcoming"] == true) {
                  upcomingParkings.add(Parking.fromJson(parking.data()));
                }
              });
            }

            return upcomingParkings.isNotEmpty
                ? ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: upcomingParkings.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 2,
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
                                  CircleAvatar(
                                    backgroundColor: Colors.white,
                                    backgroundImage: NetworkImage(
                                      upcomingParkings[index].getDriverImage!,
                                    ),
                                    radius: 25,
                                  ),
                                  const SizedBox(width: 15),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        upcomingParkings[index].getDriver!,
                                        style: textStyle,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                              Row(
                                children: [
                                  const Icon(
                                    FontAwesomeIcons.carAlt,
                                    color: Colors.blue,
                                    size: 30,
                                  ),
                                  const SizedBox(width: 15),
                                  Text(
                                    upcomingParkings[index].getPlateNumber!,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Arrival:",
                                              style: textStyle,
                                            ),
                                            Text(
                                              _getFormattedTime(
                                                DateTime
                                                    .fromMillisecondsSinceEpoch(
                                                  upcomingParkings[index]
                                                      .getArrival!,
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Departure:",
                                              style: textStyle,
                                            ),
                                            Text(
                                              _getFormattedTime(
                                                DateTime
                                                    .fromMillisecondsSinceEpoch(
                                                  upcomingParkings[index]
                                                      .getDeparture!,
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Time Remaining:",
                                              style: textStyle,
                                            ),
                                            Text(
                                              upcomingParkings[index]
                                                  .getDuration!,
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
                  )
                : Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.info_outline,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "No cars parked today.",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
          }),
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
