import 'package:flutter/material.dart';
import 'package:lets_park/models/parking_space.dart';
import 'package:lets_park/screens/drawer_screens/register_screens/info_and_features.dart';
import 'package:lets_park/screens/popups/notice_dialog.dart';
import 'package:lets_park/services/parking_space_services.dart';

class ReservabilityModifier extends StatefulWidget {
  final ParkingSpace space;
  const ReservabilityModifier({
    Key? key,
    required this.space,
  }) : super(key: key);

  @override
  State<ReservabilityModifier> createState() => _ReservabilityModifierState();
}

class _ReservabilityModifierState extends State<ReservabilityModifier> {
  final GlobalKey<ReservabilityState> _reservabilityState = GlobalKey();
  late Reservability reservability;

  @override
  void initState() {
    reservability = Reservability(
      key: _reservabilityState,
      reservability: widget.space.getType!,
      dailyOrMonthly: widget.space.getDailyOrMonthly!,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text("Edit space reservability"),
        centerTitle: true,
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
                  "Update parking space reservability",
                  style: TextStyle(
                    fontSize: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            reservability,
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.save,
        ),
        onPressed: () async {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => WillPopScope(
              onWillPop: () async => false,
              child: const NoticeDialog(
                imageLink: "assets/logo/lets-park-logo.png",
                message: "We are now updating the parking space. Please wait.",
                forLoading: true,
              ),
            ),
          );

          widget.space.setType =
              _reservabilityState.currentState!.getSelectedReservability!;

          widget.space.setDailyOrMonthly =
              _reservabilityState.currentState!.getSelectedDailyOrMonthly!;

          await Future.delayed(const Duration(seconds: 1));

          ParkingSpaceServices.updateSpaceType(
            widget.space.getSpaceId!,
            _reservabilityState.currentState!.getSelectedReservability!,
          );

          ParkingSpaceServices.updateSpaceDailyOrMonthly(
            widget.space.getSpaceId!,
            _reservabilityState.currentState!.getSelectedDailyOrMonthly!,
          );

          Navigator.pop(context);
          Navigator.pop(context, widget.space);
        },
      ),
    );
  }
}
