// ignore_for_file: unused_catch_clause

import 'package:http/http.dart';
import 'dart:convert';

class WorldTimeServices {
  static Future<DateTime> getDateTimeNow() async {
    try {
      Response response = await get(
        Uri.parse("http://worldtimeapi.org/api/timezone/Asia/Macau"),
      );
      Map data = jsonDecode(response.body);

      String dateTime = data["datetime"];
      String offset = data["utc_offset"].substring(1, 3);

      DateTime now = DateTime.parse(dateTime);
      now = now.add(Duration(hours: int.parse(offset)));

      return now;
    } on Exception catch (e) {
      return DateTime.now();
    }
  }

  static Future<DateTime> getDateOnlyNow() async {
    try {
      Response response = await get(
        Uri.parse("http://worldtimeapi.org/api/timezone/Asia/Macau"),
      );
      Map data = jsonDecode(response.body);

      String dateTime = data["datetime"];
      String offset = data["utc_offset"].substring(1, 3);

      DateTime now = DateTime.parse(dateTime);
      now = now.add(Duration(hours: int.parse(offset)));

      DateTime dateOnly = DateTime(
        now.year,
        now.month,
        now.day,
      );

      return dateOnly;
    } on Exception catch (e) {
      return DateTime.now();
    }
  }
  
}
