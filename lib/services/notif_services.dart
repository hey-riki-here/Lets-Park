// ignore_for_file: unused_field

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:lets_park/screens/drawer_screens/my_parkings.dart';

class NotificationServices {
  static bool _inProgress = true;

  static void initChannel() {
    AwesomeNotifications().initialize('resource://drawable/ic_icon', [
      NotificationChannel(
        channelGroupKey: 'basic_test',
        channelKey: 'basic',
        channelName: 'Basic notifications',
        channelDescription: 'Notification channel for basic tests',
        defaultColor: Colors.blue,
        channelShowBadge: true,
        importance: NotificationImportance.High,
        enableVibration: false,
      ),
    ]);
  }

  static void showNotification(String notificationTitle, String message) {
    if (notificationTitle.compareTo("Parking session started") == 0) {
      _inProgress = true;
    } else {
      _inProgress = false;
    }
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 123,
        wakeUpScreen: true,
        channelKey: 'basic',
        title: notificationTitle,
        body: message,
        autoDismissible: true,
      ),
      actionButtons: [
        NotificationActionButton(
          color: Colors.blue,
          key: "go_to_in_progress_parkings",
          label: _inProgress ? "View Parking" : "View Parking History",
        ),
      ],
    );
  }

  static void startListening(BuildContext context) {
    AwesomeNotifications().actionStream.listen((action) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MyParkings(
                  initialIndex: _inProgress ? 0 : 2,
                )),
      );
    });
  }
}
