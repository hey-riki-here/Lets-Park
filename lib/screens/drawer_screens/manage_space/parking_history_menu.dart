// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lets_park/models/parking_space.dart';
import 'package:lets_park/screens/drawer_screens/manage_space/space_parking_history.dart';
import 'package:lets_park/services/parking_space_services.dart';
import 'package:lets_park/shared/shared_widgets.dart';
import 'package:lets_park/globals/globals.dart';

class ParkingHistoryMenu extends StatefulWidget {
  const ParkingHistoryMenu({Key? key}) : super(key: key);

  @override
  State<ParkingHistoryMenu> createState() => _ParkingHistoryMenuState();
}

class _ParkingHistoryMenuState extends State<ParkingHistoryMenu> {
  final _sharedWidgets = SharedWidget();
  List<ParkingSpace>? parkingSpaces = userData.getOwnedParkingSpaces;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _sharedWidgets.manageSpaceAppBar("Parking History"),
      backgroundColor: Colors.grey.shade100,
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: parkingSpaces!.length,
        itemBuilder: (BuildContext context, int index) {
          return SpaceCard(
            space: parkingSpaces![index],
            index: index,
            spaceId: parkingSpaces![index].getSpaceId!,
            address: parkingSpaces![index].getAddress!,
          );
        },
      ),
    );
  }
}

class SpaceCard extends StatefulWidget {
  final ParkingSpace space;
  final int index;
  final String spaceId;
  final String address;
  const SpaceCard({
    Key? key,
    required this.space,
    required this.index,
    required this.spaceId,
    required this.address,
  }) : super(key: key);

  @override
  State<SpaceCard> createState() => _SpaceCardState();
}

class _SpaceCardState extends State<SpaceCard> {
  @override
  Widget build(BuildContext context) {
    final space = widget.space;
    final index = widget.index + 1;
    final spaceId = widget.spaceId;
    final address = widget.address;
    int totalParkings = 0;

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: ParkingSpaceServices.getParkingSessionsDocs(
          space.getSpaceId!,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.hasData) {
              totalParkings = 0;
              snapshot.data!.docs.forEach((parking) {
                if (parking.data()["inHistory"] == true) {
                  totalParkings++;
                }
              });
            }
          }

          return Card(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(12),
              ),
            ),
            elevation: 3,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ParkingHistory(
                      space: space,
                      index: index,
                      spaceId: spaceId,
                      address: address,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          "assets/icons/parking-marker.png",
                          scale: 2.7,
                        ),
                        const SizedBox(width: 5),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Space $index",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "Space ID: $spaceId",
                              style: const TextStyle(
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "Total Parkings: $totalParkings",
                              style: const TextStyle(
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
