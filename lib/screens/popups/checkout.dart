// ignore_for_file: unused_catch_clause

import 'package:flutter/material.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class Checkout extends StatefulWidget {
  const Checkout({Key? key}) : super(key: key);

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
      ),
      backgroundColor: Colors.grey.shade300,
      body: Theme(
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: const [
                  SetUpTime(),
                  Vehicle(),
                  Payment(),
                ],
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text(
                  "Pay now",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.lightBlue,
                  fixedSize: const Size(180, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SetUpTime extends StatefulWidget {
  const SetUpTime({Key? key}) : super(key: key);

  @override
  State<SetUpTime> createState() => _SetUpTimeState();
}

class _SetUpTimeState extends State<SetUpTime> {
  final labelStyle = const TextStyle(
    fontSize: 16,
  );

  final timeStampStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  DateTime? _selectedDate = DateTime.now();
  DateTime? _selectedTime;
  String _date = "Today";
  String? _time = DateFormat("h:mm a").format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Setup time",
          style: TextStyle(
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(
          width: double.infinity,
          child: Card(
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
                    "Please select the time of arrival and departure",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Arrival:", style: labelStyle),
                      Row(
                        children: [
                          Text("$_date at $_time", style: timeStampStyle),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: IconButton(
                              onPressed: () {
                                showDateTimePicker(context, "arrival");
                              },
                              padding: const EdgeInsets.all(0.0),
                              color: Colors.blue,
                              icon: const Icon(
                                FontAwesomeIcons.pencilAlt,
                                size: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Departure:", style: labelStyle),
                      Row(
                        children: [
                          Text("Today - 3:00 PM", style: timeStampStyle),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: IconButton(
                              onPressed: () async {
                                showDateTimePicker(context, "departure");
                              },
                              padding: const EdgeInsets.all(0.0),
                              color: Colors.blue,
                              icon: const Icon(
                                FontAwesomeIcons.pencilAlt,
                                size: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Duration:", style: labelStyle),
                      Row(
                        children: [
                          Text("3 Hrs", style: timeStampStyle),
                          const SizedBox(width: 25),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: Colors.black54),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total price:", style: labelStyle),
                      Row(
                        children: [
                          Text("50.00", style: timeStampStyle),
                          const SizedBox(width: 25),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<dynamic> showDateTimePicker(BuildContext context, String label) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          height: 335,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  "Please select valid time and date of " + label,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue.shade900,
                  ),
                ),
                const SizedBox(height: 20),
                TimePickerSpinner(
                  is24HourMode: false,
                  normalTextStyle: const TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                  highlightedTextStyle: const TextStyle(
                    fontSize: 23,
                    color: Colors.black,
                  ),
                  spacing: 40,
                  itemHeight: 25,
                  isForce2Digits: true,
                  onTimeChange: (time) {
                    _selectedTime = time;
                  },
                ),
                DatePickerWidget(
                  looping: false,
                  firstDate: DateTime.now(),
                  dateFormat: "MMM/dd/yyyy",
                  onChange: (DateTime newDate, _) {
                    _selectedDate = newDate;
                  },
                  pickerTheme: const DateTimePickerTheme(
                    itemTextStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 19,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        try {
                          final _dateTime = DateTime(
                            _selectedDate!.year,
                            _selectedDate!.month,
                            _selectedDate!.day,
                            _selectedTime!.hour,
                            _selectedTime!.minute,
                          );

                          getDate(_dateTime);
                        } on Exception catch (e) {
                          getDate(DateTime.now());
                        }
                      },
                      child: const Text("Confirm"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void getDate(DateTime selectedDateTime) {
    setState(() {
      DateTime now = DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day);
      DateTime selected = DateTime(
          selectedDateTime.year, selectedDateTime.month, selectedDateTime.day);
      if (selected.compareTo(now) == 0) {
        _date = "Today";
      } else {
        _date = DateFormat('MMM. dd, yyyy').format(selected);
      }
      _time = DateFormat("h:mma").format(selectedDateTime);
    });
  }
}

class Vehicle extends StatefulWidget {
  const Vehicle({Key? key}) : super(key: key);

  @override
  State<Vehicle> createState() => _VehicleState();
}

class _VehicleState extends State<Vehicle> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        const Text(
          "Vehicle",
          style: TextStyle(
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(
          width: double.infinity,
          child: Card(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(12),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Text(
                        "Plate No.: ",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                          ),
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class Payment extends StatefulWidget {
  const Payment({Key? key}) : super(key: key);

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        const Text(
          "Payment",
          style: TextStyle(
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(
          width: double.infinity,
          child: Card(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(12),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        "assets/icons/gpay-logo.png",
                        width: 40,
                      ),
                      const SizedBox(width: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            "GOOGLE PAY",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
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
      ],
    );
  }
}
