// ignore_for_file: import_of_legacy_library_into_null_safe, avoid_function_literals_in_foreach_calls

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lets_park/models/parking_space.dart';
import 'package:lets_park/models/review.dart';
import 'package:lets_park/screens/popups/checkout.dart';
import 'package:lets_park/screens/popups/checkout_monthly.dart';
import 'package:lets_park/screens/popups/checkout_non_reservable.dart';
import 'package:lets_park/screens/popups/email_verification.dart';
import 'package:lets_park/screens/popups/notice_dialog.dart';
import 'package:lets_park/screens/popups/space_certificates.dart';
import 'package:lets_park/services/firebase_api.dart';
import 'package:lets_park/services/parking_space_services.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:lets_park/services/user_services.dart';
import 'package:location/location.dart';
import 'package:lets_park/globals/globals.dart' as globals;
import 'package:url_launcher/url_launcher.dart' as launcher;

class ParkingAreaInformation extends StatefulWidget {
  final ParkingSpace parkingSpace;
  final bool verified;
  const ParkingAreaInformation({
    Key? key,
    required this.parkingSpace,
    required this.verified,
  }) : super(key: key);

  @override
  State<ParkingAreaInformation> createState() => _ParkingAreaInformationState();
}

class _ParkingAreaInformationState extends State<ParkingAreaInformation> {
  final ScrollController _scrollController = ScrollController();
  bool lastStatus = true;
  Icon _favIcon = const Icon(
    Icons.favorite_outline,
  );
  bool _added = false;
  String destinationDistance = "";
  bool isLocationEnabled = false;

  @override
  void initState() {
    _scrollController.addListener(_scrollListener);

    _favIcon = Icon(
      globals.favorites.contains(widget.parkingSpace.getSpaceId!)
          ? Icons.favorite_outlined
          : Icons.favorite_outline,
      color: globals.favorites.contains(widget.parkingSpace.getSpaceId!)
          ? Colors.red
          : Colors.white,
    );

    _added = globals.favorites.contains(widget.parkingSpace.getSpaceId!)
        ? true
        : false;

    toDestination();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 3,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          slivers: <Widget>[
            SliverAppBar(
              iconTheme: IconThemeData(
                color: isShrink ? Colors.black : Colors.white,
              ),
              title: isShrink
                  ? Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Image.network(
                              widget.parkingSpace.getImageUrl!,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Space information",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    )
                  : const Text("Space information"),
              backgroundColor: Colors.white,
              stretch: true,
              floating: false,
              pinned: true,
              onStretchTrigger: () {
                return Future<void>.value();
              },
              expandedHeight: 300.0,
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const <StretchMode>[
                  StretchMode.zoomBackground,
                  StretchMode.blurBackground,
                  StretchMode.fadeTitle,
                ],
                background: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    Image.network(
                      widget.parkingSpace.getImageUrl!,
                      fit: BoxFit.cover,
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(0.0, 0.5),
                          end: Alignment.center,
                          colors: <Color>[
                            Color(0x60000000),
                            Color(0x00000000),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_added) {
                        _favIcon = const Icon(
                          Icons.favorite_outline,
                        );
                        showNotice(
                          context,
                          "Parking space remove from My Favorites",
                        );
                        UserServices.removeSpaceonFavorites(
                          FirebaseAuth.instance.currentUser!.uid,
                          widget.parkingSpace.getSpaceId!,
                        );
                        _added = false;
                      } else {
                        _favIcon = const Icon(
                          Icons.favorite_outlined,
                          color: Colors.red,
                        );
                        showNotice(
                            context, "Parking space added to My Favorites");
                        UserServices.addSpaceonFavorites(
                          FirebaseAuth.instance.currentUser!.uid,
                          widget.parkingSpace.getSpaceId!,
                        );
                        _added = true;
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: _favIcon,
                  ),
                ),
              ],
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Header(
                    space: widget.parkingSpace,
                    verified: widget.verified,
                  ),
                  PriceAndDistance(
                    distance: destinationDistance,
                    isLocationEnabled: isLocationEnabled,
                    dailyOrMonthly: widget.parkingSpace.getDailyOrMonthly!,
                  ),
                  const TabBar(
                    labelColor: Colors.black,
                    indicatorColor: Colors.black,
                    indicatorSize: TabBarIndicatorSize.label,
                    tabs: [
                      Tab(
                        child: Text(
                          "Information",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Tab(
                        child: Text(
                          "Reviews",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Tab(
                        child: Text(
                          "Instructions",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SliverFillRemaining(
              child: ScrollConfiguration(
                behavior: ScrollWithoutGlowBehavior(),
                child: InfoReviewsCaretaker(
                  spaceId: widget.parkingSpace.getSpaceId!,
                  info: widget.parkingSpace.getInfo!,
                  rules: widget.parkingSpace.getRules!,
                  features: widget.parkingSpace.getFeatures!,
                  capacity: widget.parkingSpace.getCapacity!,
                  verticalClearance: widget.parkingSpace.getVerticalClearance!,
                  type: widget.parkingSpace.getType!,
                  caretakerPhoneNumber:
                      widget.parkingSpace.getCaretakerPhoneNumber!,
                  certificatesUrl: widget.parkingSpace.getCertificates!,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 80,
        ),
        child: ElevatedButton(
          onPressed: () async {
            if (FirebaseAuth.instance.currentUser!.emailVerified == false) {
              showAlertDialog(
                context,
                "Looks like your email is not yet verified. Please verify the email to continue renting the parking space.",
              );
              return;
            }

            bool? proceed = true;

            if (!widget.verified) {
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
                                "Please be advied that you are about to rent a parking space that is not yet verified.",
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
            globals.nonReservable = widget.parkingSpace;
            widget.parkingSpace.getDailyOrMonthly!.compareTo("Monthly") == 0
                ? await Navigator.push(
                    context,
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (context) => CheckoutMonthly(
                        parkingSpace: widget.parkingSpace,
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
                                "Your booking at ${widget.parkingSpace.getAddress!} has been cancelled.",
                          ));
                        },
                      );
                    }
                  })
                : widget.parkingSpace.getType!.compareTo("Reservable") == 0
                    ? await Navigator.push(
                        context,
                        MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (context) => Checkout(
                            parkingSpace: widget.parkingSpace,
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
                                    "Your booking at ${widget.parkingSpace.getAddress!} has been cancelled.",
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
                          parkingAreaAddress: widget.parkingSpace.getAddress!,
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
                            "Your booking at ${widget.parkingSpace.getAddress!} has been cancelled.",
                      ));
                    },
                  );
                }
              });
            }
          },
          child: const Text(
            "Rent parking space",
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 18,
            ),
          ),
          style: ElevatedButton.styleFrom(
            primary: Colors.lightBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50.0),
            ),
          ),
        ),
      ),
    );
  }

  _scrollListener() {
    if (isShrink != lastStatus) {
      setState(() {
        lastStatus = isShrink;
      });
    }
  }

  bool get isShrink {
    return _scrollController.hasClients &&
        _scrollController.offset > (200 - kToolbarHeight);
  }

  void showNotice(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 5),
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
        content: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Verify Email Address",
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
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
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
              Navigator.pop(context);
            },
            child: const Text("MAYBE LATER"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (context) => const EmailVerification(),
                ),
              );
            },
            child: const Text("VERIFY EMAIL NOW"),
          ),
        ],
      ),
    );
  }

  void toDestination() async {
    if (mounted) {
      Location location = Location();

      bool _serviceEnabled;
      _serviceEnabled = await location.serviceEnabled();
      if (_serviceEnabled) {
        setState(() {
          isLocationEnabled = true;
        });
      }
      var position = await geolocator.Geolocator().getCurrentPosition(
          desiredAccuracy: geolocator.LocationAccuracy.high);

      double distance = FirebaseServices.calculateDistance(
        position.latitude,
        position.longitude,
        widget.parkingSpace.getLatLng!.latitude,
        widget.parkingSpace.getLatLng!.longitude,
      );
      if (mounted) {
        setState(() {
          destinationDistance = getDistance(distance);
          isLocationEnabled = true;
        });
      }
    }
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

class Header extends StatefulWidget {
  final ParkingSpace space;
  final bool verified;
  const Header({
    Key? key,
    required this.space,
    required this.verified,
  }) : super(key: key);

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  int sessionsQty = 0, reviewsQty = 0;

  @override
  void initState() {
    getParkingReviews();
    getParkingSessions();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.space.getAddress!,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w400,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      widget.verified
                          ? const Icon(
                              Icons.verified,
                              color: Colors.blue,
                              size: 14,
                            )
                          : const SizedBox(),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      ParkingSpaceServices.getStars(widget.space.getRating!),
                      const SizedBox(width: 5),
                      Text(
                        "($reviewsQty)",
                        style: const TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        widget.space.getType!,
                        style: TextStyle(
                          color: Colors.blue[300],
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text("/"),
                      const SizedBox(width: 5),
                      Text(
                        widget.space.getDailyOrMonthly!,
                        style: TextStyle(
                          color: Colors.blue[300],
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text("/"),
                      const SizedBox(width: 5),
                      Text(
                        sessionsQty > 1
                            ? "$sessionsQty Parkings"
                            : "$sessionsQty Parking",
                        style: TextStyle(
                          color: Colors.blue[300],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () => callCaretaker(widget.space.getCaretakerPhoneNumber!),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            color: Colors.green.shade300,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          const Text(
                            "Call caretaker",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: Colors.grey.shade700,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SpaceCertificates(
                      space: widget.space,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.wysiwyg_rounded,
                            color: Colors.blue.shade300,
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            "Certificates",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: Colors.grey.shade700,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),
          ],
        ),
      ],
    );
  }

  void showAlertDialog() {
    showDialog(
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
              "Certificates",
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
                borderRadius: const BorderRadius.all(Radius.circular(8)),
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
                      "View the certificates below for your reference.",
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // GalleryImage(
            //   titleGallery: "Business Certificates",
            //   numOfShowImages: 3,
            //   imageUrls: widget.space.getCertificates!,
            // ),
          ],
        ),
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

  void showNotice(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void getParkingSessions() async {
    int qty = await ParkingSpaceServices.getParkingSessionQuantity(
            widget.space.getSpaceId!)
        .then((value) => value);
    setState(() {
      sessionsQty = qty;
    });
  }

  void getParkingReviews() async {
    int qty = await ParkingSpaceServices.getParkingReviewsQuantity(
            widget.space.getSpaceId!)
        .then((value) => value);
    setState(() {
      reviewsQty = qty;
    });
  }

  void callCaretaker(String caretakerPhoneNumber) async {
    final url = "tel:0$caretakerPhoneNumber";
    if (await launcher.canLaunchUrl(Uri.parse(url))) {
      await launcher.launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }
}

class PriceAndDistance extends StatefulWidget {
  final String dailyOrMonthly;
  final String distance;
  final bool isLocationEnabled;
  const PriceAndDistance({
    Key? key,
    required this.distance,
    required this.isLocationEnabled,
    required this.dailyOrMonthly,
  }) : super(key: key);

  @override
  State<PriceAndDistance> createState() => _PriceAndDistanceState();
}

class _PriceAndDistanceState extends State<PriceAndDistance> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      width: double.infinity,
      height: 50,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        widget.dailyOrMonthly.compareTo("Daily") == 0
                            ? "50.00"
                            : "1500.00",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text("Price"),
                    ],
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      showAlertDialog(
                        widget.dailyOrMonthly.compareTo("Daily") == 0
                            ? "The flat rate for parking is 50.00 and an additional 10.00 for each succeeding hour."
                            : "The fee for monthly parking is 1500.00 for each month.",
                      );
                    },
                    child: const Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                    ),
                  ),
                ],
              ),
              Container(
                color: Colors.black54,
                width: 1,
                height: 30,
              ),
              !widget.isLocationEnabled
                  ? Column(
                      children: [
                        Icon(
                          Icons.location_off_rounded,
                          color: Colors.red[300],
                        ),
                        const Text("Location service disabled."),
                      ],
                    )
                  : widget.distance.isNotEmpty
                      ? Column(
                          children: [
                            Text(
                              "About ${widget.distance}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text("To Destination"),
                          ],
                        )
                      : Column(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.grey.shade500,
                                strokeWidth: 3,
                              ),
                            ),
                            const Text("Calculating distance"),
                          ],
                        ),
            ],
          ),
        ],
      ),
    );
  }

  void showAlertDialog(String message) {
    showDialog(
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
              "Price info",
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
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
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
              Navigator.pop(context);
            },
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}

class InfoReviewsCaretaker extends StatelessWidget {
  final String spaceId;
  final String info;
  final String rules;
  final List<String> features;
  final int capacity;
  final double verticalClearance;
  final String type;

  final String caretakerPhoneNumber;
  final List<String> certificatesUrl;
  const InfoReviewsCaretaker({
    Key? key,
    required this.spaceId,
    required this.info,
    required this.rules,
    required this.features,
    required this.capacity,
    required this.verticalClearance,
    required this.type,
    required this.caretakerPhoneNumber,
    required this.certificatesUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(
      fontSize: 20,
      color: Colors.grey,
    );

    const valueStyle = TextStyle(
      fontSize: 19,
    );

    final List<Review> reviews = [];
    return TabBarView(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 10),
                      Text("This parking space is ${type.toLowerCase()}."),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  info,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Rules",
                  style: labelStyle,
                ),
                const SizedBox(height: 12),
                Text(
                  rules,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Features",
                  style: labelStyle,
                ),
                const SizedBox(height: 12),
                getFeatures(),
                const SizedBox(height: 20),
                const Text(
                  "Capacity",
                  style: labelStyle,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      CommunityMaterialIcons.car,
                      color: Colors.blue,
                      size: 30,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "$capacity",
                      style: valueStyle,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Center(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: ParkingSpaceServices.getParkingSpaceReviews(spaceId),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                reviews.clear();
                snapshot.data!.docs.forEach((review) {
                  reviews.add(Review.fromJson(review.data()));
                });
              }
              int tag1Qty = 0,
                  tag2Qty = 0,
                  tag3Qty = 0,
                  tag4Qty = 0,
                  tag5Qty = 0;
              reviews.forEach((review) {
                review.getQuickReviews!.forEach((tag) {
                  if (tag.compareTo("Safe and Secure") == 0) {
                    tag1Qty += 1;
                  } else if (tag.compareTo("Will park again!") == 0) {
                    tag2Qty += 1;
                  } else if (tag.compareTo("Accomodating") == 0) {
                    tag3Qty += 1;
                  } else if (tag.compareTo("Clean Parking") == 0) {
                    tag4Qty += 1;
                  } else {
                    tag5Qty += 1;
                  }
                });
              });

              return reviews.isEmpty
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
                            "No reviews yet.",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: reviews.length,
                      itemBuilder: (context, index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            index == 0
                                ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Wrap(
                                        alignment: WrapAlignment.center,
                                        direction: Axis.horizontal,
                                        runSpacing: 10,
                                        children: [
                                          "Safe and Secure ($tag1Qty)",
                                          "Will park again! ($tag2Qty)",
                                          "Accomodating ($tag3Qty)",
                                          "Clean Parking ($tag4Qty)",
                                          "Easy to find ($tag5Qty)",
                                        ]
                                            .map(
                                              (tag) => QuickReviewTile(
                                                label: tag,
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                  )
                                : const SizedBox(),
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.white,
                                  backgroundImage: NetworkImage(
                                      reviews[index].getDisplayPhoto!),
                                  radius: 15,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  reviews[index].getReviewer!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: const [
                                      Icon(
                                        Icons.more_vert_rounded,
                                        color: Colors.black54,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            ParkingSpaceServices.getStars(
                              reviews[index].getRating!,
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              alignment: WrapAlignment.start,
                              direction: Axis.horizontal,
                              runSpacing: 10,
                              children: reviews[index]
                                  .getQuickReviews!
                                  .map(
                                    (tag) => QuickReviewTile(
                                      label: tag,
                                    ),
                                  )
                                  .toList(),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              reviews[index].getReview!,
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                            ),
                            const Center(
                              child: SizedBox(
                                height: 30,
                                width: 30,
                                child: Divider(
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
            },
          ),
        ),
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 30,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue[50],
                      radius: 30,
                      child: CircleAvatar(
                        backgroundColor: Colors.blue[50],
                        backgroundImage:
                            const AssetImage("assets/images/reserve.png"),
                        radius: 25,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        "This parking space is not reservable so make sure that you are at the parking area as you are paying.",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue[50],
                      radius: 30,
                      child: CircleAvatar(
                        backgroundColor: Colors.blue[50],
                        backgroundImage:
                            const AssetImage("assets/images/reserve.png"),
                        radius: 25,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        "Once arrived or payed, present the receipt sent through your email to the parking attendant.",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue[50],
                      radius: 30,
                      child: CircleAvatar(
                        backgroundColor: Colors.blue[50],
                        backgroundImage:
                            const AssetImage("assets/images/reserve.png"),
                        radius: 25,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        "You can always extend your parking session as you wish.",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget getFeatures() {
    List<Widget> newChildren = [];

    for (String feature in features) {
      if (feature.compareTo("With gate") == 0) {
        newChildren.add(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                CommunityMaterialIcons.gate,
                color: Colors.blue,
                size: 30,
              ),
              const SizedBox(width: 12),
              Text(
                feature,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 15),
            ],
          ),
        );
      } else if (feature.compareTo("CCTV") == 0) {
        newChildren.add(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                CommunityMaterialIcons.cctv,
                color: Colors.blue,
                size: 30,
              ),
              const SizedBox(width: 12),
              Text(
                feature,
                style: const TextStyle(
                  fontSize: 16,
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
                size: 30,
              ),
              const SizedBox(width: 12),
              Text(
                feature,
                style: const TextStyle(
                  fontSize: 16,
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
                size: 30,
              ),
              const SizedBox(width: 12),
              Text(
                feature,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      }
    }

    return Wrap(
      direction: Axis.horizontal,
      runSpacing: 10,
      children: newChildren,
    );
  }
}

class QuickReviewTile extends StatelessWidget {
  final String label;
  const QuickReviewTile({
    Key? key,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: Colors.white,
            border: Border.all(
              color: Colors.black26,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
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
