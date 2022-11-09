// ignore_for_file: unused_catch_clause, empty_catches, avoid_function_literals_in_foreach_calls

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lets_park/models/notification.dart';
import 'package:lets_park/models/parking.dart';
import 'package:lets_park/models/parking_space.dart';
import 'package:lets_park/screens/drawer_screens/profile_page/registered_cars.dart';
import 'package:lets_park/screens/popups/notice_dialog.dart';
import 'package:lets_park/screens/popups/successful_booking.dart';
import 'package:lets_park/services/parking_space_services.dart';
import 'package:lets_park/services/user_services.dart';
import 'package:lets_park/services/world_time_api.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:lets_park/globals/globals.dart' as globals;
import 'package:url_launcher/url_launcher.dart' as launcher;

class NonReservableCheckout extends StatefulWidget {
  final ParkingSpace parkingSpace;
  const NonReservableCheckout({Key? key, required this.parkingSpace})
      : super(key: key);

  @override
  State<NonReservableCheckout> createState() => _NonReservableCheckoutState();
}

class _NonReservableCheckoutState extends State<NonReservableCheckout> {
  final GlobalKey<VehicleState> _vehicleState = GlobalKey();
  final GlobalKey<SetUpTimeState> _setupTimeState = GlobalKey();
  StreamSubscription? checkPayedStream;
  final Stream checkPayed =
      Stream.periodic(const Duration(milliseconds: 1000), (int count) {
    return count;
  });
  bool canPay = true;

  @override
  void dispose() {
    if (checkPayedStream != null) {
      checkPayedStream!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rent details"),
      ),
      backgroundColor: Colors.grey.shade100,
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: ParkingSpaceServices.getParkingSessionsDocs(
              widget.parkingSpace.getSpaceId!),
          builder: (context, snapshot) {
            return Padding(
              padding: const EdgeInsets.all(12),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        SetUpTime(
                          key: _setupTimeState,
                          type: widget.parkingSpace.getType!,
                        ),
                        Vehicle(key: _vehicleState),
                        //const PhotoPicker(),
                        const Payment(),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 80,
        ),
        child: ElevatedButton(
          onPressed: canPay
              ? () async {
                  setState(() {
                    canPay = false;
                  });

                  if (_vehicleState.currentState!.getPlateNumber!
                          .compareTo("Select plate number") ==
                      0) {
                    showAlertDialog("Please provide car's plate number.");
                    return;
                  }

                  int qty = globals.userData.getUserParkings!.length + 1;
                  String parkingId = "PARKSESS" +
                      DateTime.now()
                          .millisecondsSinceEpoch
                          .toString()
                          .toString() +
                      "$qty";

                  int paymentDate = 0;
                  await WorldTimeServices.getDateOnlyNow().then((date) {
                    paymentDate = date.millisecondsSinceEpoch;
                  });

                  Parking newParking = Parking(
                    widget.parkingSpace.getSpaceId,
                    widget.parkingSpace.getType,
                    widget.parkingSpace.getDailyOrMonthly,
                    parkingId,
                    widget.parkingSpace.getImageUrl,
                    widget.parkingSpace.getOwnerId,
                    widget.parkingSpace.getOwnerName,
                    FirebaseAuth.instance.currentUser!.displayName,
                    FirebaseAuth.instance.currentUser!.uid,
                    FirebaseAuth.instance.currentUser!.photoURL,
                    FirebaseAuth.instance.currentUser!.phoneNumber!,
                    widget.parkingSpace.getRating!.toInt(),
                    widget.parkingSpace.getAddress,
                    [
                      widget.parkingSpace.getLatLng!.latitude,
                      widget.parkingSpace.getLatLng!.longitude
                    ],
                    _vehicleState.currentState!.getPlateNumber,
                    _setupTimeState
                        .currentState!.getArrival!.millisecondsSinceEpoch,
                    _setupTimeState
                        .currentState!.getDeparture!.millisecondsSinceEpoch,
                    paymentDate,
                    _setupTimeState.currentState!.getDuration,
                    _setupTimeState.currentState!.getParkingPrice,
                    false,
                    true,
                    false,
                    false,
                  );

                  await UserServices.setPaymentParams(
                    FirebaseAuth.instance.currentUser!.uid,
                    "${widget.parkingSpace.getPaypalEmail}/${_setupTimeState.currentState!.getParkingPrice}",
                  );

                  await UserServices.addToPay(
                    paymentDate,
                    parkingId,
                    _setupTimeState
                        .currentState!.getArrival!.millisecondsSinceEpoch,
                    _setupTimeState
                        .currentState!.getDeparture!.millisecondsSinceEpoch,
                    _setupTimeState.currentState!.getDuration!,
                    _setupTimeState.currentState!.getParkingPrice,
                    widget.parkingSpace.getAddress!,
                  );

                  String url =
                      "https://sample-paypal-payment-sandbox.herokuapp.com/${FirebaseAuth.instance.currentUser!.uid}";
                  if (await launcher.canLaunchUrl(Uri.parse(url))) {
                    await launcher.launchUrl(
                      Uri.parse(url),
                      mode: launcher.LaunchMode.externalApplication,
                    );
                  }
                  showAlertDialogWithLoading("Now paying...");

                  checkPayedStream = checkPayed.listen((event) {
                    UserServices.isPayed(FirebaseAuth.instance.currentUser!.uid)
                        .then((payed) async {
                      if (payed) {
                        checkPayedStream!.cancel();

                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => WillPopScope(
                            onWillPop: () async => false,
                            child: const NoticeDialog(
                              imageLink: "assets/logo/lets-park-logo.png",
                              message: "Finalizing your booking. Please wait.",
                              forLoading: true,
                            ),
                          ),
                        );
                        var request = http.Request(
                          'POST',
                          Uri.parse(
                            "https://sample-paypal-payment-sandbox.herokuapp.com/write/to/database",
                          ),
                        )..headers.addAll({
                            HttpHeaders.contentTypeHeader: "application/json",
                          });

                        DateTime now = DateTime(0, 0, 0, 0, 0);
                        await WorldTimeServices.getDateTimeNow().then((time) {
                          now = DateTime(
                            time.year,
                            time.month,
                            time.day,
                            time.hour,
                            time.minute,
                          );
                        });

                        // int notifLength =
                        //     await UserServices.getUserNotificationLength(
                        //   FirebaseAuth.instance.currentUser!.uid,
                        // );

                        final userNotif = UserNotification(
                          "",
                          widget.parkingSpace.getSpaceId!,
                          newParking.getParkingId!,
                          FirebaseAuth.instance.currentUser!.photoURL ??
                              "https://cdn4.iconfinder.com/data/icons/user-people-2/48/5-512.png",
                          FirebaseAuth.instance.currentUser!.displayName!,
                          "just booked on your parking space. Tap to view details.",
                          true,
                          false,
                          now.millisecondsSinceEpoch,
                          false,
                          false,
                          false,
                          "",
                          "",
                          "",
                          "",
                          "",
                          0.0,
                        );

                        var params = {
                          "parking": newParking.toJson(),
                          "notification": {
                            "notificationId": "",
                            "userId": widget.parkingSpace.getOwnerId!,
                            "userNotification": userNotif.toJson(),
                          },
                        };

                        request.body = jsonEncode(params);
                        await request.send();

                        UserServices.setPayedToFalse(
                            FirebaseAuth.instance.currentUser!.uid);
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: ((context) => SuccessfulBooking(
                                  owner: widget.parkingSpace.getOwnerName!,
                                  parkee: FirebaseAuth
                                      .instance.currentUser!.displayName!,
                                  transactioDate: DateFormat('MMMM dd, yyyy')
                                      .format(DateTime.now()),
                                  arrivalDate: DateFormat(
                                          'MMMM dd, yyyy - h:mm a')
                                      .format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                              _setupTimeState
                                                  .currentState!
                                                  .getArrival!
                                                  .millisecondsSinceEpoch)),
                                  departureDate: DateFormat(
                                          'MMMM dd, yyyy - h:mm a')
                                      .format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                              _setupTimeState
                                                  .currentState!
                                                  .getDeparture!
                                                  .millisecondsSinceEpoch)),
                                  duration: _setupTimeState
                                      .currentState!.getDuration!,
                                  parkingFee: _setupTimeState
                                      .currentState!.getParkingPrice,
                                  spaceAddress: widget.parkingSpace.getAddress!,
                                  sendTo:
                                      FirebaseAuth.instance.currentUser!.email!,
                                  replyTo: "chuarex55@gmail.com",
                                )),
                          ),
                        );
                      }
                    });
                  });
                }
              : null,
          child: const Text(
            "Pay now",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
          style: ElevatedButton.styleFrom(
            primary: Colors.lightBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
        ),
      ),
    );
  }

  void showAlertDialog(String message) async {
    await showDialog(
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
    ).then((value) {
      setState(() {
        canPay = true;
      });
    });
  }

  void showAlertDialogWithLoading(String message) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => AlertDialog(
        title: Center(
          child: Image.asset(
            "assets/logo/app_icon.png",
            scale: 20,
          ),
        ),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(message),
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              checkPayedStream!.cancel();
              await UserServices.setPayedToFalse(
                FirebaseAuth.instance.currentUser!.uid,
              );
              await UserServices.deletePaymentDoc();
              setState(() {
                canPay = true;
              });
              Navigator.pop(context);
              Navigator.pop(context, "non-null-callback");
            },
            child: const Text("Cancel Payment"),
          ),
        ],
      ),
    ).then((value) {
      setState(() {
        canPay = true;
      });
    });
  }
}

class SetUpTime extends StatefulWidget {
  final String type;
  const SetUpTime({
    Key? key,
    required this.type,
  }) : super(key: key);

  @override
  State<SetUpTime> createState() => SetUpTimeState();
}

class SetUpTimeState extends State<SetUpTime> {
  final labelStyle = const TextStyle(
    fontSize: 16,
  );

  final timeStampStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  final DateTime? _selectedDate = DateTime.now();
  DateTime? _selectedDateTime;
  DateTime? _selectedArrivalDateTime;
  DateTime? _selectedDepartureDateTime;
  String _arrivalDate = "Today";
  String? _arrivalTime = DateFormat("h:mm a").format(DateTime.now());
  String _departureDate = "Today";
  String? _departureTime;
  String _parkingDuration = "";
  int _selectedHour = 0;
  int _selectedMinute = 15;
  double price = 50;
  bool isTimeBehind = true;

  @override
  void initState() {
    _selectedArrivalDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedDate!.hour,
      _selectedDate!.minute,
    );

    _selectedDateTime = _selectedArrivalDateTime;

    _selectedDepartureDateTime =
        _selectedArrivalDateTime!.add(const Duration(minutes: 15));
    _departureTime = DateFormat("h:mm a").format(_selectedDepartureDateTime!);

    setDuration();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
              Expanded(
                child: Text(
                  widget.type.compareTo("Reservable") == 0
                      ? "You are about to rent a reservable space. Please be mindful on choosing the time of arrival and parking duration."
                      : "You are about to rent a non-reservable space. By that, you cannot specify your time of arrival.",
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
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
                children: <Widget>[
                  widget.type.compareTo("Reservable") == 0
                      ? const Text(
                          "Please select the time of arrival and parking duration",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        )
                      : const Text(
                          "Please input parking duration",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Start:", style: labelStyle),
                      Row(
                        children: [
                          Text(
                            "$_arrivalDate at $_arrivalTime",
                            style: timeStampStyle,
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Duration:", style: labelStyle),
                      Card(
                        elevation: 2,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(12),
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            showDialog<int>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Center(
                                    child: Text(
                                      "Select parking duration (HH:MM)",
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.blue.shade900,
                                      ),
                                    ),
                                  ),
                                  content: StatefulBuilder(
                                    builder: (context, sbSetState) {
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          NumberPicker(
                                            textStyle: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                            value: _selectedHour,
                                            minValue: 0,
                                            maxValue: 23,
                                            onChanged: (value) {
                                              setState(
                                                () {
                                                  _selectedHour = value;
                                                },
                                              );
                                              sbSetState(
                                                () {
                                                  _selectedHour = value;
                                                },
                                              );
                                            },
                                          ),
                                          NumberPicker(
                                            textStyle: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                            value: _selectedMinute,
                                            minValue: 0,
                                            maxValue: 59,
                                            onChanged: (value) {
                                              setState(
                                                () => _selectedMinute = value,
                                              );
                                              sbSetState(
                                                () => _selectedMinute = value,
                                              );
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setDuration();
                                        getDepartureTime();
                                        getPrice();
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Confirm"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(7.0),
                            child: Row(
                              children: [
                                Text(
                                  _parkingDuration,
                                  style: timeStampStyle,
                                ),
                                const SizedBox(width: 10),
                                const Icon(
                                  FontAwesomeIcons.clock,
                                  color: Colors.blue,
                                  size: 15,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Departure:", style: labelStyle),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Text(
                              "$_departureDate at $_departureTime",
                              style: timeStampStyle,
                            ),
                            const SizedBox(width: 7),
                            const Icon(
                              FontAwesomeIcons.carSide,
                              color: Colors.blue,
                              size: 15,
                            ),
                          ],
                        ),
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
                          Text("$price", style: timeStampStyle),
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

  // Future<dynamic> showDateTimePicker(BuildContext context) {
  //   return showDialog(
  //     barrierDismissible: false,
  //     context: context,
  //     builder: (context) => Dialog(
  //       child: SizedBox(
  //         height: 335,
  //         child: Padding(
  //           padding: const EdgeInsets.all(8.0),
  //           child: Column(
  //             children: [
  //               Text(
  //                 "Please select valid time and date of arrival",
  //                 style: TextStyle(
  //                   fontSize: 16,
  //                   color: Colors.blue.shade900,
  //                 ),
  //               ),
  //               const SizedBox(height: 20),
  //               TimePickerSpinner(
  //                 time: _selectedArrivalDateTime,
  //                 is24HourMode: false,
  //                 normalTextStyle: const TextStyle(
  //                   fontSize: 18,
  //                   color: Colors.grey,
  //                 ),
  //                 highlightedTextStyle: const TextStyle(
  //                   fontSize: 23,
  //                   color: Colors.black,
  //                 ),
  //                 spacing: 40,
  //                 itemHeight: 25,
  //                 isForce2Digits: true,
  //                 onTimeChange: (time) {
  //                   _selectedTime = time;
  //                 },
  //               ),
  //               DatePickerWidget(
  //                 initialDate: _selectedArrivalDateTime,
  //                 looping: false,
  //                 firstDate: DateTime.now(),
  //                 dateFormat: "MMM/dd/yyyy",
  //                 onChange: (DateTime newDate, _) {
  //                   _selectedDate = newDate;
  //                 },
  //                 pickerTheme: const DateTimePickerTheme(
  //                   itemTextStyle: TextStyle(
  //                     color: Colors.black,
  //                     fontSize: 19,
  //                   ),
  //                 ),
  //               ),
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.end,
  //                 children: [
  //                   TextButton(
  //                     onPressed: () => Navigator.pop(context),
  //                     child: const Text("Cancel"),
  //                   ),
  //                   ElevatedButton(
  //                     onPressed: () {
  //                       try {
  //                         _selectedDateTime = DateTime(
  //                           _selectedDate!.year,
  //                           _selectedDate!.month,
  //                           _selectedDate!.day,
  //                           _selectedTime!.hour,
  //                           _selectedTime!.minute,
  //                         );
  //                         Navigator.pop(context);
  //                         getArrivalDateTime(_selectedDateTime!);
  //                       } on Exception catch (e) {
  //                         Navigator.pop(context);
  //                         getArrivalDateTime(DateTime.now());
  //                       } finally {
  //                         getPrice();
  //                       }
  //                     },
  //                     child: const Text("Confirm"),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  void setDuration() {
    if (_selectedHour != 0 || _selectedMinute != 0) {
      setState(() {
        if (_selectedHour == 0 && _selectedMinute == 1) {
          _parkingDuration = "$_selectedMinute minute";
        } else if (_selectedHour == 1 && _selectedMinute == 0) {
          _parkingDuration = "$_selectedHour hour";
        } else if (_selectedHour == 0 && _selectedMinute > 1) {
          _parkingDuration = "$_selectedMinute minutes";
        } else if (_selectedHour > 1 && _selectedMinute == 0) {
          _parkingDuration = "$_selectedHour hours";
        } else if (_selectedHour > 1 && _selectedMinute > 1) {
          _parkingDuration =
              "$_selectedHour hours and $_selectedMinute minutes";
        } else if (_selectedHour == 1 && _selectedMinute == 1) {
          _parkingDuration = "$_selectedHour hour and $_selectedMinute minute";
        } else if (_selectedHour > 1 && _selectedMinute == 1) {
          _parkingDuration = "$_selectedHour hours and $_selectedMinute minute";
        } else if (_selectedHour == 1 && _selectedMinute > 1) {
          _parkingDuration = "$_selectedHour hour and $_selectedMinute minutes";
        }
      });
    }
  }

  void getArrivalDateTime(DateTime selectedDateTime) {
    setState(() {
      DateTime now = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );
      DateTime selected = DateTime(
        selectedDateTime.year,
        selectedDateTime.month,
        selectedDateTime.day,
      );

      if (isTimeValid()) {
        if (selected.compareTo(now) == 0) {
          _arrivalDate = "Today";
        } else {
          _arrivalDate = DateFormat('MMM. dd, yyyy').format(selected);
        }
        _arrivalTime = DateFormat("h:mm a").format(selectedDateTime);

        getDepartureTime();
      }
    });
  }

  void getDepartureTime() {
    setState(() {
      if (_selectedHour != 0 || _selectedMinute != 0) {
        _selectedDepartureDateTime = _selectedArrivalDateTime!.add(
          Duration(
            hours: _selectedHour,
            minutes: _selectedMinute,
          ),
        );
      }

      DateTime now = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );

      DateTime departure = DateTime(
        _selectedDepartureDateTime!.year,
        _selectedDepartureDateTime!.month,
        _selectedDepartureDateTime!.day,
      );

      if (departure.compareTo(now) == 0) {
        _departureDate = "Today";
      } else {
        _departureDate = DateFormat('MMM. dd, yyyy').format(departure);
      }
      _departureTime = DateFormat("h:mm a").format(_selectedDepartureDateTime!);
    });
  }

  void getPrice() {
    price = 50;
    if (_selectedHour <= 8) {
      price = 50;
    } else {
      int exceededHours = _selectedHour - 8;
      price += exceededHours * 10;
    }
  }

  bool isTimeValid() {
    bool result = false;
    DateTime now = getDateTimeNow();
    if (_selectedDateTime!.compareTo(now) == -1) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: const Text("Arrival can't be a past time."),
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
      result = false;
    } else {
      _selectedArrivalDateTime = DateTime(
        _selectedDateTime!.year,
        _selectedDateTime!.month,
        _selectedDateTime!.day,
        _selectedDateTime!.hour,
        _selectedDateTime!.minute,
      );
      result = true;
    }
    _selectedDateTime = _selectedArrivalDateTime;
    return result;
  }

  DateTime getDateTimeNow() {
    return DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      DateTime.now().hour,
      DateTime.now().minute,
    );
  }

  DateTime? get getArrival => _selectedArrivalDateTime;

  DateTime? get getDeparture => _selectedDepartureDateTime;

  String? get getDuration => _parkingDuration;

  double get getParkingPrice => price;
}

class Vehicle extends StatefulWidget {
  const Vehicle({Key? key}) : super(key: key);

  @override
  State<Vehicle> createState() => VehicleState();
}

class VehicleState extends State<Vehicle> {
  final plateNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<String> plateNumbers = [];
  String selectedCar = "Select plate number";

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection("user-data")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("cars")
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          plateNumbers.clear();
          plateNumbers.add("Select plate number");
          snapshot.data!.docs.forEach((car) {
            plateNumbers.add(car.data()["plateNumber"]);
          });
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
                  elevation: 2,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(12),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(width: 10),
                          plateNumbers.length == 1
                              ? Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const RegisteredCars(),
                                            ),
                                          ).then((value) {
                                            setState(() {});
                                          });
                                        },
                                        icon: const Icon(FontAwesomeIcons.car),
                                        label: const Text("Add car"),
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedCar,
                                      icon: const Icon(
                                        Icons.arrow_drop_down_rounded,
                                        size: 32,
                                      ),
                                      elevation: 16,
                                      isExpanded: true,
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedCar = newValue!;
                                        });
                                      },
                                      items: plateNumbers
                                          .map(dropdownItem)
                                          .toList(),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        } else {
          return const Padding(
            padding: EdgeInsets.all(12.0),
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  DropdownMenuItem<String> dropdownItem(String item) {
    return DropdownMenuItem(
      child: Text(
        item,
        style: TextStyle(
          color: item.compareTo("Select plate number") == 0
              ? Colors.grey
              : Colors.black,
        ),
      ),
      value: item,
    );
  }

  String? get getPlateNumber => selectedCar;
}

class PhotoPicker extends StatefulWidget {
  const PhotoPicker({Key? key}) : super(key: key);

  @override
  State<PhotoPicker> createState() => PhotoPickerState();
}

class PhotoPickerState extends State<PhotoPicker> {
  File? image;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        const Text(
          "Senior Citizen Card (Optional)",
          style: TextStyle(
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 5),
        Card(
          elevation: 2,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(12),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Please provide an image of your senior citizen card",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black45,
                  ),
                ),
                const SizedBox(height: 15),
                Center(
                  child: DottedBorder(
                    color: Colors.blue,
                    child: image != null ? displayImage() : placeHolder(),
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(12),
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Note: The space owner will be the one who will verify your senior citizen card.",
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future chooseImage() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (image == null) return;
      final imageTemp = File(image.path);

      setState(() => this.image = imageTemp);
    } on Exception catch (e) {}
  }

  Widget displayImage() => Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(28.0),
            child: SizedBox(
              child: Image.file(
                image!,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  child: const Icon(Icons.close),
                  onTap: () {
                    setState(() {
                      image = null;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      );

  Widget placeHolder() => InkWell(
        onTap: () {
          chooseImage();
        },
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: Container(
          width: 300,
          height: 150,
          padding: const EdgeInsets.all(35),
          child: Column(
            children: const [
              Icon(
                Icons.cloud_upload,
                size: 50,
                color: Colors.grey,
              ),
              SizedBox(height: 10),
              Text("Browse for an image")
            ],
          ),
        ),
      );

  File? get getImage => image;
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
            elevation: 2,
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
                        "assets/icons/paypal_logo.png",
                        width: 30,
                      ),
                      const SizedBox(width: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            "Paypal",
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
