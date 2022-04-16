// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lets_park/globals/globals.dart';
import 'package:lets_park/models/parking.dart';
import 'package:lets_park/models/parking_space.dart';
import 'package:lets_park/services/parking_space_services.dart';
import 'package:lets_park/shared/shared_widgets.dart';

class Space extends StatefulWidget {
  final ParkingSpace space;
  final String title;
  const Space({Key? key, required this.space, required this.title})
      : super(key: key);

  @override
  State<Space> createState() => _SpaceState();
}

class _SpaceState extends State<Space> {
  final _sharedWidgets = SharedWidget();
  final textStyle = const TextStyle(
    fontSize: 16,
  );

  @override
  Widget build(BuildContext context) {
    final space = widget.space;
    final title = widget.title;
    final capacity = space.getCapacity;
    int availableSlot = 0;
    List<Parking> inProgressParkings = [];

    return Scaffold(
      appBar: _sharedWidgets.manageSpaceAppBar("Space $title"),
      backgroundColor: Colors.grey.shade100,
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream:
              ParkingSpaceServices.getParkingSessionsDocs(space.getSpaceId!),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              int occupied = 0;
              inProgressParkings.clear();
              snapshot.data!.docs.forEach((parking) {
                if (parking.data()["inProgress"] == true) {
                  occupied++;
                  inProgressParkings.add(Parking.fromJson(parking.data()));
                }
              });
              availableSlot = space.getCapacity! - occupied;
            }
            return ListView(
              padding: const EdgeInsets.all(12),
              children: [
                Card(
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
                        const Text(
                          "Available slots",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
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
                            const SizedBox(width: 10),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: "$availableSlot",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        height: 2,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const TextSpan(
                                      text: " available slot/s out of ",
                                      style: TextStyle(
                                        height: 2,
                                        color: Colors.black,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "$capacity",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        height: 2,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const TextSpan(
                                      text: " slot/s",
                                      style: TextStyle(
                                        height: 2,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Cars Parked",
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 10),
                inProgressParkings.isNotEmpty
                    ? SizedBox(
                        height: inProgressParkings.length > 1 ? 370 : 180,
                        child: ListView.builder(
                            itemCount: inProgressParkings.length,
                            itemBuilder: ((context, index) {
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: Colors.white,
                                            backgroundImage: NetworkImage(
                                              inProgressParkings[index]
                                                  .getDriverImage!,
                                            ),
                                            radius: 25,
                                          ),
                                          const SizedBox(width: 15),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                inProgressParkings[index]
                                                    .getDriver!,
                                                style: textStyle,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.star,
                                                    color:
                                                        Colors.yellow.shade600,
                                                    size: 15,
                                                  ),
                                                  Icon(
                                                    Icons.star,
                                                    color:
                                                        Colors.yellow.shade600,
                                                    size: 15,
                                                  ),
                                                  Icon(
                                                    Icons.star,
                                                    color:
                                                        Colors.yellow.shade600,
                                                    size: 15,
                                                  ),
                                                  Icon(
                                                    Icons.star,
                                                    color:
                                                        Colors.yellow.shade600,
                                                    size: 15,
                                                  ),
                                                  Icon(
                                                    Icons.star,
                                                    color:
                                                        Colors.yellow.shade600,
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
                                            inProgressParkings[index]
                                                .getPlateNumber!,
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
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Arrival:",
                                                      style: textStyle,
                                                    ),
                                                    Text(
                                                      _getFormattedTime(
                                                        DateTime
                                                            .fromMillisecondsSinceEpoch(
                                                          inProgressParkings[
                                                                  index]
                                                              .getArrival!,
                                                        ),
                                                      ),
                                                      style: textStyle.copyWith(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 5),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Departure:",
                                                      style: textStyle,
                                                    ),
                                                    Text(
                                                      _getFormattedTime(
                                                        DateTime
                                                            .fromMillisecondsSinceEpoch(
                                                          inProgressParkings[
                                                                  index]
                                                              .getDeparture!,
                                                        ),
                                                      ),
                                                      style: textStyle.copyWith(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 5),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Time Remaining:",
                                                      style: textStyle,
                                                    ),
                                                    Text(
                                                      inProgressParkings[index]
                                                          .getDuration!,
                                                      style: textStyle.copyWith(
                                                        fontWeight:
                                                            FontWeight.w700,
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
                            })),
                      )
                    : const Card(
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
                            "No cars parked today.",
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          )),
                        ),
                      ),
                const SizedBox(height: 10),
                const Text(
                  "Reviews",
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    itemBuilder: ((context, index) {
                      return SizedBox(
                        width: MediaQuery.of(context).size.width - 20,
                        child: Card(
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
                                    const CircleAvatar(
                                      backgroundColor: Colors.white,
                                      backgroundImage: NetworkImage(
                                          "https://www.bentbusinessmarketing.com/wp-content/uploads/2013/02/35844588650_3ebd4096b1_b-1024x683.jpg"),
                                      radius: 25,
                                    ),
                                    const SizedBox(width: 15),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Roberto Ginintuan",
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
                                const Text(
                                    "Some reviews about the parking area."),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Settings",
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 10),
                Card(
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
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            "Disable space",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.red.shade300,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            "Delete space",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.red.shade300,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
