import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_audit/global/global_variants.dart';
import 'package:shop_audit/global/internalDatabase.dart';
import 'package:shop_audit/global/socket_handler.dart';
import 'package:shop_audit/pages/anketaPage.dart';
import 'package:shop_audit/pages/camera_handler.dart';
import 'package:shop_audit/pages/load_splash.dart';
import 'package:shop_audit/pages/login.dart';
import 'package:shop_audit/pages/new_shop.dart';
import 'package:shop_audit/pages/photo_page.dart';
import 'package:shop_audit/pages/map_screen.dart';
import 'package:shop_audit/pages/shopPage.dart';

SharedPreferences? mainShared;
const int versionApk = 11;
GlobalHandler globalHandler = GlobalHandler();
SocketHandler socketHandler = SocketHandler();
late SqlFliteDB sqlFliteDB;
final GeolocatorPlatform geolocatorPlatform = GeolocatorPlatform.instance;
double meterShop = 1000;

String presentDateTime(DateTime dateTime, {bool seconds = false})
{
  String answer = '${dateTime.year}.${dateTime.month}.${dateTime.day} ${dateTime.hour}:${dateTime.minute}';
  if(seconds){
    answer += ':${dateTime.second}';
  }
  return answer;
}

Future<void> main() async
{
  WidgetsFlutterBinding.ensureInitialized();
  mainShared = await SharedPreferences.getInstance();
  sqlFliteDB = SqlFliteDB();
  sqlFliteDB.openDb();
  CameraHandler().loadCameras();
  // if(await DatabaseClient().openDB()){
  //   // await DatabaseClient().getShopPoints();
  //   await DatabaseClient().getReverseShopPoints();
  // }
  // exit(0);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget
{
  const MyApp({super.key});

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
  Widget build(BuildContext context)
  {
    return MaterialApp(
      title: 'Yandex Map',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/loadSplash',
      routes: {
        '/mapScreen': (context) => const MapScreen(),
        '/login': (context) => LoginPage(),
        '/photoPage': (context) => PhotoPage(),
        '/newShop': (context) => NewShopPage(),
        '/shopPage': (context) => ShopPage(),
        // '/points': (context) => PointsPage(),
        // '/report': (context) => ReportPage(),
        '/loadSplash': (context) => LoadSplash(),
        '/anketaPage': (context) => AnketaPage(),
      },
    );
  }
}