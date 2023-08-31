
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_audit/global/database.dart';
import 'package:shop_audit/global/socket_handler.dart';
import 'package:shop_audit/main.dart';

class LoadSplash extends StatefulWidget {

  @override
  State<LoadSplash> createState() => _LoadSplashState();
}

class _LoadSplashState extends State<LoadSplash> {

  bool isConnect = true;
  bool isProcessing = true;

  Future<void> loadDB() async
  {
    int? id = mainShared?.getInt('userId');
    bool isLogged = false;
    if(id != null && id != 0){
      isLogged = true;
    }
    await SocketHandler().init();
    if(SocketHandler().isLoad) {
      // DatabaseClient().getShopPoints();//FIXME это для субдо версии
      SocketHandler().loadShops(false);
      SocketHandler().getAims(false);
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
