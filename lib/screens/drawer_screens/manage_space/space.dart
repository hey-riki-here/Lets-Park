// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lets_park/main.dart';
import 'package:lets_park/models/parking.dart';
import 'package:lets_park/models/parking_space.dart';
import 'package:lets_park/screens/drawer_screens/manage_space/update_parking_space.dart';
import 'package:lets_park/screens/popups/notice_dialog.dart';
import 'package:lets_park/services/parking_space_services.dart';
import 'package:lets_park/shared/shared_widgets.dart';
import 'package:lets_park/models/review.dart';
import 'package:lets_park/globals/globals.dart' as globals;
import 'package:lets_park/screens/drawer_screens/manage_space/credit_score_page.dart';

class Space extends StatefulWidget {
  final ParkingSpace space;
  final String title;
  const Space({Key? key, required this.space, required this.title})
      : super(key: key);

  @override
  State<Space> createState() => _SpaceState();
}

class _SpaceState extends State<Space> {
  final _sharedWidgets = SharedWidget();
  final textStyle = const TextStyle(
    fontSize: 16,
  );
  final controller = TextEditingController();
  final key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final space = widget.space;
    final title = widget.title;
    final capacity = space.getCapacity;
    int availableSlot = 0;
    List<Parking> inProgressParkings = [];
    final List<Review> reviews = [];
    bool disableButton = true,
        isLoading = false,
        isDisabled = space.isDisabled!;

    return Scaffold(
      appBar: _sharedWidgets.manageSpaceAppBar("Space $title"),
      backgroundColor: Colors.grey.shade100,
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream:
              ParkingSpaceServices.getParkingSessionsDocs(space.getSpaceId!),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              int occupied = 0;
              inProgressParkings.clear();
              snapshot.data!.docs.forEach((parking) {
                if (parking.data()["inProgress"] == true) {
                  occupied++;
                  inProgressParkings.add(Parking.fromJson(parking.data()));
                }
              });
              availableSlot = space.getCapacity! - occupied;
            }
            return ListView(
              padding: const EdgeInsets.all(12),
              children: [
                Card(
                  elevation: 2,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(12),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Available slots",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              child: Center(
                                child: Text(
                                  "$availableSlot",
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(100),
                                ),
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.green,
                                  width: 2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: "$availableSlot",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        height: 2,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const TextSpan(
                                      text: " available slot(s) out of ",
                                      style: TextStyle(
                                        height: 2,
                                        color: Colors.black,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "$capacity",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        height: 2,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const TextSpan(
                                      text: " slot(s)",
                                      style: TextStyle(
                                        height: 2,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Cars Parked",
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 10),
                inProgressParkings.isNotEmpty
                    ? SizedBox(
                        height: inProgressParkings.length > 1 ? 370 : 180,
                        child: ListView.builder(
                            itemCount: inProgressParkings.length,
                            itemBuilder: ((context, index) {
                              return Card(
                                elevation: 2,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: Colors.white,
                                            backgroundImage: NetworkImage(
                                              inProgressParkings[index]
                                                  .getDriverImage!,
                                            ),
                                            radius: 25,
                                          ),
                                          const SizedBox(width: 15),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                inProgressParkings[index]
                                                    .getDriver!,
                                                style: textStyle,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.star,
                                                    color:
                                                        Colors.yellow.shade600,
                                                    size: 15,
                                                  ),
                                                  Icon(
                                                    Icons.star,
                                                    color:
                                                        Colors.yellow.shade600,
                                                    size: 15,
                                                  ),
                                                  Icon(
                                                    Icons.star,
                                                    color:
                                                        Colors.yellow.shade600,
                                                    size: 15,
                                                  ),
                                                  Icon(
                                                    Icons.star,
                                                    color:
                                                        Colors.yellow.shade600,
                                                    size: 15,
                                                  ),
                                                  Icon(
                                                    Icons.star,
                                                    color:
                                                        Colors.yellow.shade600,
                                                    size: 15,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          const Icon(
                                            FontAwesomeIcons.carAlt,
                                            color: Colors.blue,
                                            size: 30,
                                          ),
                                          const SizedBox(width: 15),
                                          Text(
                                            inProgressParkings[index]
                                                .getPlateNumber!,
                                            style: textStyle,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.access_time,
                                            color: Colors.blue,
                                            size: 30,
                                          ),
                                          const SizedBox(width: 15),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Arrival:",
                                                      style: textStyle,
                                                    ),
                                                    Text(
                                                      _getFormattedTime(
                                                        DateTime
                                                            .fromMillisecondsSinceEpoch(
                                                          inProgressParkings[
                                                                  index]
                                                              .getArrival!,
                                                        ),
                                                      ),
                                                      style: textStyle.copyWith(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 5),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Departure:",
                                                      style: textStyle,
                                                    ),
                                                    Text(
                                                      _getFormattedTime(
                                                        DateTime
                                                            .fromMillisecondsSinceEpoch(
                                                          inProgressParkings[
                                                                  index]
                                                              .getDeparture!,
                                                        ),
                                                      ),
                                                      style: textStyle.copyWith(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 5),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Duration:",
                                                      style: textStyle,
                                                    ),
                                                    Text(
                                                      inProgressParkings[index]
                                                          .getDuration!,
                                                      style: textStyle.copyWith(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            })),
                      )
                    : const Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(12),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                              child: Text(
                            "No cars parked today.",
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          )),
                        ),
                      ),
                const SizedBox(height: 10),
                const Text(
                  "Reviews",
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 10),
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: ParkingSpaceServices.getParkingSpaceReviews(
                        space.getSpaceId!),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        reviews.clear();
                        snapshot.data!.docs.forEach((review) {
                          reviews.add(Review.fromJson(review.data()));
                        });
                      }
                      return reviews.isEmpty
                          ? const Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                    child: Text(
                                  "No reviews yet.",
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                )),
                              ),
                            )
                          : SizedBox(
                              height: 180,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: reviews.length,
                                itemBuilder: ((context, index) {
                                  return SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width - 20,
                                    child: Card(
                                      elevation: 2,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(12),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                  backgroundColor: Colors.white,
                                                  backgroundImage: NetworkImage(
                                                      reviews[index]
                                                          .getDisplayPhoto!),
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
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
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
                                            getStars(reviews[index]
                                                .getRating!
                                                .toInt()),
                                            const SizedBox(height: 10),
                                            Text(reviews[index].getReview!),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            );
                    }),
                const SizedBox(height: 10),
                const Text(
                  "Caretaker",
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  elevation: 2,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(12),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.black12,
                          backgroundImage: NetworkImage(
                            space.getCaretakerPhotoUrl!,
                          ),
                          radius: 40,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.person,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              space.getCaretakerName!,
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.phone,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              space.getCaretakerPhoneNumber!,
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Settings",
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  elevation: 2,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(12),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextButton(
                          onPressed: () async {
                            bool result = await ParkingSpaceServices.canModify(
                                    space.getSpaceId!)
                                .then((canModify) => canModify);
                            if (result) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      UpdateParkingSpace(
                                    space: space,
                                  ),
                                ),
                              ).then((value) {
                                setState(() {});
                              });
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return (const NoticeDialog(
                                    imageLink: "assets/logo/lets-park-logo.png",
                                    message:
                                        "You cannot update, delete, or disable a parking space when there is an active booking or parking session.",
                                    forWarning: true,
                                  ));
                                },
                              );
                            }
                          },
                          child: const Text("Update parking space"),
                        ),
                        TextButton(
                          onPressed: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) => CreditScorePage(
                                  spaceId: widget.space.getSpaceId!,
                                  creditScore: widget.space.getCreditScore!,
                                ),
                              ),
                            );
                          },
                          child: const Text("Credit score"),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            primary: space.isDisabled!
                                ? Colors.green.shade500
                                : Colors.red.shade300,
                          ),
                          onPressed: () async {
                            bool result = await ParkingSpaceServices.canModify(
                                    space.getSpaceId!)
                                .then((canModify) => canModify);

                            if (result == true) {
                              await showDialog<String>(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) =>
                                    StatefulBuilder(
                                  builder: (context, setState) => AlertDialog(
                                    title: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: isDisabled
                                            ? Colors.green.shade50
                                            : Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.warning_rounded,
                                                color: isDisabled
                                                    ? Colors.green.shade800
                                                    : Colors.red.shade800,
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  isLoading
                                                      ? isDisabled
                                                          ? "Enabling parking space"
                                                          : "Disabling parking space."
                                                      : isDisabled
                                                          ? "Enable this parking space?"
                                                          : "Disable this parking space ?",
                                                  style: TextStyle(
                                                    color: isDisabled
                                                        ? Colors.green.shade800
                                                        : Colors.red.shade800,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                //
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 15),
                                          Text(
                                            isLoading
                                                ? "Please wait..."
                                                : isDisabled
                                                    ? "Doing so will continue the parking space to receive bookings."
                                                    : "Doing so will make the parking space unable to receive bookings.",
                                            style: TextStyle(
                                              color: isDisabled
                                                  ? Colors.green.shade900
                                                  : Colors.red.shade900,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    content: isLoading
                                        ? Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: const [
                                              CircularProgressIndicator(),
                                            ],
                                          )
                                        : Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "Parking space",
                                                style: TextStyle(
                                                  color: Colors.black54,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                "Space $title",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              Text(
                                                "Are you sure you want to ${isDisabled ? "enable" : "disable"} this space?",
                                              ),
                                            ],
                                          ),
                                    actions: isLoading
                                        ? []
                                        : [
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                primary: Colors.black54,
                                              ),
                                              onPressed: () => Navigator.pop(
                                                  context, 'Cancel'),
                                              child: const Text('Cancel'),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                right: 10,
                                              ),
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  setState(() {
                                                    isLoading = true;
                                                  });
                                                  ParkingSpaceServices
                                                      .updateDisableStatus(
                                                    space.getSpaceId!,
                                                    !space.isDisabled!,
                                                  );
                                                  Navigator.pop(
                                                    context,
                                                    "Confirm",
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  primary: isDisabled
                                                      ? Colors.green.shade800
                                                      : Colors.red.shade800,
                                                  elevation: 0,
                                                ),
                                                child: const Text(
                                                  "Confirm",
                                                ),
                                              ),
                                            ),
                                          ],
                                  ),
                                ),
                              ).then((value) {
                                if (value!.compareTo("Confirm") == 0) {
                                  Navigator.of(context).pop();
                                }
                              });
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return (const NoticeDialog(
                                    imageLink: "assets/logo/lets-park-logo.png",
                                    message:
                                        "You cannot update, delete, or disable a parking space when there is an active booking or parking session.",
                                    forWarning: true,
                                  ));
                                },
                              );
                            }
                          },
                          child: Text(
                            isDisabled ? "Enable space" : "Disable space",
                            style: const TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            primary: Colors.red.shade300,
                          ),
                          onPressed: () async {
                            bool result = await ParkingSpaceServices.canModify(
                                    space.getSpaceId!)
                                .then((canModify) => canModify);
                            if (result) {
                              await showDialog<String>(
                                context: context,
                                builder: (BuildContext context) =>
                                    StatefulBuilder(
                                  builder: (context, setState) => AlertDialog(
                                    title: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.warning_rounded,
                                                color: Colors.red.shade800,
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  isLoading
                                                      ? "Deleting parking space"
                                                      : "Delete this parking space ?",
                                                  style: TextStyle(
                                                    color: Colors.red.shade800,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                //
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 15),
                                          Text(
                                            isLoading
                                                ? "Please wait..."
                                                : "Deleting this parking space will delete all the data including earnings, upcoming parkings, and parking history..",
                                            style: TextStyle(
                                              color: Colors.red.shade900,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    content: isLoading
                                        ? Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: const [
                                              CircularProgressIndicator(),
                                            ],
                                          )
                                        : Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "Parking space id",
                                                style: TextStyle(
                                                  color: Colors.black54,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                "Space $title",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              const Text(
                                                "Are you sure you want to delete this space? Please type the space id.",
                                              ),
                                              const SizedBox(height: 10),
                                              Form(
                                                key: key,
                                                child: TextFormField(
                                                  controller: controller,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      if (value.compareTo(
                                                              "Space $title") ==
                                                          0) {
                                                        disableButton = false;
                                                      } else {
                                                        disableButton = true;
                                                      }
                                                    });
                                                  },
                                                  decoration: InputDecoration(
                                                    hintText: "Space $title",
                                                    border:
                                                        const OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(12),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                    actions: [
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          primary: Colors.black54,
                                        ),
                                        onPressed: () =>
                                            Navigator.pop(context, 'Cancel'),
                                        child: const Text('Cancel'),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          right: 10,
                                        ),
                                        child: ElevatedButton(
                                          onPressed: disableButton
                                              ? null
                                              : () async {
                                                  setState(() {
                                                    isLoading = true;
                                                  });
                                                  ParkingSpaceServices
                                                      .deleteParkingSpace(
                                                    space.getSpaceId!,
                                                  );
                                                  Navigator.pop(
                                                    context,
                                                    "Confirm",
                                                  );
                                                },
                                          style: ElevatedButton.styleFrom(
                                            primary: Colors.red.shade800,
                                            elevation: 0,
                                          ),
                                          child: const Text(
                                            "Confirm",
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ).then((value) {
                                if (value!.compareTo("Confirm") == 0) {
                                  if (globals.userData.getOwnedParkingSpaces!
                                          .length ==
                                      1) {
                                    navigatorKey.currentState!
                                        .popUntil((route) => route.isFirst);
                                  } else {
                                    Navigator.pop(context);
                                  }
                                }
                              });
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return (const NoticeDialog(
                                    imageLink: "assets/logo/lets-park-logo.png",
                                    message:
                                        "You cannot update, delete, or disable a parking space when there is an active booking or parking session.",
                                    forWarning: true,
                                  ));
                                },
                              );
                            }
                          },
                          child: Text(
                            "Delete space",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.red.shade300,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
    );
  }

  String _getFormattedTime(DateTime time) {
    String formattedTime = "";
    DateTime arrival = DateTime(
      time.year,
      time.month,
      time.day,
    );

    arrival.compareTo(_getDateTimeNow()) == 0
        ? formattedTime += "Today at "
        : formattedTime += DateFormat('MMM. dd, yyyy ').format(arrival) + "at ";
    formattedTime += DateFormat("h:mm a").format(time);
    return formattedTime;
  }

  DateTime _getDateTimeNow() {
    return DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
  }

  Row getStars(int stars) {
    List<Widget> newChildren = [];

    for (int i = 0; i < stars; i++) {
      newChildren.add(
        const Icon(
          Icons.star,
          color: Colors.amber,
          size: 16,
        ),
      );
    }
    return Row(children: newChildren);
  }
}
