import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lets_park/services/signin_provider.dart';
import 'package:lets_park/shared/navigation_drawer.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  final int _pageId = 1;
  const Profile({Key? key}) : super(key: key);
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final user = FirebaseAuth.instance.currentUser!;

  String phoneNumber = "None";
  String photoUrl = "https://cdn4.iconfinder.com/data/icons/user-people-2/48/5-512.png";

  @override
  void initState() {
    if (user.phoneNumber != null) {
      phoneNumber = user.phoneNumber!;
    }

    if (user.photoURL != null) {
      photoUrl = user.photoURL!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.blue[400],
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<SignInProvider>(
                context,
                listen: false,
              ).logout(context);
            },
          )
        ],
        centerTitle: true,
        title: const Text("Profile"),
        elevation: 0,
        bottom: PreferredSize(
          child: Container(
              color: Colors.blue[400],
              height: 120.0,
              width: double.infinity,
              child: Column(
                children: <Widget>[
                  CircleAvatar(
                    backgroundImage: NetworkImage(photoUrl),
                    radius: 40,
                  ),
                  const SizedBox(height: 10),
                ],
              )),
          preferredSize: const Size.fromHeight(120.0),
        ),
      ),
      drawer: NavigationDrawer(currentPage: widget._pageId),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Personal Information",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 21,
              ),
            ),
            const SizedBox(height: 20),
            FieldWidget(label: "Name", text: user.displayName!),
            const Divider(color: Colors.black, height: 30),
            FieldWidget(label: "Email", text: user.email!),
            const Divider(color: Colors.black, height: 30),
            FieldWidget(label: "Phone Number", text: phoneNumber),
            const Divider(color: Colors.black, height: 30),
            // FieldWidget(label: "Password", text: user.p),
            //const Divider(color: Colors.black, height: 30),
          ],
        ),
      ),
    );
  }
}

class FieldWidget extends StatelessWidget {
  final String label, text;
  const FieldWidget({Key? key, required this.label, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            primary: Colors.blue[400],
          ),
          icon: const Icon(Icons.edit, size: 18),
          label: const Text('Edit'),
          onPressed: () {},
        ),
      ],
    );
  }
}
