// ignore_for_file: avoid_function_literals_in_foreach_calls, empty_catches

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lets_park/globals/globals.dart' as globals;
import 'package:lets_park/models/notification.dart';
import 'package:lets_park/models/parking.dart';
import 'package:lets_park/models/parking_space.dart';
import 'package:lets_park/screens/logged_in_screens/google_map_screen.dart';
import 'package:lets_park/services/firebase_api.dart';
import 'package:lets_park/services/notif_services.dart';
import 'package:lets_park/services/user_services.dart';
import 'package:lets_park/services/parking_space_services.dart';
import 'package:lets_park/shared/navigation_drawer.dart';
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
  final UserServices _userServices = UserServices();

  @override
  void initState() {
    grantPermission();

    UserServices.getFavorites(user!.uid);

    Location().onLocationChanged.listen((currentLocation) {
      if (globals.parkingLoc.latitude != 0 &&
          globals.parkingLoc.longitude != 0) {
        if ((FirebaseServices.calculateDistance(
                  currentLocation.latitude,
                  currentLocation.longitude,
                  globals.parkingLoc.latitude,
                  globals.parkingLoc.longitude,
                ) *
                1000) <
            5) {
          NotificationServices.showNotification(
            "You have arrived at the parking space",
            "You have succesfully at the parking space location.",
          );
          globals.parkingLoc = const LatLng(0, 0);
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _userServices.startSessionsStream(context);
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _userServices.getParkingSessionsStream.cancel();
    _userServices.getOwnedParkingSessionsStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    try {
      NotificationServices.startListening(context);
    } catch (e) {}

    return Scaffold(
      key: _scaffoldKey,
      drawer: NavigationDrawer(currentPage: widget._pageId),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _userServices.getUserParkingData()!,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Parking> parkings = [];
              snapshot.data!.docs.forEach((element) {
                parkings.add(Parking.fromJson(element.data()));
              });
              globals.userData.setParkings = parkings;
            }
            return SafeArea(
              child: Stack(
                children: [
                  GoogleMapScreen(key: _gMapKey),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
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
                        const MarkerLegends(),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
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
    final UserServices _userServices = UserServices();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _userServices.getUserData()!,
        builder: (context, snapshot) {
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
        });
  }
}

class SearchBox extends StatelessWidget {
  final GlobalKey<GoogleMapScreenState> gMapKey;
  const SearchBox({Key? key, required this.gMapKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final UserServices _userServices = UserServices();
    final _controller = TextEditingController();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _userServices.getUserNotifications()!,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<UserNotification> notifications = [];
            snapshot.data!.docs.forEach((element) {
              notifications.add(UserNotification.fromJson(element.data())); //
            });
            globals.userData.setUserNotifications = notifications;
          }
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
                          NotificationServices.showNotification(
                            "Parking session started",
                            "Your parking session has started. Click View Parking to view parking\n session details.",
                          );
                          //gMapKey.currentState!.goToLocation(query + ", Valenzuela");
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
        });
  }
}

class FilterButtons extends StatefulWidget {
  final GlobalKey<GoogleMapScreenState> gMapKey;
  const FilterButtons({Key? key, required this.gMapKey}) : super(key: key);

  @override
  State<FilterButtons> createState() => _FilterButtonsState();
}

class _FilterButtonsState extends State<FilterButtons> {
  bool nearbyCanShowModal = true;
  bool highestRatingCanShowModal = true;
  bool securedCanShowModal = true;
  bool monthlyCanShowModal = true;
  @override
  Widget build(BuildContext context) {
    FirebaseServices _firebaseServices = FirebaseServices();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCategory(
          label: "Nearby",
          width: 75,
          context: context,
          canShowModal: nearbyCanShowModal,
          onTap: () async {
            Location location = Location();

            bool _serviceEnabled;

            _serviceEnabled = await location.serviceEnabled();
            if (!_serviceEnabled) {
              _serviceEnabled = await location.requestService();
              if (!_serviceEnabled) {
                return;
              }
            } else {
              if (nearbyCanShowModal == true) {
                setState(() {
                  nearbyCanShowModal = false;
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
                  nearbyCanShowModal = true;
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
                      height: 370,
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
                                  forNearby: true,
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
            }
          },
        ),
        _buildCategory(
          label: "Highest Rating",
          width: 115,
          context: context,
          canShowModal: highestRatingCanShowModal,
          onTap: () async {
            if (highestRatingCanShowModal == true) {
              setState(() {
                highestRatingCanShowModal = false;
              });
              List<ParkingSpace> topFive =
                  FirebaseServices.getHighestRatedParkings();
              setState(() {
                highestRatingCanShowModal = true;
              });
              _showContentOnFilterTap(
                title: "Top highest rated parkings",
                spaces: topFive,
              );
            }
          },
        ),
        _buildCategory(
          label: "Secured",
          width: 80,
          context: context,
          canShowModal: securedCanShowModal,
          onTap: () {
            if (securedCanShowModal == true) {
              setState(() {
                securedCanShowModal = false;
              });

              _showContentOnFilterTap(
                title: "Secure parking spaces",
                spaces: FirebaseServices.getSecuredParkingSpaces(),
              );

              setState(() {
                securedCanShowModal = true;
              });
            }
          },
        ),
        _buildCategory(
          label: "Monthly",
          width: 80,
          context: context,
          canShowModal: monthlyCanShowModal,
          onTap: () {
            if (monthlyCanShowModal == true) {
              setState(() {
                monthlyCanShowModal = false;
              });

              _showContentOnFilterTap(
                title: "Monthly parking spaces",
                spaces: FirebaseServices.getMonthlyParkings(),
              );

              setState(() {
                monthlyCanShowModal = true;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildCategory({
    required String label,
    required double width,
    required BuildContext context,
    required VoidCallback onTap,
    required bool canShowModal,
  }) {
    return Material(
      borderRadius: const BorderRadius.all(Radius.circular(15)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: canShowModal == false ? null : onTap,
        child: Ink(
          height: 25,
          width: width,
          child: canShowModal == true
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(
                        color: Colors.grey,
                        strokeWidth: 2,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void _showContentOnFilterTap({
    required String title,
    required List<ParkingSpace> spaces,
  }) async {
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
              Text(
                title,
                style: const TextStyle(
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
                  itemCount: spaces.length,
                  itemBuilder: (context, index) {
                    return NearbyParkingCard(
                      space: spaces[index],
                      gMapKey: widget.gMapKey,
                      distance: getDistance(
                        0.0,
                      ),
                      forNearby: false,
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
  final bool forNearby;
  final GlobalKey<GoogleMapScreenState> gMapKey;
  const NearbyParkingCard({
    Key? key,
    required this.space,
    required this.gMapKey,
    required this.distance,
    required this.forNearby,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 165,
      child: Card(
        elevation: 5,
        child: InkWell(
          onTap: () {
            gMapKey.currentState!.focusMapOnLocation(space.getLatLng!);
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                child: Text(
                  space.getAddress!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black45,
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: ParkingSpaceServices.getStars(space.getRating!),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: getFeatures(space.getFeatures!),
              ),
              forNearby
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "About " + distance,
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black87),
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  Column getFeatures(List<String> features) {
    List<Widget> newChildren = [];

    for (String feature in features) {
      if (feature.compareTo("With gate") == 0) {
        newChildren.add(
          Row(
            children: [
              const Icon(
                CommunityMaterialIcons.gate,
                color: Colors.blue,
                size: 15,
              ),
              const SizedBox(width: 12),
              Text(
                feature,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 15),
            ],
          ),
        );
      } else if (feature.compareTo("CCTV") == 0) {
        newChildren.add(
          Row(
            children: [
              const Icon(
                CommunityMaterialIcons.cctv,
                color: Colors.blue,
                size: 15,
              ),
              const SizedBox(width: 12),
              Text(
                feature,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 15),
            ],
          ),
        );
      } else if (feature.compareTo("Covered Parking") == 0) {
        newChildren.add(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                CommunityMaterialIcons.bus_stop_covered,
                color: Colors.blue,
                size: 15,
              ),
              const SizedBox(width: 12),
              Text(
                feature,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      } else {
        newChildren.add(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                CommunityMaterialIcons.lightbulb_on_outline,
                color: Colors.blue,
                size: 15,
              ),
              const SizedBox(width: 12),
              Text(
                feature,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: newChildren,
    );
  }
}

class MarkerLegends extends StatelessWidget {
  const MarkerLegends({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      //crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Card(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(12),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 2,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.blue[400],
                ),
                const SizedBox(width: 10),
                const Text("Reservable"),
              ],
            ),
          ),
        ),
        const SizedBox(width: 5),
        Card(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(12),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 2,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.green[400],
                ),
                const SizedBox(width: 10),
                const Text("Non-Reservable"),
              ],
            ),
          ),
        ),
        const SizedBox(height: 5),
        Card(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(12),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 2,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.orange[400],
                ),
                const SizedBox(width: 10),
                const Text("Monthly"),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
