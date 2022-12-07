import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:galleryimage/galleryimage.dart';
import 'package:lets_park/models/parking_space.dart';

class SpaceCertificates extends StatelessWidget {
  final ParkingSpace space;
  const SpaceCertificates({
    Key? key,
    required this.space,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        title: const Text(
          "Certificates",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 30,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          "The images below are the certificates of the owner for the parking space that shows the legality of the business as well as the legality of the parking space.",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            GalleryImage(
              titleGallery: "",
              numOfShowImages: 2,
              imageUrls: space.getCertificates!,
            ),
          ],
        ),
      ),
    );
  }
}
