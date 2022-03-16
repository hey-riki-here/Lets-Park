import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lets_park/models/parking_space.dart';
import 'package:lets_park/screens/drawer_screens/register_screens/register_area.dart';
import 'package:lets_park/shared/shared_widgets.dart';
import 'package:lets_park/globals/globals.dart' as globals;

class YourSpace extends StatelessWidget {
  final appUser = globals.appUser;
  YourSpace({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _sharedWidgets = SharedWidget();
    List<ParkingSpace>? parkingSpaces = appUser.getOwnedParkingSpaces;

    return Scaffold(
      appBar: _sharedWidgets.manageSpaceAppBar("Your spaces"),
      backgroundColor: Colors.grey.shade300,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: parkingSpaces!.length,
                itemBuilder: (context, index) {
                  int title = index + 1;
                  return ParkingCard(
                    parkingSpace: parkingSpaces[index],
                    title: "$title",
                  );
                },
              ),
            ),
            const AddMore(),
          ],
        ),
      ),
    );
  }
}

class ParkingCard extends StatelessWidget {
  final ParkingSpace parkingSpace;
  final String title;
  const ParkingCard({Key? key, required this.parkingSpace, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    int capacity = parkingSpace.getCapacity!;
    return Card(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(12),
        ),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Space " + title,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                buildTag("Active", Colors.green),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              parkingSpace.getAddress!,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 7),
            Row(
              children: [
                Icon(
                  Icons.star,
                  color: Colors.yellow.shade600,
                  size: 17,
                ),
                Icon(
                  Icons.star,
                  color: Colors.yellow.shade600,
                  size: 17,
                ),
                Icon(
                  Icons.star,
                  color: Colors.yellow.shade600,
                  size: 17,
                ),
                Icon(
                  Icons.star,
                  color: Colors.yellow.shade600,
                  size: 17,
                ),
                Icon(
                  Icons.star,
                  color: Colors.yellow.shade600,
                  size: 17,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text(
                  "Available slots:",
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  "1/$capacity",
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildTag("Empty", Colors.blue),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    FontAwesomeIcons.pencilAlt,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTag(String label, Color color) {
    return Container(
      width: 100,
      height: 30,
      decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.all(Radius.circular(20))),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class AddMore extends StatelessWidget {
  const AddMore({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: ((context) => const RegisterArea())));
      },
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              FontAwesomeIcons.plusCircle,
              color: Colors.grey,
            ),
            SizedBox(width: 10),
            Text(
              "Increase your level to add more space.",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
