import 'package:flutter/material.dart';
import 'package:lets_park/models/parking.dart';
import 'package:intl/intl.dart';

class ExtensionInformation extends StatelessWidget {
  final Parking parking;
  final int notificationDate;
  final String extensionInfo;
  final String oldDeparture;
  final String oldDuration;
  const ExtensionInformation({
    Key? key,
   required this.parking,
   required this.notificationDate,
   required this.extensionInfo,
   required this.oldDeparture,
   required this.oldDuration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Extension information"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Extended for $extensionInfo",
                        style: const TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),
              Text(
                "${parking.getDriver!} extended parking session", 
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Text(
                    "Extended on ${getDate(notificationDate)}",
                    style: const TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    " • ${getStatus()}",
                    style: TextStyle(
                      color: getStatus().compareTo("In Progress") == 0 ? Colors.green : getStatus().compareTo("Upcoming") == 0 ? Colors.blue : Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                "Duration", 
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                extensionInfo,
                style: const TextStyle(
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Parking ID", 
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "${parking.getParkingId!}",
                style: const TextStyle(
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 10),
              const Divider(),
              Container(
                padding: EdgeInsets.all(10),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blueGrey[900],
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Booking information", 
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "See adjusted booking below.",
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 1,
                      width: double.infinity,
                      color: Colors.green[400],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(10),
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
                        Text("${getDateTime(parking.getArrival!)}"),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Departure"),
                        Text(oldDeparture),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Duration"),
                        Text(oldDuration),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.green,
                ), 
              ),
              const SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(10),
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
                        Text("${getDateTime(parking.getArrival!)}"),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Departure"),
                        Text("${getDateTime(parking.getDeparture!)}"),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Duration"),
                        Text("${parking.getDuration!}"),
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
                padding: EdgeInsets.all(10),
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
                      "assets/icons/gpay-logo.png",
                      width: 40,
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
                            style: TextStyle(
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

  String getDate(int date){
    return DateFormat('MMM. dd, yyyy').format(DateTime.fromMillisecondsSinceEpoch(date));
  }

  String getDateTime(int date){
    return DateFormat('MMM. dd, yyyy h:mm a').format(DateTime.fromMillisecondsSinceEpoch(date));
  }

  String getStatus(){
    if (parking.isInProgress!){
      return "In Progress";
    }

    if (parking.isUpcoming!){
      return "Upcoming";
    }

    if (parking.isInHistory!){
      return "Finished";
    }

    return "";
  }
}