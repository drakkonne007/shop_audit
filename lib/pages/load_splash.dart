
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_audit/component/camera_handler.dart';
import 'package:shop_audit/global/database.dart';

class LoadSplash extends StatefulWidget {

  late final SharedPreferences prefs;

  @override
  State<LoadSplash> createState() => _LoadSplashState();
}

class _LoadSplashState extends State<LoadSplash> {

  bool isConnect = true;
  bool isProcessing = true;


  Future<void> loadDB() async
  {
    widget.prefs = await SharedPreferences.getInstance();
    bool isLogged = widget.prefs.getBool('isLogged') ?? false;
    bool answer = await DatabaseClient().openDB();
    if(answer == true) {
      DatabaseClient().getShopPoints();
      DatabaseClient().loadReports();
      if(isLogged){
        Navigator.of(context).pushNamedAndRemoveUntil('/mapScreen', (route) => false);
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
      CameraHandler().loadCameras()
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
