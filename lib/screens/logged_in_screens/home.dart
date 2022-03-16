import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lets_park/models/app_user.dart';
import 'package:lets_park/models/parking_space.dart';
import 'package:lets_park/screens/logged_in_screens/google_map_screen.dart';
import 'package:lets_park/services/firebase_api.dart';
import 'package:lets_park/shared/NavigationDrawer.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart' as geolocator;

class Home extends StatefulWidget {
  final int _pageId = 2;
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final user = FirebaseAuth.instance.currentUser;
  final GlobalKey<GoogleMapScreenState> _gMapKey = GlobalKey();
  final appUser = AppUser();
  @override
  Widget build(BuildContext context) {
    grantPermission();
    return Scaffold(
      key: _scaffoldKey,
      drawer: NavigationDrawer(currentPage: widget._pageId),
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMapScreen(key: _gMapKey),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      DrawerButton(scaffoldKey: _scaffoldKey),
                      const SizedBox(width: 10),
                      SearchBox(gMapKey: _gMapKey),
                    ],
                  ),
                  const SizedBox(height: 10),
                  FilterButtons(gMapKey: _gMapKey),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void grantPermission() async {
    Location location = Location();

    PermissionStatus _permissionGranted;

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }
}

class DrawerButton extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const DrawerButton({Key? key, required this.scaffoldKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      elevation: 2,
      color: Colors.white,
      child: IconButton(
        icon: const Icon(Icons.menu),
        splashRadius: 30,
        color: Colors.black,
        onPressed: () {
          scaffoldKey.currentState!.openDrawer();
        },
      ),
    );
  }
}

class SearchBox extends StatelessWidget {
  final GlobalKey<GoogleMapScreenState> gMapKey;
  const SearchBox({Key? key, required this.gMapKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _controller = TextEditingController();

    return Expanded(
      child: Material(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        elevation: 2,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: _controller,
            textInputAction: TextInputAction.done,
            onSubmitted: (query) {
              gMapKey.currentState!.goToLocation(query + ", Valenzuela");
            },
            decoration: InputDecoration(
              suffixIcon: IconButton(
                  onPressed: () {
                    gMapKey.currentState!
                        .goToLocation(_controller.text.trim() + ", Valenzuela");
                  },
                  icon: const Icon(
                    Icons.search,
                    color: Colors.black54,
                    size: 20,
                  )),
              isDense: true,
              hintText: 'Enter location here',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide.none,
              ),
            ),
            textAlign: TextAlign.start,
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}

class FilterButtons extends StatefulWidget {
  final GlobalKey<GoogleMapScreenState> gMapKey;
  const FilterButtons({Key? key, required this.gMapKey}) : super(key: key);

  @override
  State<FilterButtons> createState() => _FilterButtonsState();
}

class _FilterButtonsState extends State<FilterButtons> {
  bool canShowModal = true;
  @override
  Widget build(BuildContext context) {
    FirebaseServices _firebaseServices = FirebaseServices();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 50),
        _buildCategory(
          label: "Nearby",
          width: 100,
          context: context,
          onTap: () async {
            if (canShowModal == true) {
              setState(() {
                canShowModal = false;
              });
              var position = await geolocator.Geolocator().getCurrentPosition(
                  desiredAccuracy: geolocator.LocationAccuracy.high);
              Map<ParkingSpace, double> nearbySpaces =
                  _firebaseServices.getNearbyParkingSpaces(
                LatLng(
                  position.latitude,
                  position.longitude,
                ),
              );
              setState(() {
                canShowModal = true;
              });
              await showModalBottomSheet<void>(
                barrierColor: const Color.fromARGB(0, 0, 0, 0),
                elevation: 50,
                context: context,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                builder: (BuildContext context) {
                  return Container(
                    height: 350,
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Icon(
                            Icons.drag_handle_rounded,
                            color: Colors.grey,
                            size: 30,
                          ),
                        ),
                        const Text(
                          "Top nearby places",
                          style: TextStyle(
                            fontSize: 23,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          "Click on the parking space to focus it on the map",
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: nearbySpaces.keys.length,
                            itemBuilder: (context, index) {
                              return NearbyParkingCard(
                                space: nearbySpaces.keys.elementAt(index),
                                gMapKey: widget.gMapKey,
                                distance: getDistance(
                                  nearbySpaces.values.elementAt(index),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
          },
        ),
        _buildCategory(
          label: "Highest Rating",
          width: 120,
          context: context,
          onTap: () {},
        ),
        _buildCategory(
          label: "Secured",
          width: 100,
          context: context,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildCategory({
    required String label,
    required double width,
    required BuildContext context,
    required VoidCallback onTap,
  }) {
    return Material(
      borderRadius: const BorderRadius.all(Radius.circular(15)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: canShowModal == false && label.compareTo("Nearby") == 0
            ? null
            : onTap,
        child: Ink(
          height: 30,
          width: width,
          child: label.compareTo("Nearby") == 0
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    canShowModal == false
                        ? const SizedBox(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(
                              color: Colors.grey,
                              strokeWidth: 2,
                            ),
                          )
                        : Container(),
                  ],
                )
              : Center(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  String getDistance(double distance) {
    int newDistance = 0;
    if (distance < 1) {
      newDistance = (distance * 1000).toInt();
      return "$newDistance m";
    } else {
      newDistance = distance.toInt();
      return "$newDistance km";
    }
  }
}

class NearbyParkingCard extends StatelessWidget {
  final ParkingSpace space;
  final String distance;
  final GlobalKey<GoogleMapScreenState> gMapKey;
  const NearbyParkingCard({
    Key? key,
    required this.space,
    required this.gMapKey,
    required this.distance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: InkWell(
        onTap: () {
          gMapKey.currentState!.focusMapOnLocation(space.getLatLng!);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 150,
                  height: 100,
                  child: Image.network(
                    space.getImageUrl!,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.yellow.shade600,
                    size: 17,
                  ),
                  Icon(
                    Icons.star,
                    color: Colors.yellow.shade600,
                    size: 17,
                  ),
                  Icon(
                    Icons.star,
                    color: Colors.yellow.shade600,
                    size: 17,
                  ),
                  Icon(
                    Icons.star,
                    color: Colors.yellow.shade600,
                    size: 17,
                  ),
                  Icon(
                    Icons.star,
                    color: Colors.yellow.shade600,
                    size: 17,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: getFeatures(space.getFeatures!),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "About " + distance,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getFeatures(List<String> features) {
    String featuresList = "";
    for (String feature in features) {
      featuresList += "-" + feature + "\n";
    }

    return Text(
      featuresList,
      style: const TextStyle(color: Colors.black54),
    );
  }
}
