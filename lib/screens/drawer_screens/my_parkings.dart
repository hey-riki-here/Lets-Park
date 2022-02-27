import 'package:flutter/material.dart';
import 'package:lets_park/shared/NavigationDrawer.dart';

class MyParkings extends StatefulWidget {
  final int _pageId = 3;
  const MyParkings({Key? key}) : super(key: key);

  @override
  _MyParkingsState createState() => _MyParkingsState();
}

class _MyParkingsState extends State<MyParkings> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              _scaffoldKey.currentState!.openDrawer();
            },
          ),
          elevation: 2,
          bottom: PreferredSize(
            child: Container(
              color: Colors.white,
              height: 120.0,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "My Parkings",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TabBar(
                    labelColor: Colors.black,
                    tabs: [
                      Tab(
                        child: Text(
                          "In Progress",
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),
                      ),
                      Tab(
                        child: Text(
                          "Upcoming",
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),
                      ),
                      Tab(
                        child: Text(
                          "History",
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            preferredSize: const Size.fromHeight(120.0),
          ),
        ),
        drawer: NavigationDrawer(currentPage: widget._pageId),
        body: const TabBarView(
          children: [
            Center(
              child: Text("Tab 1"),
            ),
            Center(
              child: Text("Tab 2"),
            ),
            Center(
              child: Text("Tab 3"),
            ),
          ],
        ),
      ),
    );
  }
}
