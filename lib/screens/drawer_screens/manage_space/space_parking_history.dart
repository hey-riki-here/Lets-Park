// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lets_park/models/parking.dart';
import 'package:lets_park/models/parking_space.dart';
import 'package:lets_park/services/parking_space_services.dart';
import 'package:lets_park/shared/shared_widgets.dart';

class ParkingHistory extends StatefulWidget {
  final ParkingSpace space;
  final int index;
  const ParkingHistory({Key? key, required this.space, required this.index})
      : super(key: key);

  @override
  State<ParkingHistory> createState() => _ParkingHistoryState();
}

class _ParkingHistoryState extends State<ParkingHistory> {
  final _sharedWidgets = SharedWidget();
  List<Parking> parkingHistory = [];
  final labelStyle = const TextStyle(
    fontSize: 18,
    color: Colors.grey,
  );
  final valueStyle = const TextStyle(
    fontSize: 16,
  );
  @override
  Widget build(BuildContext context) {
    final index = widget.index;
    return Scaffold(
      appBar: _sharedWidgets.manageSpaceAppBar(
        "Parking History - Space $index",
      ),
      backgroundColor: Colors.grey.shade100,
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: ParkingSpaceServices.getParkingSessionsDocs(
            widget.space.getSpaceId!),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            parkingHistory.clear();
            snapshot.data!.docs.forEach((parking) {
              if (parking.data()["inHistory"] == true) {
                parkingHistory.add(Parking.fromJson(parking.data()));
              }
            });
          }

          return parkingHistory.isNotEmpty
              ? ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: parkingHistory.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 2,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(12),
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          showModalBottomSheet<void>(
                            elevation: 50,
                            context: context,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            builder: (BuildContext context) {
                              return Card(
                                elevation: 0,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Driver",
                                        style: labelStyle,
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: Colors.white,
                                            backgroundImage: NetworkImage(
                                              parkingHistory[index]
                                                  .getDriverImage!,
                                            ),
                                            radius: 20,
                                          ),
                                          const SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                parkingHistory[index]
                                                    .getDriver!,
                                                style: valueStyle,
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        "Car",
                                        style: labelStyle,
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          const Icon(
                                            FontAwesomeIcons.carAlt,
                                          ),
                                          const SizedBox(width: 10),
                                          Column(
                                            children: [
                                              Text(
                                                parkingHistory[index]
                                                    .getPlateNumber!
                                                    .toUpperCase(),
                                                style: valueStyle,
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        "Parking information",
                                        style: labelStyle,
                                      ),
                                      const SizedBox(height: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Arrived: " +
                                                _getFormattedTime(
                                                  DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                    parkingHistory[index]
                                                        .getArrival!,
                                                  ),
                                                ),
                                            style: valueStyle,
                                          ),
                                          Text(
                                            "Departed: " +
                                                _getFormattedTime(
                                                  DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                    parkingHistory[index]
                                                        .getDeparture!,
                                                  ),
                                                ),
                                            style: valueStyle,
                                          ),
                                          Text(
                                            "Duration: ${parkingHistory[index].getDuration!}",
                                            style: valueStyle,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        "Paid",
                                        style: labelStyle,
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        "${parkingHistory[index].getPrice!}.00",
                                        style: valueStyle,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                const Icon(
                                  FontAwesomeIcons.carAlt,
                                  size: 30,
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    "${ parkingHistory[index].getPlateNumber!.toUpperCase()}, parked for ${parkingHistory[index].getDuration!}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                        "No one has parked here yet.",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
        },
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
