import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lets_park/screens/intro/intro_screen.dart';
import 'package:lets_park/screens/wrapper.dart';
import 'package:lets_park/services/notif_services.dart';
import 'package:lets_park/services/signin_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Future main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   NotificationServices.initChannel();

//   final prefs = await SharedPreferences.getInstance();
//   runApp(LetsPark(
//     prefs: prefs,
//   ));

// }

// final navigatorKey = GlobalKey<NavigatorState>();

// class LetsPark extends StatelessWidget {
//   final SharedPreferences prefs;
//   const LetsPark({
//     Key? key,
//     required this.prefs,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     print("print statement");
//     return ChangeNotifierProvider(
//       create: (context) {
//         return SignInProvider();
//       },
//       child: MaterialApp(
//         navigatorKey: navigatorKey,
//         debugShowCheckedModeBanner: false,
//         title: "Let's Park!",
//         theme: ThemeData(
//           primarySwatch: Colors.blue,
//         ),
//         home: prefs.getBool("firstOpen") ?? true
//             ? const Introduction()
//             : const Wrapper(),
//       ),
//     );
//   }
// }

//For resolution testing
Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  NotificationServices.initChannel();

  final prefs = await SharedPreferences.getInstance();
  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => LetsPark(
        prefs: prefs,
      ),
    ),
  );
}

final navigatorKey = GlobalKey<NavigatorState>();

class LetsPark extends StatelessWidget {
  final SharedPreferences prefs;
  const LetsPark({
    Key? key,
    required this.prefs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("print statement");
    return ChangeNotifierProvider(
      create: (context) {
        return SignInProvider();
      },
      child: MaterialApp(
        navigatorKey: navigatorKey,
        useInheritedMediaQuery: true,
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        debugShowCheckedModeBanner: false,
        title: "Let's Park!",
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: prefs.getBool("firstOpen") ?? true
            ? const Introduction()
            : const Wrapper(),
      ),
    );
  }
}