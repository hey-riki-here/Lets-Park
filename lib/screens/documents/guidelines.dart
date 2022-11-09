import 'package:flutter/material.dart';

class Guidelines extends StatelessWidget {
  const Guidelines({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        title: const Text(
          "Guidelines",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Parking space",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              buildArticle(
                "All parking space owner shall abide to the minimum requirements of a parking space must have that is stated in the City Ordinance no. 601 also known as \"Parking ng Bayan and Incentives Ordinance\".\n\nThe ordinance stated that parking space shall have the following:",
              ),
              const SizedBox(height: 10),
              buildSubRichTextArticle(
                "a.",
                "",
                " A watchman or caretaker shall be assigned for purpose of parking maintenance and security;",
              ),
              const SizedBox(height: 10),
              buildSubRichTextArticle(
                "b.",
                "",
                " Ensure that the parking lot or area is adequately ligted;",
              ),
              const SizedBox(height: 10),
              buildSubRichTextArticle(
                "c.",
                "",
                " A conspicuous sign or signs shall be posted at all entrances to the parking lot or parking area informing the public as to the permitted conditions of parking thereon;",
              ),
              const SizedBox(height: 10),
              buildSubRichTextArticle(
                "d.",
                "",
                " The whole lot or area shall be exclusively used as pay parking facility only;",
              ),
              const SizedBox(height: 10),
              buildSubRichTextArticle(
                "e.",
                "",
                " The parking lot or area can accomodate at least ten (10) parking slots;",
              ),
              const SizedBox(height: 10),
              buildSubRichTextArticle(
                "f.",
                "",
                " Perimeter shall be secured by fence, using at least a barb wire or cyclone wire;",
              ),
              const SizedBox(height: 10),
              buildSubRichTextArticle(
                "g.",
                "",
                " Parking layout must be properly marked to avoid over parking and maintain proper distances to avoid any accidents;",
              ),
              const SizedBox(height: 10),
              buildSubRichTextArticle(
                "h.",
                "",
                " The parking lot or area shall have a pervious surface of hard compression earth fill or at least gravel bedded. Concrete surfaces may be ideal but are discouraged;",
              ),
              const SizedBox(height: 10),
              buildSubRichTextArticle(
                "i.",
                "",
                " Parking and Electrical Layout shall be approved by the Office of the Building Official; and",
              ),
              const SizedBox(height: 10),
              buildSubRichTextArticle(
                "j.",
                "",
                " A provision for maintenance of comfort room is also encouraged for proper hygience and sanitation.",
              ),
              const SizedBox(height: 20),
              const Text(
                "Parking Fee",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              buildArticle(
                "In accordance to the said ordinance, the following parking fee shall be used:",
              ),
              const SizedBox(height: 10),
              buildSubRichTextArticle(
                "a.",
                " Short-term parking",
                "",
              ),
              const SizedBox(height: 10),
              buildSubSubRichTextArticle(
                "",
                "",
                "The parking fee to be collected in cases of daily or short-term parking shall not exceed P50.00/day for a maximum period of eight (8) hours and additional P10.00 per hour in excess thereof.",
              ),
              const SizedBox(height: 10),
              buildSubRichTextArticle(
                "b.",
                " Monthly parking",
                "",
              ),
              const SizedBox(height: 10),
              buildSubSubRichTextArticle(
                "",
                "",
                "The parking for a monthly rent shall not exceed P1,500.00/slot per month.",
              ),
              const SizedBox(height: 20),
              const Text(
                "Payment",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              buildArticle(
                "In order for a driver to succesfully book a parking space he/she must have a Paypal account. Paypal will be the payment gateway that will be used through out the entire transaction. The space owner shall also have a Paypal account to receive payments from the Drivers.",
              ),
              const SizedBox(height: 20),
              const Text(
                "No cancellation of booking",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              buildArticle(
                "The drivers that already booked a parking space can no longer cancel a booking or request for a refund. This is to prevent inconvenience for the parking area owners.",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildArticle(String article) {
    return Row(
      children: [
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            article,
          ),
        ),
      ],
    );
  }

  Widget buildRichTextArticle(
    String articleNumber,
    String articleName,
    String article,
  ) {
    return Row(
      children: [
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: articleNumber,
              style: const TextStyle(
                color: Colors.black,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: articleName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: article,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSubRichTextArticle(
    String articleNumber,
    String articleName,
    String article,
  ) {
    return Row(
      children: [
        const SizedBox(width: 20),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: articleNumber,
              style: const TextStyle(
                color: Colors.black,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: articleName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: article,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSubSubRichTextArticle(
    String articleNumber,
    String articleName,
    String article,
  ) {
    return Row(
      children: [
        const SizedBox(width: 30),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: articleNumber,
              style: const TextStyle(
                color: Colors.black,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: articleName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: article,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
