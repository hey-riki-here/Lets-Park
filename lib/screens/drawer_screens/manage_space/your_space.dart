import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class YourSpace extends StatelessWidget {
  const YourSpace({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        bottom: PreferredSize(
          child: Container(
            color: Colors.white,
            height: 40,
            width: double.infinity,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Your Spaces",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          preferredSize: const Size.fromHeight(40),
        ),
      ),
      backgroundColor: Colors.grey.shade300,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: const [
              ParkingCard(),
              SizedBox(height: 15),
              AddMore(),
            ],
          ),
        ),
      ),
    );
  }
}

class ParkingCard extends StatelessWidget {
  const ParkingCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(12),
        ),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Space 1",
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                buildTag("Active", Colors.green),
              ],
            ),
            const SizedBox(height: 7),
            const Text(
              "83 P. Faustino St.",
              style: TextStyle(
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
              children: const [
                Text(
                  "Available slots:",
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 5),
                Text(
                  "1/1",
                  style: TextStyle(
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
          color: color, borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
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
    return Center(
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
    );
  }
}
