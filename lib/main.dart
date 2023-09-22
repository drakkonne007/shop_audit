import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_audit/pages/load_splash.dart';
import 'package:shop_audit/pages/login.dart';
import 'package:shop_audit/pages/report.dart';
import 'package:shop_audit/pages/map_screen.dart';

SharedPreferences? mainShared;
int? globalUserId;

String presentDateTime(DateTime dateTime, {bool seconds = false})
{
  String answer = '${dateTime.year}.${dateTime.month}.${dateTime.day} ${dateTime.hour}:${dateTime.minute}';
  if(seconds){
    answer += ':${dateTime.second}';
  }
  return answer;
}

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  mainShared = await SharedPreferences.getInstance();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  MaterialColor getMaterialColor(Color color) {
    final int red = color.red;
    final int green = color.green;
    final int blue = color.blue;

    final Map<int, Color> shades = {
      50: Color.fromRGBO(red, green, blue, 1),
      100: Color.fromRGBO(red, green, blue, .2),
      200: Color.fromRGBO(red, green, blue, .3),
      300: Color.fromRGBO(red, green, blue, .4),
      400: Color.fromRGBO(red, green, blue, .5),
      500: Color.fromRGBO(red, green, blue, .6),
      600: Color.fromRGBO(red, green, blue, .7),
      700: Color.fromRGBO(red, green, blue, .8),
      800: Color.fromRGBO(red, green, blue, .9),
      900: Color.fromRGBO(red, green, blue, 1),
    };

    return MaterialColor(color.value, shades);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yandex Map',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.brown,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/loadSplash',
      routes: {
        '/mapScreen': (context) => const MapScreen(),
        '/login': (context) => LoginPage(),
        // '/points': (context) => PointsPage(),
        '/report': (context) => ReportPage(),
        '/loadSplash': (context) => LoadSplash(),
      },
    );
  }
}