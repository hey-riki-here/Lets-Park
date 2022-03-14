import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lets_park/models/app_user.dart';
import 'package:lets_park/screens/logged_in_screens/google_map_screen.dart';
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
  final user = FirebaseAuth.instance.currentUser;
  final GlobalKey<GoogleMapScreenState> _gMapKey = GlobalKey();
  final appUser = AppUser();
  @override
  Widget build(BuildContext context) {
    grantPermission();
    return Scaffold(
      key: _scaffoldKey,
      drawer: NavigationDrawer(currentPage: widget._pageId),
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMapScreen(key: _gMapKey),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      DrawerButton(scaffoldKey: _scaffoldKey),
                      const SizedBox(width: 10),
                      SearchBox(gMapKey: _gMapKey),
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
  final GlobalKey<GoogleMapScreenState> gMapKey;
  const SearchBox({Key? key, required this.gMapKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _controller = TextEditingController();
    return Expanded(
      child: Material(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        elevation: 2,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: _controller,
            textInputAction: TextInputAction.done,
            onSubmitted: (query) {
              gMapKey.currentState!.goToLocation(query + ", Valenzuela");
            },
            decoration: InputDecoration(
              suffixIcon: IconButton(
                  onPressed: () {
                    gMapKey.currentState!
                        .goToLocation(_controller.text.trim() + ", Valenzuela");
                  },
                  icon: const Icon(
                    Icons.search,
                    color: Colors.black54,
                    size: 20,
                  )),
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
          double totalDistance =
              calculateDistance(14.7560799, 120.9975581, 14.750741800000002, 121.00106040000001);

          print(totalDistance);
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

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
}
