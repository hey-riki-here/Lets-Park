import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lets_park/shared/navigation_drawer.dart';
import 'package:lets_park/shared/shared_widgets.dart';

class AboutUs extends StatelessWidget {
  final int _pageId = 7;
  final textStyle = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );
  final double divHeight = 15;
  const AboutUs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _scaffoldKey = GlobalKey<ScaffoldState>();
    final SharedWidget _sharedWidgets = SharedWidget();
    return Scaffold(
      key: _scaffoldKey,
      appBar: _sharedWidgets.appbarDrawer(
        title: "About Us",
        onPressed: () {
          _scaffoldKey.currentState!.openDrawer();
        },
      ),
      drawer: NavigationDrawer(currentPage: _pageId),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: _sharedWidgets.headerWithLogo()),
              SizedBox(height: divHeight),
              Text(
                "About the App",
                style: textStyle,
              ),
              SizedBox(height: divHeight),
              const Text(
                "With Let's Park parking is made easy. Locate available parking space and book or pay now. Generate extra income using our app by registering your space and manage it.",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              SizedBox(height: divHeight),
              Text(
                "About the Developers",
                style: textStyle,
              ),
              SizedBox(height: divHeight),
              _buildDeveloperInfo(
                imageUrl: 'assets/devs/dev-1.jpg',
                name: 'Ricky E. Eredillas Jr.',
                position: 'Lead Programmer',
              ),
              SizedBox(height: divHeight),
              _buildDeveloperInfo(
                imageUrl: 'assets/devs/dev-2.jpg',
                name: 'Marc Tristan S.C. Lampitoc',
                position: 'Assistant Programmer',
              ),
              SizedBox(height: divHeight),
              _buildDeveloperInfo(
                imageUrl: 'assets/devs/dev-4.jpg',
                name: 'Kevin Joshua I. Pelayo',
                position: 'Front-end Developer',
              ),
              SizedBox(height: divHeight),
              _buildDeveloperInfo(
                imageUrl: 'assets/devs/dev-3.jpg',
                name: 'Jeffrey L. Cruz',
                position: 'Front-end Developer',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeveloperInfo({
    required String imageUrl,
    required String name,
    required String position,
  }) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue[400],
            radius: 70,
            child: CircleAvatar(
              backgroundImage: AssetImage(imageUrl),
              radius: 68,
            ),
          ),
          SizedBox(height: divHeight),
          Text(
            name,
            style: const TextStyle(
              fontSize: 21,
            ),
          ),
          SizedBox(height: divHeight),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              CircleAvatar(
                child: Icon(Icons.facebook, size: 35),
              ),
              CircleAvatar(
                child: Icon(Icons.mail, size: 25),
              ),
              CircleAvatar(
                child: Icon(FontAwesomeIcons.linkedinIn, size: 25),
              ),
            ],
          ),
          SizedBox(height: divHeight),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Position",
                    style: textStyle,
                  ),
                  SizedBox(height: divHeight),
                  Text(
                    position,
                    style: const TextStyle(
                      fontSize: 21,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
