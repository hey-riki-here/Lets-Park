import 'package:flutter/material.dart';
import 'package:lets_park/shared/shared_widgets.dart';

class Earnings extends StatefulWidget {
  const Earnings({Key? key}) : super(key: key);

  @override
  State<Earnings> createState() => _EarningsState();
}

class _EarningsState extends State<Earnings> {
  final _sharedWidgets = SharedWidget();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _sharedWidgets.manageSpaceAppBar("Earnings"),
      backgroundColor: Colors.grey.shade300,
      body: SingleChildScrollView(
        child: Column(
          children: const [],
        ),
      ),
    );
  }
}


