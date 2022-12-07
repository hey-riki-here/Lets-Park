import 'package:flutter/material.dart';
import 'package:lets_park/models/parking.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

class ParkingInformation extends StatelessWidget {
  final Parking parking;
  final int notificationDate;
  const ParkingInformation({
    Key? key,
    required this.parking,
    required this.notificationDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Parking information"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      parking.getDriverImage!,
                    ),
                    radius: 30,
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        parking.getDriver!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        getStatus().compareTo("In Progress") == 0
                            ? "Parking for ${parking.getDuration!}"
                            : getStatus().compareTo("Upcoming") == 0
                                ? "Will park for ${parking.getDuration!}"
                                : "Parked for ${parking.getDuration!}",
                        style: const TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final url = "tel:${parking.getDriverPhone!}";
                        if (await launcher.canLaunchUrl(Uri.parse(url))) {
                          await launcher.launchUrl(Uri.parse(url));
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                      icon: const Icon(
                        Icons.phone_outlined,
                      ),
                      label: Text("Call ${parking.getDriver!}"),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),
              Text(
                "${parking.getDriver!} booked on your space",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Text(
                    "Booked on ${getDate(notificationDate)}",
                    style: const TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    " • ${getStatus()}",
                    style: TextStyle(
                      color: getStatus().compareTo("In Progress") == 0
                          ? Colors.green
                          : getStatus().compareTo("Upcoming") == 0
                              ? Colors.blue
                              : Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                "Parking ID",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                parking.getParkingId!,
                style: const TextStyle(
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),
              const Text(
                "Booking information",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Colors.black26,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(3),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Arrival"),
                        Text(getDateTime(parking.getArrival!)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Departure"),
                        Text(getDateTime(parking.getDeparture!)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Duration"),
                        Text(parking.getDuration!),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),
              const Text(
                "Paid through",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Colors.black26,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(3),
                  ),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      "assets/icons/paypal_logo.png",
                      width: 30,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Paypal",
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "${parking.getPrice!}.00",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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

  String getDate(int date) {
    return DateFormat('MMM. dd, yyyy')
        .format(DateTime.fromMillisecondsSinceEpoch(date));
  }

  String getDateTime(int date) {
    return DateFormat('MMM. dd, yyyy h:mm a')
        .format(DateTime.fromMillisecondsSinceEpoch(date));
  }

  String getStatus() {
    if (parking.isInProgress!) {
      return "In Progress";
    }

    if (parking.isUpcoming!) {
      return "Upcoming";
    }

    if (parking.isInHistory!) {
      return "Finished";
    }

    return "";
  }
}
