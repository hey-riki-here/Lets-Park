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
import 'package:lets_park/screens/popups/checkout.dart';
import 'package:lets_park/screens/popups/checkout_monthly.dart';
import 'package:lets_park/screens/popups/notice_dialog.dart';
import 'package:lets_park/screens/popups/parking_area_info.dart';
import 'package:lets_park/services/firebase_api.dart';
import 'package:lets_park/services/notif_services.dart';
import 'package:lets_park/services/user_services.dart';
import 'package:lets_park/services/parking_space_services.dart';
import 'package:lets_park/services/world_time_api.dart';
import 'package:lets_park/shared/navigation_drawer.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:shimmer/shimmer.dart';

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
  bool mapSelected = true, feedSelected = false;
  final controller = DraggableScrollableController();
  double initialChildSize = 0.55;

  @override
  void initState() {
    grantPermission();
    initDateNow();
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

  void initDateNow() async {
    await WorldTimeServices.getDateOnlyNow().then((date) {
      globals.today = date.millisecondsSinceEpoch;
    });
  }

  void refresh() {
    setState(() {});
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
                GoogleMapScreen(
                  key: _gMapKey,
                  notifyParent: refresh,
                ),
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
                      //const MarkerLegends(),
                    ],
                  ),
                ),
                ScrollConfiguration(
                  behavior: ScrollWithoutGlowBehavior(),
                  child: NotificationListener<DraggableScrollableNotification>(
                    onNotification:
                        (DraggableScrollableNotification notification) {
                      initialChildSize = notification.extent;
                      return true;
                    },
                    child: DraggableScrollableSheet(
                      initialChildSize: initialChildSize,
                      controller: controller,
                      minChildSize: 0,
                      builder: (
                        BuildContext context,
                        ScrollController scrollController,
                      ) {
                        return SingleChildScrollView(
                          controller: scrollController,
                          child: const CustomScrollViewContent(),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(
          Icons.location_searching,
          color: Colors.white,
        ),
        onPressed: () async {
          try {
            _gMapKey.currentState!.getLocation(context);
          } on Exception catch (e) {}
        },
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      mapSelected = true;
                      feedSelected = false;
                    });
                    controller.animateTo(
                      initialChildSize >= 0.55 ? 0 : 0.55,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutBack,
                    );
                  },
                  padding: const EdgeInsets.all(5),
                  constraints: const BoxConstraints(),
                  splashRadius: 18,
                  icon: Icon(
                    mapSelected ? Icons.map : Icons.map_outlined,
                    color: mapSelected ? Colors.blue : Colors.black26,
                  ),
                ),
                Text(
                  "Map",
                  style: TextStyle(
                    color: mapSelected ? Colors.blue : Colors.black26,
                  ),
                ),
                const SizedBox(height: 5),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      feedSelected = true;
                      mapSelected = false;
                    });
                  },
                  padding: const EdgeInsets.all(5),
                  constraints: const BoxConstraints(),
                  splashRadius: 18,
                  icon: Icon(
                    feedSelected ? Icons.star : Icons.star_outline,
                    color: feedSelected ? Colors.blue : Colors.black26,
                  ),
                ),
                Text(
                  "Feed",
                  style: TextStyle(
                    color: feedSelected ? Colors.blue : Colors.black26,
                  ),
                ),
                const SizedBox(height: 5),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void focusMapOnLocation() {}

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

class CustomScrollViewContent extends StatelessWidget {
  const CustomScrollViewContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 30,
      child: Card(
        elevation: 30,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        margin: const EdgeInsets.all(0),
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: const SheetContent(),
        ),
      ),
    );
  }
}

class SheetContent extends StatelessWidget {
  const SheetContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        SizedBox(height: 12),
        CustomDraggingHandle(),
        SizedBox(height: 16),
        GreetingsWidget(),
        SizedBox(height: 16),
        NearbySpacesView(),
        SizedBox(height: 24),
        TopRatedParkings(),
        SizedBox(height: 16),
        CustomFeaturedItemsGrid(),
      ],
    );
  }
}

class CustomDraggingHandle extends StatelessWidget {
  const CustomDraggingHandle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 5,
      width: 30,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

class GreetingsWidget extends StatelessWidget {
  const GreetingsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(
          "Good day, ${FirebaseAuth.instance.currentUser!.displayName!.split(" ")[0]}!",
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
        const SizedBox(width: 8),
        RichText(
          text: const TextSpan(
            text: 'These are the parking spaces ',
            style: TextStyle(fontSize: 14, color: Colors.black45),
            children: <TextSpan>[
              TextSpan(
                text: 'Near you.',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class NearbySpacesView extends StatefulWidget {
  const NearbySpacesView({Key? key}) : super(key: key);

  @override
  State<NearbySpacesView> createState() => _NearbySpacesViewState();
}

class _NearbySpacesViewState extends State<NearbySpacesView> {
  Map<ParkingSpace, double> nearbySpaces = {};
  bool loading = true;

  @override
  void initState() {
    getNearbySpaces();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        right: 16,
      ),
      child: loading
          ? Shimmer.fromColors(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: const [
                    ShimmerItem(),
                    ShimmerItem(),
                    ShimmerItem(),
                  ],
                ),
              ),
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: nearbySpaces.entries.map((entry) {
                  return NearbySpaces(
                    space: entry.key,
                    distance: entry.value,
                  );
                }).toList(),
              ),
            ),
    );
  }

  void getNearbySpaces() async {
    FirebaseServices _firebaseServices = FirebaseServices();
    Location location = Location();

    bool _serviceEnabled;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    } else {
      var position = await geolocator.Geolocator().getCurrentPosition(
          desiredAccuracy: geolocator.LocationAccuracy.high);
      nearbySpaces = _firebaseServices.getNearbyParkingSpaces(
        LatLng(
          position.latitude,
          position.longitude,
        ),
      );
      setState(() {
        loading = false;
      });
    }
  }
}

class ShimmerItem extends StatelessWidget {
  const ShimmerItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 16,
        top: 16,
        left: 10,
      ),
      child: Column(
        children: [
          Container(
            height: 180,
            width: 250,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: 250,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              border: Border.all(
                color: Colors.black26,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 7),
          Container(
            width: 250,
            height: 45,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              border: Border.all(
                color: Colors.black26,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }
}

class NearbySpaces extends StatelessWidget {
  final ParkingSpace space;
  final double distance;
  const NearbySpaces({
    Key? key,
    required this.space,
    required this.distance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 16,
        top: 16,
        left: 10,
      ),
      child: Column(
        children: [
          Container(
            height: 180,
            width: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (context) => ParkingAreaInfo(
                      parkingSpace: space,
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  space.getImageUrl!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: 250,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.black26,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Material(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              child: InkWell(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (context) => ParkingAreaInfo(
                        parkingSpace: space,
                      ),
                    ),
                  );
                },
                child: Ink(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  "assets/icons/marker.png",
                                  width: 12,
                                ),
                                const SizedBox(width: 7),
                                space.getAddress!.length <= 25
                                    ? Text(
                                        space.getAddress!,
                                        style: const TextStyle(
                                          fontSize: 15,
                                        ),
                                      )
                                    : Text(
                                        space.getAddress!.substring(0, 24) +
                                            "...",
                                        style: const TextStyle(
                                          fontSize: 15,
                                        ),
                                      ),
                              ],
                            ),
                            const SizedBox(height: 7),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 15,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  "${space.getRating} • ${getDistance(distance)} • ${space.getType}",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
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
              ),
            ),
          ),
          OutlinedButton.icon(
            onPressed: () {
              globals.nonReservable = space;
              space.getDailyOrMonthly!.compareTo("Monthly") == 0
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (context) => CheckoutMonthly(
                          parkingSpace: space,
                        ),
                      ),
                    )
                  : space.getType!.compareTo("Reservable") == 0
                      ? Navigator.push(
                          context,
                          MaterialPageRoute(
                            fullscreenDialog: true,
                            builder: (context) => Checkout(
                              parkingSpace: space,
                            ),
                          ),
                        )
                      : showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (context) => NoticeDialog(
                            imageLink: "assets/logo/lets-park-logo.png",
                            header:
                                "You're about to rent a non-reservable space...",
                            parkingAreaAddress: space.getAddress!,
                            message:
                                "Please confirm that you are currently at the parking location.",
                            forNonreservableConfirmation: true,
                          ),
                        );
            },
            icon: const Icon(Icons.book),
            label: const Text("Book now"),
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(
                250,
                20,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ],
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

class TopRatedParkings extends StatelessWidget {
  const TopRatedParkings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Row(
        children: const [
          Text(
            "Top parking spaces",
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class CustomFeaturedItemsGrid extends StatelessWidget {
  const CustomFeaturedItemsGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<ParkingSpace> topFive = FirebaseServices.getHighestRatedParkings();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(0),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        shrinkWrap: true,
        children: topFive
            .map((space) => CustomFeaturedItem(
                  space: space,
                ))
            .toList(),
      ),
    );
  }
}

class CustomRecentPhotosText extends StatelessWidget {
  const CustomRecentPhotosText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Row(
        children: const [
          Text(
            "Recent Photos",
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class CustomFeaturedItem extends StatelessWidget {
  final ParkingSpace space;
  const CustomFeaturedItem({
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
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.star_rounded,
                color: Colors.amber,
                size: 25,
              ),
              const SizedBox(width: 5),
              Text(
                "${space.getRating!}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (context) => ParkingAreaInfo(
                      parkingSpace: space,
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
          ),
        ),
      ],
    );
  }
}

class ScrollWithoutGlowBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
