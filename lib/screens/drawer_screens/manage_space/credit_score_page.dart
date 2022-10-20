import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lets_park/services/parking_space_services.dart';
import 'package:lets_park/models/report.dart';

class CreditScorePage extends StatefulWidget {
  final String spaceId;
  final int creditScore;
  const CreditScorePage({
    Key? key,
    required this.spaceId,
    required this.creditScore,
  }) : super(key: key);

  @override
  State<CreditScorePage> createState() => _CreditScorePageState();
}

class _CreditScorePageState extends State<CreditScorePage> {
  List<Report> reports = [];

  @override
  initState(){


    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Credit score"),
        backgroundColor: Colors.red.shade400,
        actions: [
          IconButton(
            onPressed: (){
              setState((){});
            },
            icon: Icon(Icons.stop),
          ),
        ],
      ),
      body: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: ParkingSpaceServices.getSpaceReports(widget.spaceId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {

            reports.clear();
            snapshot.data!.docs.forEach((report) {
              reports.add(Report.fromJson(report.data()));
            });

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.warning_rounded,
                                color: Colors.red.shade700,
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text(
                                  "Be aware that reaching 0 points of credit will result to disabling your parking space automatically.",
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "Credit Score"
                    ),
                    const SizedBox(height: 5),
                    Card(
                      elevation: 1,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          children: [
                            Center(
                              child: Text(
                                widget.creditScore <= 4 ? "Poor" : widget.creditScore <= 7 ? "Good" : "Excellent", 
                                style: TextStyle(
                                  color: widget.creditScore <= 4 ? Colors.red : widget.creditScore <= 7 ? Colors.orange : Colors.green, 
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Center(
                              child: Text(
                                "${widget.creditScore}/10",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "Credit Score History",
                    ),
                    const SizedBox(height: 15),

                    reports.isNotEmpty ? Column(
                      children: reports.map(buildCard).toList(),
                    )
                    :
                    const Card(
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
                          "No reports to show.",
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        )),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Widget buildCard(Report report){
    return report.getReportType!.compareTo("Merit") == 0 ? buildMeritCard(report.getReportDate!) : buildDemeritCard(report.getReporter!, report.getReportDate!, report.getMessage!);
  }

  Card buildMeritCard(int date){
    return Card(
      elevation: 3,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(5),
        ),
      ),
      child: Container(
        child: Row(
          children: [
            Container(
              width: 5,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.shade400,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5),
                  bottomLeft: Radius.circular(5),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Added 1 credit score point",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "Merit date: ${getDate(date)}",
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Reason",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "A user rated your space 4-5 stars",
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: const Text(
                "+1 point",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Card buildDemeritCard(String username, int date, String reason){
    return Card(
      elevation: 3,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(5),
        ),
      ),
      child: Container(
        child: Row(
          children: [
            Container(
              width: 5,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.shade700,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5),
                  bottomLeft: Radius.circular(5),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$username reported your space",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "Reported on ${getDate(date)}",
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Reason",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          reason,
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: const Text(
                "-1 point",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getDate(int date){
    return DateFormat('MMM. dd, yyyy').format(DateTime.fromMillisecondsSinceEpoch(date));
  }
}
