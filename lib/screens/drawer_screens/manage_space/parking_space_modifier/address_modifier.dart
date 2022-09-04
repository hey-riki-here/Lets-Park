import 'package:flutter/material.dart';
import 'package:lets_park/models/parking_space.dart';
import 'package:lets_park/screens/popups/notice_dialog.dart';
import 'package:lets_park/services/parking_space_services.dart';

class AddressModifier extends StatelessWidget {
  final ParkingSpace space;
  const AddressModifier({
    Key? key,
    required this.space,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GlobalKey<AreaAdressState> _addressState = GlobalKey();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text("Edit Address"),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: const [
                Text(
                  "Input new address",
                  style: TextStyle(
                    fontSize: 22,
                  ),
                ),
              ],
            ),
            AreaAdress(
              space: space,
              key: _addressState,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.save,
        ),
        onPressed: () async {
          if (_addressState.currentState!.getFormKey.currentState!.validate()) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => WillPopScope(
                onWillPop: () async => false,
                child: const NoticeDialog(
                  imageLink: "assets/logo/lets-park-logo.png",
                  message:
                      "We are now updating the parking space. Please wait.",
                  forLoading: true,
                ),
              ),
            );
            space.setAddress = _addressState.currentState!.getAddress;

            await Future.delayed(const Duration(seconds: 1));

            ParkingSpaceServices.updateSpaceAddress(
              space.getSpaceId!,
              _addressState.currentState!.getAddress,
            );

            Navigator.pop(context);
            Navigator.pop(context, space);
          }
        },
      ),
    );
  }
}

class AreaAdress extends StatefulWidget {
  final ParkingSpace space;
  const AreaAdress({
    Key? key,
    required this.space,
  }) : super(key: key);

  @override
  State<AreaAdress> createState() => AreaAdressState();
}

class AreaAdressState extends State<AreaAdress> {
  TextEditingController barangay = TextEditingController();
  late TextEditingController street;
  final _formKey = GlobalKey<FormState>();
  final barangays = <String>[
    'Arkong Bato',
    'Bagbaguin',
    'Balangkas',
    'Bignay',
    'Bisig',
    'Canumay East',
    'Canumay West',
    'Coloong',
    'Dalandanan',
    'Gen. T. De Leon',
    'Isla',
    'Karuhatan',
    'Lawang Bato',
    'Lingunan',
    'Mabolo',
    'Malanday',
    'Malinta',
    'Mapulang Lupa',
    'Marulas',
    'Maysan',
    'Palasan',
    'Parada',
    'Pariancillo Villa',
    'Paso De Blas',
    'Pasolo',
    'Poblacion',
    'Pulo',
    'Punturin',
    'Rincon',
    'Tagalag',
    'Ugong',
    'Viente Reales',
    'Wawang Pulo',
  ];
  String selectedBarangay = "";
  String stepOneSubtitle = "";

  @override
  void initState() {
    // globals.globalStreet = street;
    // globals.globalBarangay = selectedBarangay;
    street = TextEditingController(
      text: getStreet(),
    );

    super.initState();
  }

  String getStreet() {
    String street = "";
    List<String> parts = widget.space.getAddress!.split(",");

    for (int i = 0; i < parts.length; i++) {
      if (i != parts.length - 2) {
        street += parts[i];
      } else {
        selectedBarangay = parts[i].trim();
        break;
      }
    }

    return street;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              const Text(
                "House No./Blk Lot/Street",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                textInputAction: TextInputAction.done,
                controller: street,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter street";
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Barangay",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedBarangay,
                    icon: const Icon(
                      Icons.arrow_drop_down_rounded,
                      size: 32,
                    ),
                    elevation: 16,
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedBarangay = newValue!;
                      });
                    },
                    items: barangays.map(dropdownItem).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  DropdownMenuItem<String> dropdownItem(String item) {
    return DropdownMenuItem(
      child: Text(
        item,
      ),
      value: item,
    );
  }

  GlobalKey<FormState> get getFormKey => _formKey;

  String get getAddress =>
      street.text + ", " + selectedBarangay + ", Valenzuela";
}
