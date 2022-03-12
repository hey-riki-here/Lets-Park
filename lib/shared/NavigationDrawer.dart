import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lets_park/screens/drawer_screens/about_us.dart';
import 'package:lets_park/screens/drawer_screens/manage_space/manage_space.dart';
import 'package:lets_park/screens/drawer_screens/messages.dart';
import 'package:lets_park/screens/drawer_screens/my_parkings.dart';
import 'package:lets_park/screens/drawer_screens/notifications.dart';
import 'package:lets_park/screens/drawer_screens/profile.dart';
import 'package:lets_park/screens/drawer_screens/register_screens/register_area.dart';
import 'package:lets_park/screens/logged_in_screens/home.dart';

class NavigationDrawer extends StatefulWidget {
  final int currentPage;
  const NavigationDrawer({Key? key, required this.currentPage})
      : super(key: key);

  @override
  State<NavigationDrawer> createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer> {
  final user = FirebaseAuth.instance.currentUser!;

  String photoURL = "https://cdn4.iconfinder.com/data/icons/user-people-2/48/5-512.png";

  @override
  void initState() {
    if (user.photoURL != null) {
      photoURL = user.photoURL!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        child: Material(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListView(
              children: [
                const Header(),
                const SizedBox(height: 20),
                const Divider(
                  color: Colors.black,
                ),
                const SizedBox(height: 20),
                MyAccount(
                  id: 1,
                  currentPage: widget.currentPage,
                  name: user.displayName!,
                  photoUrl: photoURL,
                ),
                const SizedBox(height: 40),
                const Text(
                  "Let's Park",
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.blue,
                  ),
                ),
                Item(
                  title: 'Find parking space',
                  id: 2,
                  currentPage: widget.currentPage,
                ),
                Item(
                  title: 'My Parkings',
                  id: 3,
                  currentPage: widget.currentPage,
                ),
                Item(
                  title: 'Notifications',
                  id: 4,
                  currentPage: widget.currentPage,
                ),
                Item(
                  title: 'Messages',
                  id: 5,
                  currentPage: widget.currentPage,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Earn",
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.blue,
                  ),
                ),
                Item(
                  title: 'Rent out your own space',
                  id: 6,
                  currentPage: widget.currentPage,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Developers",
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.blue,
                  ),
                ),
                Item(
                  title: 'About us',
                  id: 7,
                  currentPage: widget.currentPage,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Header extends StatelessWidget {
  const Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SizedBox(height: 20),
            Text(
              "Let's Park!",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 25,
              ),
            ),
            Text(
              "7TH DEVS",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 15,
              ),
            ),
          ],
        ),
        Image.asset(
          'assets/logo/lets-park-logo.png',
          width: 50,
          height: 50,
        ),
      ],
    );
  }
}

class MyAccount extends StatelessWidget {
  final int id;
  final int currentPage;
  final String photoUrl;
  final String name;
  const MyAccount({
    Key? key,
    required this.id,
    required this.currentPage,
    required this.photoUrl,
    required this.name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(photoUrl),
            radius: 30,
            backgroundColor: Colors.grey,
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "My account",
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
      onTap: () {
        Navigator.pop(context);
        if (currentPage != id) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Profile()),
          );
        }
      },
    );
  }
}

class Item extends StatelessWidget {
  final String title;
  final int id;
  final int currentPage;
  const Item(
      {Key? key,
      required this.title,
      required this.id,
      required this.currentPage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w400,
        ),
      ),
      onTap: () => goToPage(title, context),
    );
  }

  void goToPage(String title, BuildContext context) {
    Navigator.pop(context);
    switch (title) {
      case 'Find parking space':
        if (currentPage != id) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Home()),
          );
        }
        break;
      case 'My Parkings':
        if (currentPage != id) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MyParkings()),
          );
        }
        break;
      case 'Notifications':
        if (currentPage != id) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Notifications()),
          );
        }
        break;
      case 'Messages':
        if (currentPage != id) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Messages()),
          );
        }
        break;
      case 'About us':
        if (currentPage != id) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AboutUs()),
          );
        }
        break;
        case 'Rent out your own space':
        if (currentPage != id) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ManageSpace()),
          );
        }
        break;
      default:
    }
  }
}
