import 'package:flutter/material.dart';
import 'package:shop_audit/global/database.dart';
import 'package:shop_audit/pages/login.dart';
import 'package:shop_audit/pages/points.dart';
import 'package:shop_audit/pages/report.dart';
import 'package:shop_audit/pages/map_screen.dart';


Future<void> main() async{
  await DatabaseClient().openDB();
  DatabaseClient().getShopPoints();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yandex Map',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/mapScreen': (context) => const MapScreen(),
        '/login': (context) => LoginPage(),
        '/points': (context) => PointsPage(),
        '/report': (context) => ReportPage(),
      },
    );
  }
}