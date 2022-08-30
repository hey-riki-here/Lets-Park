// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lets_park/models/parking.dart';
import 'package:lets_park/models/parking_space.dart';
import 'package:lets_park/services/parking_space_services.dart';
import 'package:lets_park/shared/shared_widgets.dart';

class SpaceEarnings extends StatefulWidget {
  final ParkingSpace space;
  final int index;
  const SpaceEarnings({Key? key, required this.space, required this.index})
      : super(key: key);

  @override
  State<SpaceEarnings> createState() => _SpaceEarningsState();
}

class _SpaceEarningsState extends State<SpaceEarnings> {
  final _sharedWidgets = SharedWidget();
  List<Parking> parkingEarnings = [];
  Map<int, Earning> dailyEarnings = {};
  Map<String, Earning> monthlyEarnings = {};

  @override
  Widget build(BuildContext context) {
    final spaceIndex = widget.index;

    const boldText = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    );

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar:
            _sharedWidgets.manageSpaceAppBar("Earnings - Space $spaceIndex"),
        backgroundColor: Colors.grey.shade100,
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: ParkingSpaceServices.getParkingSessionsDocs(
                widget.space.getSpaceId!),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                parkingEarnings.clear();
                dailyEarnings.clear();
                monthlyEarnings.clear();
                snapshot.data!.docs.forEach((parking) {
                  parkingEarnings.add(Parking.fromJson(parking.data()));
                });
                generateMap();
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(12),
                        ),
                      ),
                      elevation: 0,
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TabBar(
                            labelStyle: const TextStyle(
                              fontSize: 16,
                            ),
                            unselectedLabelColor: Colors.black54,
                            labelColor: Colors.white,
                            indicator: BoxDecoration(
                              color: Colors.blue.shade400,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            tabs: const [
                              Tab(
                                text: 'Daily',
                              ),
                              Tab(
                                text: 'Monthly',
                              ),
                            ]),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        ListView.builder(
                            padding: const EdgeInsets.all(8.0),
                            itemCount: dailyEarnings.length,
                            itemBuilder: (context, index) {
                              List<Earning> dailyEarningsList =
                                  dailyEarnings.values.toList();
                              return Card(
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12),
                                  ),
                                ),
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "${dailyEarningsList[index].getParkingQuantity} parking/s",
                                            style: boldText,
                                          ),
                                          Text(
                                            "P ${dailyEarningsList[index].getEarned}",
                                            style: boldText,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Space $spaceIndex"),
                                          Text(
                                            _getFormattedTime(
                                              DateTime
                                                  .fromMillisecondsSinceEpoch(
                                                dailyEarningsList[index]
                                                    .getTime!,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                        ListView.builder(
                            padding: const EdgeInsets.all(8.0),
                            itemCount: monthlyEarnings.length,
                            itemBuilder: (context, index) {
                              List<Earning> monthlyEarningsList =
                                  monthlyEarnings.values.toList();

                              return Card(
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12),
                                  ),
                                ),
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "${monthlyEarningsList[index].getParkingQuantity} parking/s",
                                            style: boldText,
                                          ),
                                          Text(
                                            "P ${monthlyEarningsList[index].getEarned}",
                                            style: boldText,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Space $spaceIndex"),
                                          Text(
                                            _generateKey(
                                              DateTime
                                                  .fromMillisecondsSinceEpoch(
                                                monthlyEarningsList[index]
                                                    .getTime!,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                      ],
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }

  void generateMap() {
    for (Parking parking in parkingEarnings) {
      double time = parking.getArrival!.toDouble();

      double date = time * 0.00000001;

      if (!dailyEarnings.containsKey(date.toInt())) {
        dailyEarnings[date.toInt()] =
            Earning(1, time.toInt(), parking.getPrice!);
      } else {
        dailyEarnings.update(date.toInt(), (earned) {
          earned.setEarned = parking.getPrice!;
          earned.setParkingQuantity = 1;
          return earned;
        });
      }

      String key = _generateKey(
          DateTime.fromMillisecondsSinceEpoch(parking.getArrival!));

      if (!monthlyEarnings.containsKey(key)) {
        monthlyEarnings[key] = Earning(1, time.toInt(), parking.getPrice!);
      } else {
        monthlyEarnings.update(key, (earned) {
          earned.setEarned = parking.getPrice!;
          earned.setParkingQuantity = 1;
          return earned;
        });
      }
    }
  }

  String _getFormattedTime(DateTime time) {
    String formattedTime = "";
    DateTime arrival = DateTime(
      time.year,
      time.month,
      time.day,
    );

    formattedTime += DateFormat('MMMM dd, yyyy').format(arrival);
    return formattedTime;
  }

  String _generateKey(DateTime time) {
    String formattedTime = "";
    DateTime arrival = DateTime(
      time.year,
      time.month,
      time.day,
    );

    formattedTime += DateFormat('MMMM-yyyy').format(arrival);
    return formattedTime;
  }
}

class Earning {
  int? _parkingQuantity;
  int? _time;
  num? _earned;

  Earning(
    int parkingQuantity,
    int time,
    num earned,
  ) {
    _parkingQuantity = parkingQuantity;
    _time = time;
    _earned = earned;
  }

  int? get getParkingQuantity => _parkingQuantity;

  set setParkingQuantity(int? quantity) {
    _parkingQuantity = _parkingQuantity! + quantity!;
  }

  int? get getTime => _time;

  num? get getEarned => _earned;

  set setEarned(num? earned) {
    _earned = _earned! + earned!;
  }

  @override
  String toString() {
    return "Earning[$_parkingQuantity, $_time, $_earned]";
  }
}
