import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lets_park/screens/logged_in_screens/google_map_screen.dart';
import 'package:lets_park/shared/NavigationDrawer.dart';

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
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    } else {}

    if (permission == LocationPermission.deniedForever) {
      // Some popup or instuctions to enable Location permission
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
        _buildCategory("Nearest", 100),
        _buildCategory("Highest Rating", 120),
        _buildCategory("Secured", 100),
      ],
    );
  }

  Widget _buildCategory(String label, double width) {
    return Material(
      borderRadius: const BorderRadius.all(Radius.circular(15)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {},
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
