// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:flutter/material.dart';
import 'package:lets_park/screens/popups/parking_area_information.dart';
import 'package:lets_park/services/firebase_api.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lets_park/models/parking_space.dart';
import 'package:lets_park/services/parking_space_services.dart';

class MonthlyParkingsPage extends StatefulWidget {
  const MonthlyParkingsPage({
    Key? key,
  }) : super(key: key);

  @override
  State<MonthlyParkingsPage> createState() => _MonthlyParkingsPageState();
}

class _MonthlyParkingsPageState extends State<MonthlyParkingsPage> {
  List<ParkingSpace> spaces = [];
  List<ParkingSpace> filteredSpaces = [];
  String query = "";
  bool isFiltered = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            size: 17,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text(
          "Monthly Parkings",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
        bottom: PreferredSize(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                if (value.isEmpty) {
                  setState(() {
                    isFiltered = false;
                  });
                } else {
                  query = value;
                }
              },
              onSubmitted: (value) => filterList(value),
              textAlign: TextAlign.start,
              maxLines: 1,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  onPressed: () => filterList(query),
                  icon: const Icon(
                    Icons.search,
                    color: Colors.black54,
                    size: 20,
                  ),
                ),
                isDense: true,
                hintText: 'Enter location here',
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 3,
                    color: Colors.grey.shade200,
                  ),
                ),
                border: const OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          preferredSize: const Size.fromHeight(70),
        ),
      ),
      body: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: FirebaseServices.getMonthlyParkingSpaces(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            spaces.clear();
            snapshot.data!.docs.forEach((space) {
              spaces.add(ParkingSpace.fromJson(space.data()));
            });
            return spaces.isEmpty || (isFiltered && filteredSpaces.isEmpty)
                ? Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.info_outline,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "No monthly parking spaces found.",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: GridView.count(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(0),
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        shrinkWrap: true,
                        children: isFiltered
                            ? filteredSpaces
                                .map((space) => MonthlyParkingSpaceCard(
                                      space: space,
                                    ))
                                .toList()
                            : spaces
                                .map((space) => MonthlyParkingSpaceCard(
                                      space: space,
                                    ))
                                .toList(),
                      ),
                    ),
                  );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  void filterList(String query) {
    filteredSpaces.clear();
    spaces.forEach((space) {
      if (space.getAddress!.contains(query)) {
        filteredSpaces.add(space);
      }
    });
    setState(() {
      isFiltered = true;
    });
  }
}

class MonthlyParkingSpaceGrid extends StatefulWidget {
  final List<ParkingSpace> spaces;
  const MonthlyParkingSpaceGrid({Key? key, required this.spaces})
      : super(key: key);

  @override
  State<MonthlyParkingSpaceGrid> createState() =>
      MonthlyParkingSpaceGridState();
}

class MonthlyParkingSpaceGridState extends State<MonthlyParkingSpaceGrid> {
  List<ParkingSpace> spaces = [];
  bool loading = false;

  @override
  void initState() {
    spaces = widget.spaces;
    print(spaces);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(0),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      shrinkWrap: true,
      children: spaces
          .map((space) => MonthlyParkingSpaceCard(
                space: space,
              ))
          .toList(),
    );
  }
}

class MonthlyParkingSpaceCard extends StatelessWidget {
  final ParkingSpace space;
  const MonthlyParkingSpaceCard({
    Key? key,
    required this.space,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            color: Colors.black54,
            image: DecorationImage(
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.5),
                BlendMode.srcOver,
              ),
              image: NetworkImage(
                space.getImageUrl!,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      color: Colors.blue.shade100,
                      size: 20,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        space.getAddress!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        "${space.getRating!.toInt()}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                OutlinedButton(
                  onPressed: () async {
                    bool verified = await ParkingSpaceServices.isVerified(
                      space.getSpaceId!,
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ParkingAreaInformation(
                          parkingSpace: space,
                          verified: verified && space.getRating! >= 4,
                        ),
                      ),
                    );
                  },
                  child: const Text("View space"),
                  style: OutlinedButton.styleFrom(
                    fixedSize: Size(
                      MediaQuery.of(context).size.width,
                      20,
                    ),
                    side: const BorderSide(color: Colors.grey),
                    primary: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
