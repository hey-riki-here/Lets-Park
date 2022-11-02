import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lets_park/screens/drawer_screens/profile_page/my_favorites.dart';
import 'package:lets_park/screens/drawer_screens/profile_page/registered_cars.dart';
import 'package:lets_park/screens/drawer_screens/profile_page/update_profile_info.dart';
import 'package:lets_park/services/signin_provider.dart';
import 'package:lets_park/shared/navigation_drawer.dart';
import 'package:provider/provider.dart';
import 'package:lets_park/screens/signin_register/forgot_password.dart';

class Profile extends StatefulWidget {
  final int _pageId = 1;
  const Profile({Key? key}) : super(key: key);
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  User user = FirebaseAuth.instance.currentUser!;

  String phoneNumber = "None";
  String photoUrl =
      "https://cdn4.iconfinder.com/data/icons/user-people-2/48/5-512.png";

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
        centerTitle: true,
        title: const Text("Profile"),
        elevation: 0,
        bottom: PreferredSize(
          child: Container(
              color: Colors.blue[400],
              height: 140,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          user.displayName!,
                          style: const TextStyle(
                            fontSize: 21,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(
                              Icons.email_outlined,
                              color: Colors.red[700],
                            ),
                            const SizedBox(width: 10),
                            Text(
                              FirebaseAuth.instance.currentUser!.email!,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.phone_rounded,
                              color: Colors.green[400],
                            ),
                            const SizedBox(width: 10),
                            Text(
                              phoneNumber,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                        photoUrl,
                      ),
                      radius: 40,
                    ),
                  ],
                ),
              )),
          preferredSize: const Size.fromHeight(140),
        ),
      ),
      drawer: NavigationDrawer(currentPage: widget._pageId),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "ACCOUNT SETTINGS",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 10),
              Menu(notifyParent: refresh),
              const SizedBox(height: 20),
              const Text(
                "OTHER",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const MenuTD(),
            ],
          ),
        ),
      ),
    );
  }

  refresh() {
    setState(() {
      user = FirebaseAuth.instance.currentUser!;
      phoneNumber = "None";
      photoUrl =
          "https://cdn4.iconfinder.com/data/icons/user-people-2/48/5-512.png";
      if (user.phoneNumber != null) {
        phoneNumber = user.phoneNumber!;
      }

      if (user.photoURL != null) {
        photoUrl = user.photoURL!;
      }
    });
  }
}

class Menu extends StatelessWidget {
  final Function notifyParent;
  const Menu({
    Key? key,
    required this.notifyParent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(12),
            ),
          ),
          elevation: 5,
          child: Column(
            children: [
              buildMenuItem(
                icon: Icons.edit_note_rounded,
                iconSize: 20,
                iconColor: Colors.blue[400]!,
                label: "Update Profile info",
                insets: const EdgeInsets.all(15),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  topLeft: Radius.circular(12),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: ((context) => UpdateProfile(
                            notifyParent: notifyParent,
                          )),
                    ),
                  );
                },
              ),
              buildMenuItem(
                icon: Icons.favorite_outlined,
                iconSize: 22,
                iconColor: Colors.red[400]!,
                label: "My Favorites",
                insets: const EdgeInsets.all(15),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  topLeft: Radius.circular(12),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: ((context) => const MyFavorites()),
                    ),
                  );
                },
              ),
              buildMenuItem(
                icon: FontAwesomeIcons.car,
                iconSize: 20,
                iconColor: Colors.green[400]!,
                label: "My Cars",
                insets: const EdgeInsets.all(15),
                borderRadius: const BorderRadius.all(Radius.zero),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: ((context) => const RegisteredCars()),
                    ),
                  );
                },
              ),
              buildMenuItem(
                icon: Icons.paypal_rounded,
                iconSize: 20,
                iconColor: Colors.blue[700]!,
                label: "Paypal accounts",
                insets: const EdgeInsets.all(15),
                borderRadius: const BorderRadius.all(Radius.zero),
                onTap: ()  {},
              ),
              buildMenuItem(
                icon: FontAwesomeIcons.key,
                iconSize: 17,
                iconColor: Colors.yellow[700]!,
                label: "Reset password",
                insets: const EdgeInsets.all(15),
                borderRadius: const BorderRadius.all(Radius.zero),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ForgotPassword(email: FirebaseAuth.instance.currentUser!.email!)),
                  );
                },
              ),
              buildMenuItem(
                icon: Icons.logout_rounded,
                iconSize: 20,
                iconColor: Colors.red[400]!,
                label: "Logout",
                insets: const EdgeInsets.all(15),
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                onTap: () {
                  Provider.of<SignInProvider>(
                    context,
                    listen: false,
                  ).logout(context);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  refresh() {
    //setS
  }

  Widget buildMenuItem({
    required IconData icon,
    required double iconSize,
    required Color iconColor,
    required String label,
    required EdgeInsets insets,
    required BorderRadius borderRadius,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      child: Padding(
        padding: insets,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: iconColor,
                  size: iconSize,
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.grey.shade700,
            ),
          ],
        ),
      ),
    );
  }
}

class MenuTD extends StatelessWidget {
  const MenuTD({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(12),
            ),
          ),
          elevation: 5,
          child: Column(
            children: [
              buildMenuItem(
                label: "Privacy policy",
                insets: const EdgeInsets.all(15),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  topLeft: Radius.circular(12),
                ),
                onTap: () {},
              ),
              buildMenuItem(
                label: "Terms and conditions",
                insets: const EdgeInsets.all(15),
                borderRadius: const BorderRadius.all(Radius.zero),
                onTap: () {},
              ),
              buildMenuItem(
                label: "Guidelines",
                insets: const EdgeInsets.all(15),
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  refresh() {
    //setS
  }

  Widget buildMenuItem({
    required String label,
    required EdgeInsets insets,
    required BorderRadius borderRadius,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      child: Padding(
        padding: insets,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.grey.shade700,
            ),
          ],
        ),
      ),
    );
  }
}

class RecentParkingSample extends StatelessWidget {
  final String photoURL;
  const RecentParkingSample({Key? key, required this.photoURL})
      : super(key: key);

  final textStyle = const TextStyle(
    fontSize: 16,
  );

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(12),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: NetworkImage(
                    photoURL,
                  ),
                  radius: 25,
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Ricky Eredillas Jr.",
                      style: textStyle,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.yellow.shade600,
                          size: 15,
                        ),
                        Icon(
                          Icons.star,
                          color: Colors.yellow.shade600,
                          size: 15,
                        ),
                        Icon(
                          Icons.star,
                          color: Colors.yellow.shade600,
                          size: 15,
                        ),
                        Icon(
                          Icons.star,
                          color: Colors.yellow.shade600,
                          size: 15,
                        ),
                        Icon(
                          Icons.star,
                          color: Colors.yellow.shade600,
                          size: 15,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  FontAwesomeIcons.carAlt,
                  color: Colors.blue,
                  size: 30,
                ),
                const SizedBox(width: 15),
                Text(
                  "TWAT 124",
                  style: textStyle,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  color: Colors.blue,
                  size: 30,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Arrived:",
                            style: textStyle,
                          ),
                          Text(
                            "June 2, 2022 at 12:00 PM",
                            style: textStyle.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Departed:",
                            style: textStyle,
                          ),
                          Text(
                            "June 2, 2022 at 12:15 PM",
                            style: textStyle.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Duration:",
                            style: textStyle,
                          ),
                          Text(
                            "15 Minutes",
                            style: textStyle.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
