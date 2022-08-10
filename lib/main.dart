import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lets_park/screens/wrapper.dart';
import 'package:lets_park/services/notif_services.dart';
import 'package:lets_park/services/signin_provider.dart';
import 'package:provider/provider.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  NotificationServices.initChannel();

  runApp(const LetsPark());
}

final navigatorKey = GlobalKey<NavigatorState>();

class LetsPark extends StatelessWidget {
  const LetsPark({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SignInProvider(),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: "Let's Park!",
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const Wrapper(),
      ),
    );
  }
}
