// ignore_for_file: import_of_legacy_library_into_null_safe, avoid_function_literals_in_foreach_calls

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lets_park/screens/popups/checkout_non_reservable.dart';
import 'package:lets_park/shared/navigation_drawer.dart';
import 'package:lets_park/models/parking_space.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lets_park/services/firebase_api.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:lets_park/screens/popups/parking_area_information.dart';
import 'package:lets_park/globals/globals.dart' as globals;
import 'package:lets_park/screens/popups/checkout.dart';
import 'package:lets_park/screens/popups/checkout_monthly.dart';
import 'package:lets_park/screens/popups/notice_dialog.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lets_park/services/user_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lets_park/services/world_time_api.dart';
import 'package:lets_park/services/notif_services.dart';
import 'package:lets_park/models/parking.dart';
import 'package:lets_park/screens/logged_in_screens/home.dart';
import 'package:lets_park/screens/logged_in_screens/monthly_parkings.dart';
import 'package:lets_park/screens/drawer_screens/messages.dart';
import 'package:lets_park/screens/drawer_screens/notifications.dart';
import 'package:lets_park/screens/drawer_screens/profile.dart';
import 'package:lets_park/screens/drawer_screens/my_parkings.dart';
import 'package:lets_park/services/parking_space_services.dart';
import 'package:lets_park/screens/signin_register/otp_verification.dart';
import 'package:lets_park/shared/shared_widgets.dart';

class HomeScreen extends StatefulWidget {
  final int _pageId = 0;
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController numberController;
  final SharedWidget _sharedWidget = SharedWidget();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final user = FirebaseAuth.instance.currentUser;
  final UserServices _userServices = UserServices();
  final GlobalKey<NearbySpacesViewState> nearbySpacesViewState = GlobalKey();
  final GlobalKey<TopSpacesGridState> topSpacesGridState = GlobalKey();
  final GlobalKey<MonthlyParkingSpaceGridState> monthlyParkingSpaceGridState =
      GlobalKey();

  @override
  void initState() {
    numberController = TextEditingController();
    initDateNow();
    UserServices.getFavorites(user!.uid);

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

  @override
  Widget build(BuildContext context) {
    try {
      NotificationServices.startListening(context);
      // ignore: empty_catches
    } catch (e) {}

    return FirebaseAuth.instance.currentUser!.phoneNumber != null
        ? Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              backgroundColor: Colors.blue,
              leading: IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                  _scaffoldKey.currentState!.openDrawer();
                },
              ),
              elevation: 0,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              bottom: PreferredSize(
                child: Container(
                  height: 70,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: Row(
                      children: [
                        Text(
                          "Good day, ${FirebaseAuth.instance.currentUser!.displayName!.split(" ")[0]}!",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Messages()),
                                  );
                                },
                                child: const Icon(
                                  Icons.message,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 20),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const Notifications()),
                                  );
                                },
                                child: const Icon(
                                  Icons.notifications_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 20),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Profile()),
                                  );
                                },
                                child: CircleAvatar(
                                  backgroundColor: Colors.blue[100],
                                  radius: 20,
                                  child: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      FirebaseAuth
                                          .instance.currentUser!.photoURL!,
                                    ),
                                    radius: 17,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                preferredSize: const Size.fromHeight(70),
              ),
            ),
            drawer: NavigationDrawer(currentPage: widget._pageId),
            body: RefreshIndicator(
              onRefresh: refreshPage,
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _userServices.getUserParkingData()!,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<Parking> parkings = [];
                      snapshot.data!.docs.forEach((element) {
                        parkings.add(Parking.fromJson(element.data()));
                      });
                      globals.userData.setParkings = parkings;
                    }

                    return ScrollConfiguration(
                      behavior: ScrollWithoutGlowBehavior(),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Park",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 15),
                              const QuickActions(),
                              const SizedBox(height: 30),
                              const Text(
                                "Nearby spaces",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                              const Text(
                                "Listed below are the parking space(s) near your area.",
                                style: TextStyle(
                                  color: Colors.black45,
                                ),
                              ),
                              const SizedBox(height: 30),
                              NearbySpacesView(key: nearbySpacesViewState),
                              const SizedBox(height: 30),
                              const Text(
                                "Top parking spaces",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 15),
                              TopSpacesGrid(key: topSpacesGridState),
                              const SizedBox(height: 30),
                              const Text(
                                "Monthly parking spaces",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 15),
                              MonthlyParkingSpaceGrid(
                                  key: monthlyParkingSpaceGridState),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              elevation: 0,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset("assets/logo/app_icon.png"),
                ),
              ],
            ),
            backgroundColor: Colors.white,
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: const [
                      Text(
                        "We are almost there...",
                        style: TextStyle(
                          fontSize: 22,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Row(
                    children: const [
                      Text(
                        "Enter your phone number here",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Form(
                    key: formKey,
                    child: _sharedWidget.textFormField(
                      action: TextInputAction.done,
                      textInputType: TextInputType.number,
                      controller: numberController,
                      hintText: "9182083028",
                      obscure: false,
                      icon: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            "+63",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Enter phone number";
                        } else if (value.length < 10) {
                          return "Invalid phone number";
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              child: const Icon(
                Icons.forward,
              ),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => OTPVerification(
                            phoneNumber: "+63${numberController.text.trim()}")),
                  ).then((value) {
                    if (value != null) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return (const NoticeDialog(
                            imageLink: "assets/logo/lets-park-logo.png",
                            message:
                                "Thank you for verifying your phone number. Please enjoy the app!",
                          ));
                        },
                      );
                    }
                    setState(() {});
                  });
                }
              },
            ),
          );
  }

  Future<void> refreshPage() async {
    nearbySpacesViewState.currentState!.getNearbySpaces();
    topSpacesGridState.currentState!.getTopParkingSpaces();
    monthlyParkingSpaceGridState.currentState!.getMonthlyParkingSpaces();
  }
}

class QuickActions extends StatelessWidget {
  const QuickActions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (context) => const Home(),
                    ),
                  );
                },
                child: CircleAvatar(
                  backgroundColor: Colors.blue[50],
                  radius: 30,
                  child: CircleAvatar(
                    backgroundColor: Colors.blue[50],
                    backgroundImage:
                        const AssetImage("assets/images/reserve.png"),
                    radius: 25,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Reserve a\nparking",
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(width: 20),
          Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (context) => const MonthlyParkingsPage(),
                    ),
                  );
                },
                child: CircleAvatar(
                  backgroundColor: Colors.blue[50],
                  radius: 30,
                  child: CircleAvatar(
                    backgroundColor: Colors.blue[50],
                    backgroundImage:
                        const AssetImage("assets/images/monthly.png"),
                    radius: 25,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Monthly\nparking",
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(width: 20),
          Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MyParkings(
                              initialIndex: 0,
                            )),
                  );
                },
                child: CircleAvatar(
                  backgroundColor: Colors.blue[50],
                  radius: 30,
                  child: CircleAvatar(
                    backgroundColor: Colors.blue[50],
                    backgroundImage:
                        const AssetImage("assets/images/in_progress.png"),
                    radius: 25,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "In progress\nparking",
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(width: 20),
          Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MyParkings(
                              initialIndex: 1,
                            )),
                  );
                },
                child: CircleAvatar(
                  backgroundColor: Colors.blue[50],
                  radius: 30,
                  child: CircleAvatar(
                    backgroundColor: Colors.blue[50],
                    backgroundImage:
                        const AssetImage("assets/images/upcoming.png"),
                    radius: 25,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Upcoming\nparking",
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(width: 20),
          Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MyParkings(
                              initialIndex: 2,
                            )),
                  );
                },
                child: CircleAvatar(
                  backgroundColor: Colors.blue[50],
                  radius: 30,
                  child: CircleAvatar(
                    backgroundColor: Colors.blue[50],
                    backgroundImage:
                        const AssetImage("assets/images/history.png"),
                    radius: 25,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Parking\nhistory",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class NearbySpacesView extends StatefulWidget {
  const NearbySpacesView({Key? key}) : super(key: key);

  @override
  State<NearbySpacesView> createState() => NearbySpacesViewState();
}

class NearbySpacesViewState extends State<NearbySpacesView> {
  Map<ParkingSpace, double> nearbySpaces = {};
  bool loading = true, locationEnabled = true;

  @override
  void initState() {
    getNearbySpaces();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        right: 0,
      ),
      child: locationEnabled
          ? loading
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
              : nearbySpaces.isNotEmpty
                  ? SingleChildScrollView(
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
                    )
                  : const NoNearbySpaces()
          : EnableLocationService(
              getNearbySpaces: getNearbySpaces,
            ),
    );
  }

  void getNearbySpaces() async {
    setState(() {
      loading = true;
    });
    FirebaseServices _firebaseServices = FirebaseServices();
    Location location = Location();

    bool _serviceEnabled;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      setState(() {
        locationEnabled = false;
      });

      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      } else {
        setState(() {
          locationEnabled = true;
          getNearbySpaces();
        });
      }
    } else {
      setState(() {
        locationEnabled = true;
      });

      List<ParkingSpace> parkingSpaces = [];
      List<ParkingSpace> ownedSpaces = [];

      await FirebaseServices.getParkingSpaces().then((spaces) {
        spaces.docs.forEach((space) {
          parkingSpaces.add(ParkingSpace.fromJson(space.data()));
        });
      });

      parkingSpaces.forEach((parkingSpace) {
        if (parkingSpace.getOwnerId!
                .compareTo(FirebaseAuth.instance.currentUser!.uid) ==
            0) {
          ownedSpaces.add(parkingSpace);
        }
      });

      globals.userData.setOwnedParkingSpaces = ownedSpaces;
      globals.currentParkingSpaces = parkingSpaces;
      var position = await geolocator.Geolocator().getCurrentPosition(
          desiredAccuracy: geolocator.LocationAccuracy.high);
      nearbySpaces = _firebaseServices.getNearbyParkingSpaces(
        LatLng(
          position.latitude,
          position.longitude,
        ),
        parkingSpaces,
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
        right: 10,
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
                color: const Color.fromARGB(66, 26, 18, 18),
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

class EnableLocationService extends StatelessWidget {
  final Function getNearbySpaces;
  const EnableLocationService({
    Key? key,
    required this.getNearbySpaces,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color.fromARGB(66, 26, 18, 18),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/icons/map-type-2.png",
                width: 40,
              ),
              const SizedBox(height: 20),
              const Text(
                "Enable GPS",
                style: TextStyle(
                  color: Colors.black45,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Please enable your GPS Location to see nearby parking spaces.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          getNearbySpaces();
                        },
                        child: const Text(
                          "Turn on GPS",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NoNearbySpaces extends StatelessWidget {
  const NoNearbySpaces({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color.fromARGB(66, 26, 18, 18),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/icons/map-type-2.png",
              width: 40,
            ),
            const SizedBox(height: 20),
            const Text(
              "No nearby parking spaces found",
              style: TextStyle(
                color: Colors.black45,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "No nearby parking spaces was found nearby your current area.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black45,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 15),
          ],
        ),
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
        right: 10,
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
              onTap: () async {
                if (await FirebaseServices.spaceExists(space.getSpaceId!) ==
                    false) {
                  showAlertDialog(context,
                      "Something went wrong. Pull down to refresh the app");
                  return;
                }

                if (await FirebaseServices.spaceDisabled(space.getSpaceId!) ==
                    true) {
                  showAlertDialog(context,
                      "Something went wrong. Pull down to refresh the app");
                  return;
                }

                bool verified =
                    await ParkingSpaceServices.isVerified(space.getSpaceId!);

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
                onTap: () async {
                  if (await FirebaseServices.spaceExists(space.getSpaceId!) ==
                      false) {
                    showAlertDialog(context,
                        "Something went wrong. Pull down to refresh the app");
                    return;
                  }

                  if (await FirebaseServices.spaceDisabled(space.getSpaceId!) ==
                      true) {
                    showAlertDialog(context,
                        "Something went wrong. Pull down to refresh the app");
                    return;
                  }

                  bool verified =
                      await ParkingSpaceServices.isVerified(space.getSpaceId!);

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
                                  "${space.getRating!.toInt()} • ${getDistance(distance)} • ${space.getType}",
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
            onPressed: () async {
              if (await FirebaseServices.spaceExists(space.getSpaceId!) ==
                  false) {
                showAlertDialog(context,
                    "Something went wrong. Pull down to refresh the app");
                return;
              }

              if (await FirebaseServices.spaceDisabled(space.getSpaceId!) ==
                  true) {
                showAlertDialog(context,
                    "Something went wrong. Pull down to refresh the app");
                return;
              }

              bool verified =
                  await ParkingSpaceServices.isVerified(space.getSpaceId!);
              bool? proceed = true;

              if (!(verified && space.getRating! >= 4)) {
                proceed = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Center(
                      child: Image.asset(
                        "assets/logo/app_icon.png",
                        scale: 20,
                      ),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Unverified parking space",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text(
                                  "Please be advised that you are about to rent a parking space that is not yet verified.",
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        child: const Text("Proceed anyway"),
                      ),
                    ],
                  ),
                );
              }

              if (proceed == null) {
                return;
              }

              if (proceed == false) {
                return;
              }

              bool cont = false;

              globals.nonReservable = space;
              space.getDailyOrMonthly!.compareTo("Monthly") == 0
                  ? await Navigator.push(
                      context,
                      MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (context) => CheckoutMonthly(
                          parkingSpace: space,
                        ),
                      ),
                    ).then((value) {
                      if (value != null) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return (NoticeDialog(
                              imageLink: "assets/logo/lets-park-logo.png",
                              message:
                                  "Your booking at ${space.getAddress!} has been cancelled.",
                            ));
                          },
                        );
                      }
                    })
                  : space.getType!.compareTo("Reservable") == 0
                      ? await Navigator.push(
                          context,
                          MaterialPageRoute(
                            fullscreenDialog: true,
                            builder: (context) => Checkout(
                              parkingSpace: space,
                            ),
                          ),
                        ).then((value) {
                          if (value != null) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return (NoticeDialog(
                                  imageLink: "assets/logo/lets-park-logo.png",
                                  message:
                                      "Your booking at ${space.getAddress!} has been cancelled.",
                                ));
                              },
                            );
                          }
                        })
                      : await showDialog(
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
                        ).then((value) {
                          cont = value;
                        });

              if (cont) {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (context) => NonReservableCheckout(
                      parkingSpace: globals.nonReservable,
                    ),
                  ),
                ).then((value) {
                  if (value != null) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return (NoticeDialog(
                          imageLink: "assets/logo/lets-park-logo.png",
                          message:
                              "Your booking at ${space.getAddress!} has been cancelled.",
                        ));
                      },
                    );
                  }
                });
              }
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

  void showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Center(
          child: Image.asset(
            "assets/logo/app_icon.png",
            scale: 20,
          ),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Close"),
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

class TopSpacesGrid extends StatefulWidget {
  const TopSpacesGrid({Key? key}) : super(key: key);

  @override
  State<TopSpacesGrid> createState() => TopSpacesGridState();
}

class TopSpacesGridState extends State<TopSpacesGrid> {
  List<ParkingSpace> spaces = [];
  bool loading = true;

  @override
  void initState() {
    getTopParkingSpaces();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Shimmer.fromColors(
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(0),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              shrinkWrap: true,
              children: [
                Container(
                  height: 200,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    color: Colors.grey.shade300,
                  ),
                ),
                Container(
                  height: 200,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    color: Colors.grey.shade300,
                  ),
                ),
                Container(
                  height: 200,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    color: Colors.grey.shade300,
                  ),
                ),
                Container(
                  height: 200,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    color: Colors.grey.shade300,
                  ),
                ),
              ],
            ),
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
          )
        : spaces.isNotEmpty
            ? GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(0),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                shrinkWrap: true,
                children: spaces
                    .map((space) => TopSpace(
                          space: space,
                        ))
                    .toList(),
              )
            : const NoTopParkingSpaces();
  }

  void getTopParkingSpaces() async {
    setState(() {
      loading = true;
    });
    spaces.clear();
    await FirebaseServices.getTop5ParkingSpace().then((value) {
      value.docs.forEach((space) {
        if (space.data()["disabled"] == false) {
          spaces.add(ParkingSpace.fromJson(space.data()));
        }
      });
      setState(() {
        loading = false;
      });
    });
  }
}

class TopSpace extends StatelessWidget {
  final ParkingSpace space;
  const TopSpace({
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
                "${space.getRating!.toInt()}",
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
              onPressed: () async {
                if (await FirebaseServices.spaceExists(space.getSpaceId!) ==
                    false) {
                  showAlertDialog(context,
                      "Something went wrong. Pull down to refresh the app");
                  return;
                }

                if (await FirebaseServices.spaceDisabled(space.getSpaceId!) ==
                    true) {
                  showAlertDialog(context,
                      "Something went wrong. Pull down to refresh the app");
                  return;
                }

                bool verified =
                    await ParkingSpaceServices.isVerified(space.getSpaceId!);

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
          ),
        ),
      ],
    );
  }

  void showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Center(
          child: Image.asset(
            "assets/logo/app_icon.png",
            scale: 20,
          ),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}

class NoTopParkingSpaces extends StatelessWidget {
  const NoTopParkingSpaces({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color.fromARGB(66, 26, 18, 18),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.star_rounded,
              color: Colors.amber,
              size: 25,
            ),
            SizedBox(height: 20),
            Text(
              "No parking space(s) has been rated yet.",
              style: TextStyle(
                color: Colors.black45,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "We are sorry but there are no currently reviewed parkings spaces at the moment.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black45,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MonthlyParkingSpaceGrid extends StatefulWidget {
  const MonthlyParkingSpaceGrid({Key? key}) : super(key: key);

  @override
  State<MonthlyParkingSpaceGrid> createState() =>
      MonthlyParkingSpaceGridState();
}

class MonthlyParkingSpaceGridState extends State<MonthlyParkingSpaceGrid> {
  List<ParkingSpace> spaces = [];
  bool loading = true;

  @override
  void initState() {
    getMonthlyParkingSpaces();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Shimmer.fromColors(
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(0),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              shrinkWrap: true,
              children: [
                Container(
                  height: 200,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    color: Colors.grey.shade300,
                  ),
                ),
                Container(
                  height: 200,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    color: Colors.grey.shade300,
                  ),
                ),
                Container(
                  height: 200,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    color: Colors.grey.shade300,
                  ),
                ),
                Container(
                  height: 200,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    color: Colors.grey.shade300,
                  ),
                ),
              ],
            ),
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
          )
        : spaces.isNotEmpty
            ? GridView.count(
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
              )
            : const NoMonthlyParkingsView();
  }

  void getMonthlyParkingSpaces() async {
    setState(() {
      loading = true;
    });
    spaces.clear();
    await FirebaseServices.getMonthlyParkingSpaces().then((value) {
      value.docs.forEach((space) {
        if (space.data()["disabled"] == false) {
          spaces.add(ParkingSpace.fromJson(space.data()));
        }
      });
      setState(() {
        loading = false;
      });
    });
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
                    Image.asset(
                      "assets/icons/marker.png",
                      width: 12,
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
                    if (await FirebaseServices.spaceExists(space.getSpaceId!) ==
                        false) {
                      showAlertDialog(context,
                          "Something went wrong. Pull down to refresh the app");
                      return;
                    }

                    if (await FirebaseServices.spaceDisabled(
                            space.getSpaceId!) ==
                        true) {
                      showAlertDialog(context,
                          "Something went wrong. Pull down to refresh the app");
                      return;
                    }

                    bool verified = await ParkingSpaceServices.isVerified(
                        space.getSpaceId!);

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

  void showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Center(
          child: Image.asset(
            "assets/logo/app_icon.png",
            scale: 20,
          ),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}

class NoMonthlyParkingsView extends StatelessWidget {
  const NoMonthlyParkingsView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color.fromARGB(66, 26, 18, 18),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/icons/parking-marker-monthly.png",
              width: 40,
            ),
            const SizedBox(height: 20),
            const Text(
              "No monthly parking spaces found",
              style: TextStyle(
                color: Colors.black45,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "We are sorry but there are no currently registered parkings spaces with monthly payment.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black45,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
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
