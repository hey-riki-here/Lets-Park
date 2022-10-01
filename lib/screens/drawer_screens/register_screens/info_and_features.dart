import 'package:flutter/material.dart';
import 'package:lets_park/shared/shared_widgets.dart';

class InfoAndFeatures extends StatefulWidget {
  const InfoAndFeatures({Key? key}) : super(key: key);

  @override
  State<InfoAndFeatures> createState() => InfoAndFeaturesState();
}

class InfoAndFeaturesState extends State<InfoAndFeatures> {
  final SharedWidget _sharedWidget = SharedWidget();
  final GlobalKey<InformationState> _informationState = GlobalKey();
  final GlobalKey<CapacityState> _capacityState = GlobalKey();
  final GlobalKey<ReservabilityState> _reservabilityState = GlobalKey();
  final GlobalKey<FeaturesState> _featuresState = GlobalKey();
  final GlobalKey<PaypalState> _paypalState = GlobalKey();
  final featuresItems = <FeaturesItem>[
    FeaturesItem(title: "CCTV"),
    FeaturesItem(title: "Covered Parking"),
  ];
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "Parking capacity and pricing should follow the city's ordinance. See Terms and Conditions and Parking Guidelines to learn more.",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _sharedWidget.stepHeader("Information"),
        const SizedBox(height: 10),
        //Capacity(key: _capacityState),
        // const SizedBox(height: 20),
        Information(key: _informationState),
        const SizedBox(height: 20),
        Reservability(
          key: _reservabilityState,
          reservability: "Reservable",
          dailyOrMonthly: "Daily",
        ),
        const SizedBox(height: 20),
        _sharedWidget.stepHeader("Features"),
        Features(key: _featuresState, features: featuresItems),
        _sharedWidget.stepHeader("Paypal Account"),
        const SizedBox(height: 10),
        Paypal(key: _paypalState),
        const SizedBox(height: 30),
      ],
    );
  }

  //int get getCapacity => _capacityState.currentState!.getCapacity;

  GlobalKey<FormState> get getFormKey =>
      _informationState.currentState!._infoKey;

  GlobalKey<FormState> get getPaypalFormKey =>
      _paypalState.currentState!._paypalKey;

  String get getInfo => _informationState.currentState!.getInfo;

  String get getRules => _informationState.currentState!.getRules;

  // double get getVerticalClearance =>
  //     _informationState.currentState!.getVerticalClearance;

  String? get getReservability =>
      _reservabilityState.currentState!.getSelectedReservability;

  String? get getDailyOrMonthly =>
      _reservabilityState.currentState!.getSelectedDailyOrMonthly;

  List<String> get getSelectedFeatures =>
      _featuresState.currentState!.getSelectedFeatures;

  String get getPaypalEmail => _paypalState.currentState!.getPaypaEmail;
}

class Capacity extends StatefulWidget {
  const Capacity({Key? key}) : super(key: key);

  @override
  State<Capacity> createState() => CapacityState();
}

class CapacityState extends State<Capacity> {
  int _capacity = 1;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Capacity",
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: Colors.black54,
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(12),
                ),
              ),
              height: 50,
              width: 50,
              child: Center(
                child: Text(
                  "$_capacity",
                  style: const TextStyle(
                    fontSize: 23,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _increaseCapacity("-");
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade400,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
                    height: 30,
                    width: 30,
                    child: const Center(
                      child: Text(
                        "-",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _increaseCapacity("+");
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade400,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
                    height: 30,
                    width: 30,
                    child: const Center(
                      child: Text(
                        "+",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  void _increaseCapacity(String op) {
    if (op.compareTo("+") == 0) {
      if (_capacity >= 1) _capacity++;
    } else {
      if (_capacity > 1) _capacity--;
    }
  }

  int get getCapacity => _capacity;
}

class Information extends StatefulWidget {
  const Information({Key? key}) : super(key: key);

  @override
  State<Information> createState() => InformationState();
}

class InformationState extends State<Information> {
  final _infoKey = GlobalKey<FormState>();
  final _infoController = TextEditingController();
  final _rulesController = TextEditingController();
  // final _vertClearanceController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _infoKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Information about your parking area",
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          _buildInfoField(),
          const SizedBox(height: 10),
          const Text(
            "Rules",
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          _buildRulesField(),
          const SizedBox(height: 10),
          // const Text(
          //   "Vertical clerance (in meters)",
          //   style: TextStyle(
          //     fontSize: 18,
          //   ),
          // ),
          // const SizedBox(height: 10),
          //_buildVerticalClearanceField(),
        ],
      ),
    );
  }

  TextFormField _buildRulesField() {
    return TextFormField(
      controller: _rulesController,
      maxLines: 5,
      textInputAction: TextInputAction.done,
      decoration: const InputDecoration(
        hintText:
            "Provide your parking space rules here to make the driver aware on your parking rules.",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Field is required.";
        }
        return null;
      },
    );
  }

  // SizedBox _buildVerticalClearanceField() {
  //   return SizedBox(
  //     width: 100,
  //     child: TextFormField(
  //       controller: _vertClearanceController,
  //       style: const TextStyle(
  //         fontSize: 16,
  //       ),
  //       keyboardType: TextInputType.number,
  //       textInputAction: TextInputAction.done,
  //       decoration: const InputDecoration(
  //         border: OutlineInputBorder(
  //           borderRadius: BorderRadius.all(Radius.circular(12)),
  //         ),
  //       ),
  //       validator: (value) {
  //         if (value == null || value.isEmpty) {
  //           return "Field is required.";
  //         }
  //         return null;
  //       },
  //     ),
  //   );
  // }

  TextFormField _buildInfoField() {
    return TextFormField(
      controller: _infoController,
      maxLines: 5,
      textInputAction: TextInputAction.done,
      decoration: const InputDecoration(
        hintText:
            "You can provide some selling points here or information to further help driver to find your space.",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Field is required.";
        }
        return null;
      },
    );
  }

  GlobalKey<FormState> get getFormKey => _infoKey;

  String get getInfo => _infoController.text.trim();

  String get getRules => _rulesController.text.trim();

  // double get getVerticalClearance =>
  //     double.parse(_vertClearanceController.text.trim());
}

class Reservability extends StatefulWidget {
  final String reservability;
  final String dailyOrMonthly;
  const Reservability({
    Key? key,
    required this.reservability,
    required this.dailyOrMonthly,
  }) : super(key: key);

  @override
  State<Reservability> createState() => ReservabilityState();
}

class ReservabilityState extends State<Reservability> {
  String? _selectedReservability = "";
  String? _selectedDailyOrMonthly = "";
  bool enableRadios = true;

  @override
  void initState() {
    _selectedReservability = widget.reservability;
    _selectedDailyOrMonthly = widget.dailyOrMonthly;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Parking type",
          style: TextStyle(
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 10),
        _buildDailyOrMonthlyRadioButton(
          "Daily",
          "Parking in a daily basis",
          Colors.blue[400]!,
        ),
        const SizedBox(height: 10),
        _buildDailyOrMonthlyRadioButton(
          "Monthly",
          "Parking in a monthly basis",
          Colors.orange[400]!,
        ),
        const SizedBox(height: 10),
        const Text(
          "Reservability",
          style: TextStyle(
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 10),
        Opacity(
          opacity: _selectedDailyOrMonthly!.compareTo("Daily") == 0 ? 1 : 0.5,
          child: Column(
            children: [
              _buildReservabilityRadioButton(
                "Reservable",
                "Driver can book at this parking space in advance",
                Colors.blue[400]!,
              ),
              const SizedBox(height: 10),
              _buildReservabilityRadioButton(
                "Non-reservable",
                "Immediate parking. No reservation.",
                Colors.green[400]!,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDailyOrMonthlyRadioButton(
      String option, String label, Color color) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Colors.black26,
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 70,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(7),
                bottomLeft: Radius.circular(7),
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
                        option,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Radio(
                    value: option,
                    groupValue: _selectedDailyOrMonthly,
                    autofocus: true,
                    onChanged: (String? value) {
                      setState(() {
                        if (value!.compareTo("Monthly") == 0) {
                          _selectedReservability = "Reservable";
                        }
                        _selectedDailyOrMonthly = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservabilityRadioButton(
      String option, String label, Color color) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Colors.black26,
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 70,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(7),
                bottomLeft: Radius.circular(7),
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
                        option,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Radio(
                    value: option,
                    groupValue: _selectedReservability,
                    autofocus: true,
                    onChanged: _selectedDailyOrMonthly!.compareTo("Daily") == 0
                        ? (String? value) {
                            setState(() {
                              _selectedReservability = value;
                            });
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? get getSelectedReservability => _selectedReservability;

  String? get getSelectedDailyOrMonthly => _selectedDailyOrMonthly;
}

class Features extends StatefulWidget {
  final List<FeaturesItem> features;
  const Features({Key? key, required this.features}) : super(key: key);

  @override
  State<Features> createState() => FeaturesState();
}

class FeaturesState extends State<Features> {
  List<FeaturesItem> featuresItems = [];
  List<String> selectedFeatures = [];

  @override
  void initState() {
    featuresItems = widget.features;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...featuresItems.map((buildCheckboxItem)).toList(),
      ],
    );
  }

  Widget buildCheckboxItem(FeaturesItem feature) {
    return CheckboxListTile(
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(
        feature.title,
        style: const TextStyle(
          fontSize: 18,
        ),
      ),
      value: feature.isChecked,
      onChanged: (value) {
        setState(() {
          feature.isChecked = value!;
          selectedFeatures.clear();
          // ignore: avoid_function_literals_in_foreach_calls
          featuresItems.forEach((feature) {
            if (feature.isChecked) {
              selectedFeatures.add(feature.title);
            }
          });
        });
      },
    );
  }

  List<String> get getSelectedFeatures => selectedFeatures;
}

class FeaturesItem {
  final String title;
  bool isChecked;

  FeaturesItem({required this.title, this.isChecked = false});

  String get getTitle => title;

  set setChecked(bool isChecked) {
    this.isChecked = isChecked;
  }

  @override
  String toString() {
    return "FeaturesITem[title: $title isChecked: $isChecked]";
  }
}

class Paypal extends StatefulWidget {
  const Paypal({Key? key}) : super(key: key);

  @override
  State<Paypal> createState() => PaypalState();
}

class PaypalState extends State<Paypal> {
  final _paypalKey = GlobalKey<FormState>();
  final _paypalController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _paypalKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Link your paypal account",
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _paypalController,
            style: const TextStyle(
              fontSize: 16,
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Field is required.";
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  GlobalKey<FormState> get getFormKey => _paypalKey;

  String get getPaypaEmail => _paypalController.text.trim();
}
