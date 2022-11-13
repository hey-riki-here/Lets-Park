// ignore_for_file: unused_catch_clause, empty_catches, avoid_function_literals_in_foreach_calls

import 'dart:async';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lets_park/models/notification.dart';
import 'package:lets_park/models/parking.dart';
import 'package:lets_park/screens/popups/notice_dialog.dart';
import 'package:lets_park/screens/popups/parking_extended.dart';
import 'package:lets_park/services/parking_space_services.dart';
import 'package:lets_park/services/user_services.dart';
import 'package:lets_park/services/world_time_api.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

class ExtendParking extends StatefulWidget {
  final Parking parking;
  const ExtendParking({
    Key? key,
    required this.parking,
  }) : super(key: key);

  @override
  State<ExtendParking> createState() => _ExtendParkingState();
}

class _ExtendParkingState extends State<ExtendParking> {
  final GlobalKey<VehicleState> _vehicleState = GlobalKey();
  final GlobalKey<SetUpTimeState> _setupTimeState = GlobalKey();
  StreamSubscription? checkPayedStream;
  final Stream checkPayed =
      Stream.periodic(const Duration(milliseconds: 1000), (int count) {
    return count;
  });

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
        title: const Text("Extend Parking"),
      ),
      backgroundColor: Colors.grey.shade100,
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  SetUpTime(key: _setupTimeState, parking: widget.parking),
                  Vehicle(
                      key: _vehicleState,
                      plateNumber: widget.parking.getPlateNumber!),
                  //const PhotoPicker(),
                  const Payment(),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 80,
        ),
        child: ElevatedButton(
          onPressed: () async {
            bool isAvailable = await UserServices.extendParking(
              _setupTimeState.currentState!.getHour!,
              _setupTimeState.currentState!.getMinute!,
              widget.parking,
              context,
            );

            if (isAvailable) {
              if (!hasToPay(_setupTimeState.currentState!.getNewDuration)) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => WillPopScope(
                    onWillPop: () async => false,
                    child: const NoticeDialog(
                      imageLink: "assets/logo/lets-park-logo.png",
                      message: "Extending your parking session. Please wait.",
                      forLoading: true,
                    ),
                  ),
                );

                await UserServices.updateDepartureOnParkingSession(
                  widget.parking,
                  _setupTimeState
                      .currentState!.getDeparture!.millisecondsSinceEpoch,
                );

                await ParkingSpaceServices.updateDepartureOnParkingSession(
                  widget.parking,
                  _setupTimeState
                      .currentState!.getDeparture!.millisecondsSinceEpoch,
                );

                await UserServices.updateDurationOnParkingSession(
                  widget.parking,
                  _setupTimeState.currentState!.getNewDuration,
                );

                await ParkingSpaceServices.updateDurationOnParkingSession(
                  widget.parking,
                  _setupTimeState.currentState!.getNewDuration,
                );

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

                final userNotif = UserNotification(
                  "",
                  widget.parking.getParkingSpaceId!,
                  widget.parking.getParkingId!,
                  FirebaseAuth.instance.currentUser!.photoURL ??
                      "https://cdn4.iconfinder.com/data/icons/user-people-2/48/5-512.png",
                  FirebaseAuth.instance.currentUser!.displayName!,
                  "extend parking session on your space. Tap to view details.",
                  true,
                  false,
                  now.millisecondsSinceEpoch,
                  false,
                  false,
                  true,
                  _setupTimeState.currentState!.getDuration!,
                  getDateTime(widget.parking.getDeparture!),
                  widget.parking.getDuration!,
                  DateFormat('MMM. dd, yyyy h:mm a')
                      .format(_setupTimeState.currentState!.getDeparture!),
                  _setupTimeState.currentState!.getNewDuration,
                  _setupTimeState.currentState!.getParkingPrice,
                );

                await UserServices.notifyUser(
                  widget.parking.getParkingOwner!,
                  userNotif,
                );

                await UserServices.setPayedToFalse(
                    FirebaseAuth.instance.currentUser!.uid);

                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (context) => const ParkingExtended(),
                  ),
                );

                return;
              }

              int paymentDate = 0;
              await WorldTimeServices.getDateOnlyNow().then((date) {
                paymentDate = date.millisecondsSinceEpoch;
              });

              String paypalEmail =
                  await ParkingSpaceServices.getSpacePaypalEmail(
                widget.parking.getParkingSpaceId!,
              );
              await UserServices.setPaymentParams(
                FirebaseAuth.instance.currentUser!.uid,
                "$paypalEmail/${_setupTimeState.currentState!.getParkingPrice}",
              );

              await UserServices.addToPayExtend(
                paymentDate,
                widget.parking.getParkingId!,
                _setupTimeState
                    .currentState!.getDeparture!.millisecondsSinceEpoch,
                _setupTimeState.currentState!.getDuration!,
                _setupTimeState.currentState!.getParkingPrice,
                widget.parking.getAddress!,
              );

              String url =
                  "https://letsparkpayment.up.railway.app/api/${FirebaseAuth.instance.currentUser!.uid}";
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
                          message:
                              "Extending your parking session. Please wait.",
                          forLoading: true,
                        ),
                      ),
                    );

                    await UserServices.updateDepartureOnParkingSession(
                      widget.parking,
                      _setupTimeState
                          .currentState!.getDeparture!.millisecondsSinceEpoch,
                    );

                    await ParkingSpaceServices.updateDepartureOnParkingSession(
                      widget.parking,
                      _setupTimeState
                          .currentState!.getDeparture!.millisecondsSinceEpoch,
                    );

                    await UserServices.updateDurationOnParkingSession(
                      widget.parking,
                      _setupTimeState.currentState!.getNewDuration,
                    );

                    await ParkingSpaceServices.updateDurationOnParkingSession(
                      widget.parking,
                      _setupTimeState.currentState!.getNewDuration,
                    );

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

                    final userNotif = UserNotification(
                      "",
                      widget.parking.getParkingSpaceId!,
                      widget.parking.getParkingId!,
                      FirebaseAuth.instance.currentUser!.photoURL ??
                          "https://cdn4.iconfinder.com/data/icons/user-people-2/48/5-512.png",
                      FirebaseAuth.instance.currentUser!.displayName!,
                      "extend parking session on your space. Tap to view details.",
                      true,
                      false,
                      now.millisecondsSinceEpoch,
                      false,
                      false,
                      true,
                      _setupTimeState.currentState!.getDuration!,
                      getDateTime(widget.parking.getDeparture!),
                      widget.parking.getDuration!,
                      DateFormat('MMM. dd, yyyy h:mm a')
                          .format(_setupTimeState.currentState!.getDeparture!),
                      _setupTimeState.currentState!.getNewDuration,
                      _setupTimeState.currentState!.getParkingPrice,
                    );

                    await UserServices.notifyUser(
                      widget.parking.getParkingOwner!,
                      userNotif,
                    );

                    await UserServices.setPayedToFalse(
                        FirebaseAuth.instance.currentUser!.uid);

                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (context) => const ParkingExtended(),
                      ),
                    );
                  }
                });
              });
            } else {
              showDialog(
                context: context,
                builder: (context) {
                  return (const NoticeDialog(
                    imageLink: "assets/logo/lets-park-logo.png",
                    message:
                        "We're sorry, but the time alloted is not available. Please try different time.",
                  ));
                },
              );
            }
          },
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

  bool hasToPay(String duration) {
    List<String> elements = duration.split(" ");
    bool result = false;

    if (elements.length == 2) {
      if (elements[1].compareTo("minute") == 0 ||
          elements[1].compareTo("minutes") == 0) {
        result = false;
      } else {
        int hour = int.parse(elements[0]);

        if (hour > 8) {
          result = true;
        }
      }
    } else {
      int hour = int.parse(elements[0]);

      if (hour > 8) {
        result = true;
      }
    }

    return result;
  }

  String getDateTime(int date) {
    return DateFormat('MMM. dd, yyyy h:mm a')
        .format(DateTime.fromMillisecondsSinceEpoch(date));
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
            onPressed: () {
              checkPayedStream!.cancel();
              Navigator.pop(context);
            },
            child: const Text("Cancel Payment"),
          ),
        ],
      ),
    );
  }
}

class SetUpTime extends StatefulWidget {
  final Parking parking;
  const SetUpTime({Key? key, required this.parking}) : super(key: key);

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
  int originalHour = 0;
  int originalMinute = 0;
  String newParkingDuration = "";
  DateTime? sessionDeparture;
  DateTime? _selectedDepartureDateTime;
  String _departureDate = "Today";
  String? _departureTime;
  String _parkingDuration = "";
  int _selectedHour = 1;
  int _selectedMinute = 0;
  double price = 10;

  @override
  void initState() {
    _selectedHour = 1;
    _selectedMinute = 0;
    List<String> elements = widget.parking.getDuration!.trim().split(" ");

    if (elements.length == 2) {
      if (elements[1].compareTo("minute") == 0 ||
          elements[1].compareTo("minutes") == 0) {
        originalMinute = int.parse(elements[0]);
      } else {
        originalHour = int.parse(elements[0]);
      }
    } else {
      originalMinute = int.parse(widget.parking.getDuration!.split(" ")[3]);
      originalHour = int.parse(widget.parking.getDuration!.split(" ")[0]);
    }

    sessionDeparture =
        DateTime.fromMillisecondsSinceEpoch(widget.parking.getDeparture!);

    _selectedDepartureDateTime =
        sessionDeparture!.add(const Duration(hours: 1));
    _departureTime = DateFormat("h:mm a").format(_selectedDepartureDateTime!);

    setDuration();
    getPrice();
    getNewParkingDuration();
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
              const Expanded(
                child: Text(
                    "If the extension time together with the current duration does not exceed the first 8 hours, there will be no charges applied."),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "Extend time",
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
                  const Text(
                    "Please select the duration",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
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
                                      "Select extend duration (HH:MM)",
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
                                            minValue: 1,
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
                                        getNewParkingDuration();
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

  void getNewParkingDuration() {
    int minute = originalMinute + _selectedMinute;
    int hour = originalHour + _selectedHour;
    if (hour != 0 || minute != 0) {
      if (hour == 0 && minute == 1) {
        newParkingDuration = "$minute minute";
      } else if (hour == 1 && minute == 0) {
        newParkingDuration = "$hour hour";
      } else if (hour == 0 && minute > 1) {
        newParkingDuration = "$minute minutes";
      } else if (hour > 1 && minute == 0) {
        newParkingDuration = "$hour hours";
      } else if (hour > 1 && minute > 1) {
        newParkingDuration = "$hour hours and $minute minutes";
      } else if (hour == 1 && minute == 1) {
        newParkingDuration = "$hour hour and $minute minute";
      } else if (hour > 1 && minute == 1) {
        newParkingDuration = "$hour hours and $minute minute";
      } else if (hour == 1 && minute > 1) {
        newParkingDuration = "$hour hour and $minute minutes";
      }
    }
  }

  void getDepartureTime() {
    setState(() {
      if (_selectedHour != 0 || _selectedMinute != 0) {
        _selectedDepartureDateTime = sessionDeparture!.add(
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
    int hour = 0;
    List<String> elements = widget.parking.getDuration!.trim().split(" ");

    if (elements.length == 2) {
      if (elements[1].compareTo("hour") == 0 ||
          elements[1].compareTo("hours") == 0) {
        hour = int.parse(elements[0]);
      }
    } else {
      hour = int.parse(elements[0]);
    }

    setState(() {
      hour += _selectedHour;
      if (hour > 8) {
        price = 10;
        price *= hour - 8;
      } else {
        price = 0.0;
      }
    });
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

  DateTime? get getDeparture => _selectedDepartureDateTime;

  String? get getDuration => _parkingDuration;

  String get getNewDuration => newParkingDuration;

  int? get getHour => _selectedHour;

  int? get getMinute => _selectedMinute;

  double get getParkingPrice => price;
}

class Vehicle extends StatefulWidget {
  final String plateNumber;
  const Vehicle({Key? key, required this.plateNumber}) : super(key: key);

  @override
  State<Vehicle> createState() => VehicleState();
}

class VehicleState extends State<Vehicle> {
  final plateNumberController = TextEditingController();
  List<String> plateNumbers = [];
  String selectedCar = "Select plate number";

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
            elevation: 2,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(12),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                widget.plateNumber,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                ),
              ),
            ),
          ),
        ),
      ],
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
