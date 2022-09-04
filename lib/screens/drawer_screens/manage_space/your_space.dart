// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lets_park/models/parking_space.dart';
import 'package:lets_park/screens/drawer_screens/manage_space/space.dart';
import 'package:lets_park/services/parking_space_services.dart';
import 'package:lets_park/shared/shared_widgets.dart';
import 'package:lets_park/globals/globals.dart' as globals;

class YourSpace extends StatelessWidget {
  final appUser = globals.userData;
  YourSpace({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _sharedWidgets = SharedWidget();
    List<ParkingSpace>? parkingSpaces = [];

    return Scaffold(
      appBar: _sharedWidgets.manageSpaceAppBar("Your spaces"),
      backgroundColor: Colors.grey.shade100,
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: ParkingSpaceServices.getOwnedParkingSpaces(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              parkingSpaces = [];
              snapshot.data!.docs.forEach((space) {
                parkingSpaces!.add(ParkingSpace.fromJson(space.data()));
              });
            }
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: parkingSpaces!.length,
                itemBuilder: (context, index) {
                  int title = index + 1;
                  return ParkingCard(
                    parkingSpace: parkingSpaces![index],
                    title: "$title",
                  );
                },
              ),
            );
          }),
    );
  }
}

class ParkingCard extends StatelessWidget {
  final ParkingSpace parkingSpace;
  final String title;
  const ParkingCard({Key? key, required this.parkingSpace, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final capacity = parkingSpace.getCapacity!;
    int availableSlot = 0;

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream:
          ParkingSpaceServices.getParkingSessionsDocs(parkingSpace.getSpaceId!),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.hasData) {
            int occupied = 0;
            snapshot.data!.docs.forEach((parking) {
              if (parking.data()["inProgress"] == true) {
                occupied++;
              }
            });
            availableSlot = capacity - occupied;
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
                  builder: (context) => Space(
                    space: parkingSpace,
                    title: title,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Space " + title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.red[400],
                            size: 17,
                          ),
                          Text(
                            parkingSpace.getAddress!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      ParkingSpaceServices.getStars(parkingSpace.getRating!),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text(
                            "Available slots:",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "$availableSlot/$capacity",
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      SizedBox(
                        width: 120,
                        height: 80,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            parkingSpace.getImageUrl!,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          buildTag(
                            availableSlot == 0
                                ? "Full"
                                : availableSlot > 0 && availableSlot != capacity
                                    ? "Occupied"
                                    : "Empty",
                            Colors.blue,
                          ),
                          const SizedBox(width: 5),
                          buildTag(
                            parkingSpace.isDisabled! ? "Disabled" : "Active",
                            parkingSpace.isDisabled!
                                ? Colors.red
                                : Colors.green,
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

  Widget buildTag(String label, Color color) {
    return Container(
      width: 60,
      height: 20,
      decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.all(Radius.circular(20))),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
