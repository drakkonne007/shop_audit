import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shop_audit/main.dart';

class LoadSplash extends StatefulWidget
{
  @override
  State<LoadSplash> createState() => _LoadSplashState();
}

Future<bool> _handlePermission(BuildContext context) async
{
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await geolocatorPlatform.isLocationServiceEnabled();
  if(!serviceEnabled){
    await geolocatorPlatform.openLocationSettings();
  }
  serviceEnabled = await geolocatorPlatform.isLocationServiceEnabled();
  if (!serviceEnabled) {
    if(context.mounted){
      return _handlePermission(context);
    }
    // // Location services are not enabled don't continue
    // // accessing the position and request users of the
    // // App to enable the location services.
    // if(context.mounted) {
    //   await showDialog<bool>(
    //     context: context,
    //     builder: (BuildContext context) =>
    //         AlertDialog(
    //           content: const Text(
    //               'Нет доступа к GPS! Без него программа работать не будет'),
    //           actions: <Widget>[
    //             TextButton(
    //               onPressed: () => Navigator.pop(context, true),
    //               child: const Text('Ок'),
    //             ),
    //           ],
    //         ),
    //   );
    // }
    // return false;
  }

  permission = await geolocatorPlatform.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await geolocatorPlatform.requestPermission();
    if (permission == LocationPermission.denied) {
      if(context.mounted){
        return _handlePermission(context);
      }
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      // if(context.mounted) {
      //   await showDialog<bool>(
      //     context: context,
      //     builder: (BuildContext context) =>
      //         AlertDialog(
      //           content: const Text(
      //               'Нет доступа к GPS! Без него программа работать не будет'),
      //           actions: <Widget>[
      //             TextButton(
      //               onPressed: () => Navigator.pop(context, true),
      //               child: const Text('Ок'),
      //             ),
      //           ],
      //         ),
      //   );
      // }
      // return false;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    if(context.mounted){
      return _handlePermission(context);
    }
    // Permissions are denied forever, handle appropriately.
    // if(context.mounted) {
    //   await showDialog<bool>(
    //     context: context,
    //     builder: (BuildContext context) =>
    //         AlertDialog(
    //           content: const Text(
    //               'Нет доступа к GPS! Без него программа работать не будет'),
    //           actions: <Widget>[
    //             TextButton(
    //               onPressed: () => Navigator.pop(context, true),
    //               child: const Text('Ок'),
    //             ),
    //           ],
    //         ),
    //   );
    // }
    // return false;
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.


  return true;
}

class _LoadSplashState extends State<LoadSplash> {


  bool isConnect = true;
  bool isProcessing = true;

  void catchAccess(bool result)
  {
    socketHandler.isLoginFunc = null;
    if(result){
      initializeService();
      Navigator.of(context).pushNamedAndRemoveUntil(
          '/mapScreen', (route) => false);
    }else{
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  Future<void> loadDB() async
  {
    await [
      Permission.locationAlways,
      Permission.locationWhenInUse,
      Permission.location,
      Permission.accessMediaLocation,
    ].request();
    if(context.mounted) {
      await _handlePermission(context);
    }
    String? login = mainShared?.getString('login');
    String? pwd = mainShared?.getString('pwd');
    if(!socketHandler.isLoad) {
      await socketHandler.init();
    }
    if(socketHandler.isLoad) {
      if(login != null && pwd != null){
        socketHandler.isLoginFunc = catchAccess;
        socketHandler.checkAccess(login, pwd);
      }else{
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }else{
      setState(() {
        isConnect = false;
      });
    }
    isProcessing = false;
  }

  @override
  Widget build(BuildContext context)
  {
    isConnect ? {
      loadDB(),
    } : (){};
    return Scaffold(
        body:Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  isConnect ? const Text('Подключаемся к базе данных...') : const Text("Не удалось подключиться"),
                  isProcessing ? const SizedBox(height: 20) : Container(),
                  isProcessing ? const CircularProgressIndicator() : Container(),
                  const SizedBox(height: 20),
                  isConnect ? Container() : ElevatedButton(onPressed: (){
                    setState(() {
                      isProcessing = true;
                      loadDB();
                    });
                  }, child: const Text('Переподключиться')),
                  isConnect ? Container() : const SizedBox(height: 20),
                  ElevatedButton(onPressed: (){
                    exit(0);
                  }, child: const Text('Выйти'))
                ]
            )
        )
    );
  }
}
