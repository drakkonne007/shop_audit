import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
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
import 'package:yandex_mapkit/yandex_mapkit.dart';

const int versionApk = 31;
SharedPreferences? mainShared;
GlobalHandler globalHandler = GlobalHandler();
SocketHandler socketHandler = SocketHandler();
late SqlFliteDB sqlFliteDB;
final GeolocatorPlatform geolocatorPlatform = GeolocatorPlatform.instance;
double meterShop = 100;

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
  mainShared?.setBool('onRoute', false);
  var bytes = await rootBundle.load('assets/greenGalk.png');
  var dir = await getApplicationSupportDirectory();
  File file = File('${dir.path}/greenGalk.png');
  if(!file.existsSync()){
    file.createSync();
    file.openSync(mode: FileMode.write);
    file.writeAsBytesSync(bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
    file.path;
    mainShared?.setString('greenGalk', '${dir.path}/greenGalk.png');
  }
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
// this will be used as notification channel id
// const notificationChannelId = 'my_foreground';

// this will be used for notification id, So you can update your custom notification with this id.
// const notificationId = 888;

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
      ),
      iosConfiguration: IosConfiguration());
}

@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  final GeolocatorPlatform geolocatorPlatform = GeolocatorPlatform.instance;
  var shared =  await SharedPreferences.getInstance();
  Position? myLocation;
  Timer.periodic(const Duration(seconds: 50), (timer) async {
    shared.reload();
    bool isLoad =  shared.getBool('onRoute') ?? false;
    if(!isLoad){
      return;
    }
    if(myLocation == null){
      myLocation = await geolocatorPlatform.getCurrentPosition();
      Socket socket = await Socket.connect('195.38.167.138', 9891);
      socket.write('auditor:12345\x17');
      socket.write('id=10;reload=true;setCurrPosition?userId=${shared.getString('userId')};xCoord=${myLocation!.latitude};yCoord=${myLocation!.longitude};dtime=${(DateTime.now().millisecondsSinceEpoch ~/ 1000)}\x17');
      socket.close();
      return;
    }
    var locPos = await geolocatorPlatform.getCurrentPosition();
    var distance = Geolocator.distanceBetween(myLocation!.latitude, myLocation!.longitude, locPos.latitude, locPos.longitude);
    if(distance < 70){
      return;
    }
    myLocation = locPos;
    Socket socket = await Socket.connect('195.38.167.138', 9891);
    socket.write('auditor:12345\x17');
    socket.write('id=10;reload=true;setCurrPosition?userId=${shared.getString('userId')};xCoord=${locPos.latitude};yCoord=${locPos.longitude};dtime=${(DateTime.now().millisecondsSinceEpoch ~/ 1000)}\x17');
    socket.close();
  });
}