// ignore_for_file: unused_catch_clause, empty_catches

import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lets_park/globals/globals.dart' as globals;
import 'package:lets_park/shared/shared_widgets.dart';
import 'package:path/path.dart';

class AddressSection extends StatefulWidget {
  const AddressSection({Key? key}) : super(key: key);

  @override
  State<AddressSection> createState() => AddressSectionState();
}

class AddressSectionState extends State<AddressSection> {
  final SharedWidget _sharedWidget = SharedWidget();
  final GlobalKey<AreaAdressState> _addressState = GlobalKey();
  final GlobalKey<PhotoPickerState> _photoPickerState = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sharedWidget.stepHeader("Address"),
        const SizedBox(height: 10),
        PhotoPicker(key: _photoPickerState),
        const SizedBox(height: 30),
        const Text(
          "Provide the address of your area",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w300,
          ),
        ),
        AreaAdress(key: _addressState),
        const SizedBox(height: 10),
      ],
    );
  }

  GlobalKey<FormState> get getFormKey => _addressState.currentState!.getFormKey;
  File? get getImage => _photoPickerState.currentState!.getImage;
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
        const Text(
          "Please provide an image of the entrace of your parking space",
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
        )
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
      print(basename(image.path));
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
          height: 200,
          padding: const EdgeInsets.all(35),
          child: Column(
            children: const [
              Icon(
                Icons.cloud_upload,
                size: 80,
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

class AreaAdress extends StatefulWidget {
  const AreaAdress({Key? key}) : super(key: key);

  @override
  State<AreaAdress> createState() => AreaAdressState();
}

class AreaAdressState extends State<AreaAdress> {
  TextEditingController barangay = TextEditingController();
  TextEditingController street = TextEditingController();
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
  String selectedBarangay = 'Arkong Bato';
  String stepOneSubtitle = "";

  @override
  void initState() {
    globals.globalStreet = street;
    globals.globalBarangay = selectedBarangay;
    super.initState();
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
                        globals.globalBarangay = selectedBarangay;
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
}
