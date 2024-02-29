
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shop_audit/component/dynamic_alert_msg.dart';
import 'package:shop_audit/global/global_variants.dart';
import 'package:shop_audit/global/shop_points_for_job.dart';
import 'package:shop_audit/global/socket_handler.dart';
import 'package:shop_audit/main.dart';
import 'package:shop_audit/pages/camera_handler.dart';

class LoadSplash extends StatefulWidget {

  @override
  State<LoadSplash> createState() => _LoadSplashState();
}

class _LoadSplashState extends State<LoadSplash> {


  bool isConnect = true;
  bool isProcessing = true;

  void catchAccess(bool result)
  {
    socketHandler.isLoginFunc = null;
    if(result){
      Navigator.of(context).pushNamedAndRemoveUntil(
          '/mapScreen', (route) => false);
    }else{
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  Future _askRequiredPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.locationAlways,
      Permission.locationWhenInUse,
      Permission.location,
      Permission.accessMediaLocation,
    ].request();
  }

  Future<void> loadDB() async
  {
    await _askRequiredPermission();
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
  Widget build(BuildContext context) {
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
