// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:flutter/material.dart';
import 'package:lets_park/screens/drawer_screens/manage_space/earnings.dart';
import 'package:lets_park/shared/shared_widgets.dart';
import 'package:lets_park/models/parking_space.dart';
import 'package:lets_park/services/parking_space_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lets_park/globals/globals.dart';

class Earnings extends StatefulWidget {
  const Earnings({Key? key}) : super(key: key);

  @override
  State<Earnings> createState() => _EarningsState();
}

class _EarningsState extends State<Earnings> {
  final _sharedWidgets = SharedWidget();
  List<ParkingSpace>? parkingSpaces = userData.getOwnedParkingSpaces;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _sharedWidgets.manageSpaceAppBar("Earnings"),
      backgroundColor: Colors.grey.shade100,
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: parkingSpaces!.length,
        itemBuilder: (BuildContext context, int index) {
          return SpaceCard(
            space: parkingSpaces![index],
            index: index,
          );
        },
      ),
    );
  }
}

class SpaceCard extends StatefulWidget {
  final ParkingSpace space;
  final int index;
  const SpaceCard({Key? key, required this.space, required this.index})
      : super(key: key);

  @override
  State<SpaceCard> createState() => _SpaceCardState();
}

class _SpaceCardState extends State<SpaceCard> {
  @override
  Widget build(BuildContext context) {
    final space = widget.space;
    final index = widget.index + 1;
    double earnings = 0;

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: ParkingSpaceServices.getParkingSessionsDocs(
        space.getSpaceId!,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.hasData) {
            earnings = 0;
            snapshot.data!.docs.forEach((parking) {
              earnings += parking.data()["price"];
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
                  builder: (context) => SpaceEarnings(
                    space: space,
                    index: index,
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
                          RichText(
                            text: TextSpan(
                              children: <TextSpan>[
                                const TextSpan(
                                  text: "Total Earnings: ",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: "P $earnings",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
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
      },
    );
  }
}
