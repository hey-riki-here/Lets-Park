import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lets_park/models/parking_space.dart';
import 'package:lets_park/screens/logged_in_screens/google_map_screen.dart';
import 'package:lets_park/screens/popups/parking_area_info.dart';
import 'package:lets_park/shared/NavigationDrawer.dart';
import 'package:location/location.dart';

class Home extends StatefulWidget {
  final int _pageId = 2;
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    grantPermission();
    return Scaffold(
      key: _scaffoldKey,
      drawer: NavigationDrawer(currentPage: widget._pageId),
      body: SafeArea(
        child: Stack(
          children: [
            const GoogleMapScreen(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      DrawerButton(scaffoldKey: _scaffoldKey),
                      const SizedBox(width: 10),
                      const SearchBox(),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const FilterButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void grantPermission() async {
    Location location = Location();

    PermissionStatus _permissionGranted;

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }
}

class DrawerButton extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const DrawerButton({Key? key, required this.scaffoldKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      elevation: 2,
      color: Colors.white,
      child: IconButton(
        icon: const Icon(Icons.menu),
        splashRadius: 30,
        color: Colors.black,
        onPressed: () {
          scaffoldKey.currentState!.openDrawer();
        },
      ),
    );
  }
}

class SearchBox extends StatelessWidget {
  const SearchBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        elevation: 2,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextFormField(
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Enter location here',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide.none,
              ),
            ),
            textAlign: TextAlign.start,
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}

class FilterButtons extends StatelessWidget {
  const FilterButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 50),
        _buildCategory("Nearest", 100, context),
        _buildCategory("Highest Rating", 120, context),
        _buildCategory("Secured", 100, context),
      ],
    );
  }

  Widget _buildCategory(String label, double width, BuildContext context) {
    return Material(
      borderRadius: const BorderRadius.all(Radius.circular(15)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
        },
        child: Ink(
          height: 30,
          width: width,
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
