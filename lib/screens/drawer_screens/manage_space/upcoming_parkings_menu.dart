// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lets_park/globals/globals.dart';
import 'package:lets_park/models/parking_space.dart';
import 'package:lets_park/screens/drawer_screens/manage_space/upcoming_parkings.dart';
import 'package:lets_park/services/parking_space_services.dart';
import 'package:lets_park/shared/shared_widgets.dart';

class UpcomingParkingsMenu extends StatefulWidget {
  const UpcomingParkingsMenu({Key? key}) : super(key: key);

  @override
  State<UpcomingParkingsMenu> createState() => _UpcomingParkingsState();
}

class _UpcomingParkingsState extends State<UpcomingParkingsMenu> {
  final _sharedWidgets = SharedWidget();
  final textStyle = const TextStyle(
    fontSize: 16,
  );
  List<ParkingSpace>? parkingSpaces = userData.getOwnedParkingSpaces;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _sharedWidgets.manageSpaceAppBar("Upcoming Parkings"),
      backgroundColor: Colors.grey.shade200,
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
  List<String> driverAvatar = [];

  @override
  Widget build(BuildContext context) {
    final space = widget.space;
    final index = widget.index + 1;
    int upcoming = 0;

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: ParkingSpaceServices.getParkingSessionsDocs(
          space.getSpaceId!,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.hasData) {
              upcoming = 0;
              driverAvatar.clear();
              snapshot.data!.docs.forEach((parking) {
                if (parking.data()["upcoming"] == true) {
                  driverAvatar.add(parking.data()["driverImage"]);
                  upcoming++;
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
                    builder: (context) => UpcomingParkings(
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
                            Text(
                              "Upcoming Parkings: $upcoming",
                              style: const TextStyle(
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        Expanded(child: getAvatars()),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget getAvatars() {
    List<Widget> children = [];

    driverAvatar.forEach((avatar) {
      children.add(
        CircleAvatar(
          backgroundColor: Colors.white,
          backgroundImage: NetworkImage(avatar),
          radius: 15,
        ),
      );
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: children,
    );
  }
}
