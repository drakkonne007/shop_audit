

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shop_audit/component/internal_shop.dart';
import 'package:shop_audit/main.dart';

class Temp
{
  Temp(this.path, this.xCoord, this.yCoord, this.userId);
  String path;
  double xCoord;
  double yCoord;
  int userId;
}

class PreReport
{
  PreReport(this.files, this.text, this.shopId, this.extId, this.globalId);
  List<String> files;
  String text;
  int shopId;
  int extId;
  int globalId;
}

enum SocketState
{
  notInitialize,
  connected,
  disconnected
}

class SocketHandler
{
  late Socket _socket;
  String _buffer = '';
  bool isLoad = false;
  bool isLoading = true;
  ValueNotifier<SocketState> socketState = ValueNotifier(SocketState.notInitialize);
  int _id = 0;
  final List<int> _rawBytes = [];

  Function(bool isLogged)? isLoginFunc;
  Function()? _updateApp;
  Function(List<String>)? resendShopList;

  int _getId()
  {
    return _id++;
  }

  Future<void> init() async
  {
    try {
      isLoading = false;
      _socket = await Socket.connect('195.38.167.138', 9891);
      // _socket = await Socket.connect('10.11.100.189', 9891);
      _socket.listen(_dataRecive,
          onDone: () {
            if(!isLoading){
              socketState.value = SocketState.disconnected;
              isLoading = true;
              Future.delayed(const Duration(seconds: 1),init);
            }
          },
          onError: (error) {
            if(!isLoading){
              socketState.value = SocketState.disconnected;
              isLoading = true;
              Future.delayed(const Duration(seconds: 1),init);
            }
          },
          cancelOnError: false);
      _socket.write('auditor:12345\x17');
      isLoad = true;
      socketState.value = SocketState.connected;
    }catch (e){
      if(!isLoading){
        socketState.value = SocketState.disconnected;
        isLoading = true;
        Future.delayed(const Duration(seconds: 1),init);
      }
    }
  }

  void _dataRecive(data) async{
    _rawBytes.addAll(data);
    try{
      _buffer += utf8.decode(_rawBytes);
      _rawBytes.clear();
      if (_buffer.contains('\x17')) {
        var answer = _buffer.split('\x17');
        for (int i = 0; i < answer.length; i++) {
          _answersHub(answer[i]);
        }
        _buffer = answer[answer.length - 1];
      }
    }catch(e){
      print(e);
    }
  }

  void _catchConfigMeterShop(String text)
  {
    var answer = text.split('\r');
    if (answer.length < 3) {
      return;
    }
    var categories = answer[1].split(';');
    for (int i = 2; i < answer.length; i++) {
      var temp = answer[i].split(';');
      if(categories.contains('value')){
        meterShop = double.tryParse(temp[categories.indexOf('value')]) ?? 1000;
      }
      break;
    }
  }

  void _answersHub(String text)
  {
    if(text.contains('checkShop')){
      _catchCheckShops(text);
    }
    if(text.contains('getConfig')){
      _catchConfigMeterShop(text);
    }
    // if(text.contains('checkReport')){
    //   _catchCheckReport(text);
    // }
    // if(text.contains('loadShops') || text.contains('10shops')){
    //   _getShopPoints(text);
    //   return;
    // }
    if(text.contains('login')){
      _catchAccess(text);
      return;
    }
    if(text.contains('getCurrentBuild')){
      _catchBuild(text);
      return;
    }
  }

  //ВОПРОСЫ

  void getCurrentBuild(Function() update)
  {
    _updateApp = update;
    _sendMessage(text:'getCurrentBuild',reload:false);
  }

  void sendMyPosition(double xCoord,double yCoord)
  {
    _sendMessage(text:'setCurrPosition?userId=${globalHandler.userId};xCoord=$xCoord;yCoord=$yCoord;dtime=${(DateTime.now().millisecondsSinceEpoch ~/ 1000)}',reload:true);
  }

  void sendShop(List<InternalShop> shops)
  {
    compute(_newThreadSendReport, shops);
    Future.delayed(const Duration(minutes: 1), () {
      checkLostReports();
    });
  }



  void send100MeterPhoto(String path) async
  {
    Temp temp = Temp(path, globalHandler.currentUserPoint.latitude, globalHandler.currentUserPoint.longitude, globalHandler.userId);
    compute(_new100MeterPhoto,temp);
  }

  static void _new100MeterPhoto(Temp temp) async
  {
    print('hohohofhsoghodsg');
    print(temp.userId);
    print(temp.xCoord);
    print(temp.yCoord);
    try {
      if(File(temp.path).existsSync()){
        Socket socket = await Socket.connect('195.38.167.138', 9891);
        socket.write('auditor:12345\x17');
        socket.write('id=10;reload=true;addTempPhoto?');
        socket.write('photo=');
        socket.write(File(temp.path).readAsBytesSync());
        socket.write(';userId=${temp.userId};xCoord=${temp.xCoord};yCoord=${temp.yCoord};dtime=${(DateTime.now().millisecondsSinceEpoch ~/ 1000)}');
        socket.write('\x17');
        await socket.flush();
        socket.close();
      }
    }catch(e){
      print('Oh no!Error with send TEMP photo(((');
    }
  }


  static void _newThreadSendReport(List<InternalShop> preps) async
  {
    Socket socket = await Socket.connect('195.38.167.138', 9891);
    socket.write('auditor:12345\x17');
    for(final shop in preps){
      try {
        socket.write('id=10;reload=true;newTravelShop?'
            'userId=${shop.userId}'
            ';externalId=${shop.id}'
            ';shopName=${shop.shopName}'
            ';xCoord=${shop.xCoord}'
            ';yCoord=${shop.yCoord}'
            ';shopType=${shop.shopType.name}'
            ';yuridicForm=${shop.yuridicForm.name}'
            ';emptySpace=${shop.emptySpace.name}'
            ';phoneNumber=${shop.phoneNumber}'
            ';address=${shop.address}'
            ';shopSquare=${shop.shopSquareMeter}'
            ';cassCount=${shop.cassCount}'
            ';prodavecManagerCount=${shop.prodavecManagerCount}'
            ';halal=${shop.halal ? 1 : 0}'
            ';paymentTerminal=${shop.paymanetTerminal}'
            ';dtimeExternal=${shop.millisecsSinceEpoch~/1000}');
        if(File(shop.photoMap['externalPhoto']!).existsSync()){
          socket.write(';externalPhoto=');
          socket.write(File(shop.photoMap['externalPhoto']!).readAsBytesSync());
        }
        if(File(shop.photoMap['shopLabelPhoto']!).existsSync()){
          socket.write(';shopLabelPhoto=');
          socket.write(File(shop.photoMap['shopLabelPhoto']!).readAsBytesSync());
        }
        if(File(shop.photoMap['alkoholPhoto']!).existsSync()){
          socket.write(';alkoholPhoto=');
          socket.write(File(shop.photoMap['alkoholPhoto']!).readAsBytesSync());
        }
        if(File(shop.photoMap['kolbasaSyr']!).existsSync()){
          socket.write(';kolbasaSyr=');
          socket.write(File(shop.photoMap['kolbasaSyr']!).readAsBytesSync());
        }
        if(File(shop.photoMap['milk']!).existsSync()){
          socket.write(';milk=');
          socket.write(File(shop.photoMap['milk']!).readAsBytesSync());
        }
        if(File(shop.photoMap['snack']!).existsSync()){
          socket.write(';snack=');
          socket.write(File(shop.photoMap['snack']!).readAsBytesSync());
        }
        if(File(shop.photoMap['mylomoika']!).existsSync()){
          socket.write(';mylomoika=');
          socket.write(File(shop.photoMap['mylomoika']!).readAsBytesSync());
        }
        if(File(shop.photoMap['vegetablesFruits']!).existsSync()){
          socket.write(';vegetablesFruits=');
          socket.write(File(shop.photoMap['vegetablesFruits']!).readAsBytesSync());
        }
        if(File(shop.photoMap['cigarettes']!).existsSync()){
          socket.write(';cigarettes=');
          socket.write(File(shop.photoMap['cigarettes']!).readAsBytesSync());
        }
        if(File(shop.photoMap['kassovayaZona']!).existsSync()){
          socket.write(';kassovayaZona=');
          socket.write(File(shop.photoMap['kassovayaZona']!).readAsBytesSync());
        }
        if(File(shop.photoMap['toys']!).existsSync()){
          socket.write(';toys=');
          socket.write(File(shop.photoMap['toys']!).readAsBytesSync());
        }
        if(File(shop.photoMap['butter']!).existsSync()){
          socket.write(';butter=');
          socket.write(File(shop.photoMap['butter']!).readAsBytesSync());
        }
        if(File(shop.photoMap['water']!).existsSync()){
          socket.write(';water=');
          socket.write(File(shop.photoMap['water']!).readAsBytesSync());
        }
        if(File(shop.photoMap['juice']!).existsSync()){
          socket.write(';juice=');
          socket.write(File(shop.photoMap['juice']!).readAsBytesSync());
        }
        if(File(shop.photoMap['gazirovka']!).existsSync()){
          socket.write(';gazirovka=');
          socket.write(File(shop.photoMap['gazirovka']!).readAsBytesSync());
        }
        if(File(shop.photoMap['candyVes']!).existsSync()){
          socket.write(';candyVes=');
          socket.write(File(shop.photoMap['candyVes']!).readAsBytesSync());
        }
        if(File(shop.photoMap['chocolate']!).existsSync()){
          socket.write(';chocolate=');
          socket.write(File(shop.photoMap['chocolate']!).readAsBytesSync());
        }
        if(File(shop.photoMap['korobkaCandy']!).existsSync()){
          socket.write(';korobkaCandy=');
          socket.write(File(shop.photoMap['korobkaCandy']!).readAsBytesSync());
        }
        if(File(shop.photoMap['pirogi']!).existsSync()){
          socket.write(';pirogi=');
          socket.write(File(shop.photoMap['pirogi']!).readAsBytesSync());
        }
        if(File(shop.photoMap['tea']!).existsSync()){
          socket.write(';tea=');
          socket.write(File(shop.photoMap['tea']!).readAsBytesSync());
        }
        if(File(shop.photoMap['coffee']!).existsSync()){
          socket.write(';coffee=');
          socket.write(File(shop.photoMap['coffee']!).readAsBytesSync());
        }
        if(File(shop.photoMap['macarons']!).existsSync()){
          socket.write(';macarons=');
          socket.write(File(shop.photoMap['macarons']!).readAsBytesSync());
        }
        if(File(shop.photoMap['meatKonserv']!).existsSync()){
          socket.write(';meatKonserv=');
          socket.write(File(shop.photoMap['meatKonserv']!).readAsBytesSync());
        }
        if(File(shop.photoMap['fishKonserv']!).existsSync()){
          socket.write(';fishKonserv=');
          socket.write(File(shop.photoMap['fishKonserv']!).readAsBytesSync());
        }
        if(File(shop.photoMap['fruitKonserv']!).existsSync()){
          socket.write(';fruitKonserv=');
          socket.write(File(shop.photoMap['fruitKonserv']!).readAsBytesSync());
        }
        if(File(shop.photoMap['milkKonserv']!).existsSync()){
          socket.write(';milkKonserv=');
          socket.write(File(shop.photoMap['milkKonserv']!).readAsBytesSync());
        }
        socket.write('\x17');
        await socket.flush();
      }catch(e){
        print('Oh no!Error with send PHOTOS AND NEW SHOP');
      }
    }
    socket.close();
  }

  void checkLostReports() async
  {
    var list = sqlFliteDB.getNonHasReport();
    if(list.isEmpty){
      return;
    }
    Future.delayed(const Duration(seconds: 30), () {
      globalHandler.isResendReports.value = false;
      sqlFliteDB.setUnsend();
    });
    globalHandler.isResendReports.value = true;
    for(int i=0;i<list.length;i++){
      _sendMessage(text:'checkShop?userId=${list[i].userId};extId=${list[i].id};extMillisecs=${list[i].millisecsSinceEpoch~/1000}',reload:true);
    }
  }

  void _catchCheckShops(String text) async
  {
    var answer = text.split('\r');
    if (answer.length < 3) {
      return;
    }
    var categories = answer[1].split(';');
    List<int> hasReports = [];
    for (int i = 2; i < answer.length; i++) {
      var temp = answer[i].split(';');
      if (categories.contains('ext_id')) {
        hasReports.add(int.tryParse(temp[categories.indexOf('ext_id')]) ?? 0);
      }
    }
    sqlFliteDB.setSuccessShop(hasReports);
  }

  void deleteShop(InternalShop  shop)
  {
    _sendMessage(text:'setDisableShop?userId=${shop.userId};extId=${shop.id};extMillisecs=${shop.millisecsSinceEpoch~/1000}',reload:true);
  }

  void getConfigMeterShop()
  {
    _sendMessage(text:'getConfig?key=meterPhoto',reload:false);
  }

  // void sendReport(List<String> files, String text, int shopId, {int extId=0})
  // {
  //   _createDbDump(files, text, shopId).then((value){
  //     getLastRawInt().then((value){
  //       extId = value;
  //       _socket.write('id=10;reload=true;addReport?report=$text;${extId == 0 ? '' : 'extId=$extId;'}shopId=$shopId;userId=$globalUserId');
  //       for(int i=0;i<files.length;i++){
  //         if(i == 0) {
  //           _socket.write(';photoPaths=');
  //         }
  //         File(files[i]).existsSync() ?  _socket.write(File(files[i]).readAsBytesSync()) : null;
  //       }
  //       _socket.write('\x17');
  //     });
  //   });
  // }

  // void _catchCheckReport(String text) async
  // {
  //   var answer = text.split('\r');
  //   if (answer.length < 3) {
  //     return;
  //   }
  //   Map<int,String> rawResFromExternalDb = {};
  //   var categories = answer[1].split(';');
  //   for (int i=2; i<answer.length; i++) {
  //     var temp = answer[i].split(';');
  //     int id = 0;
  //     if(categories.contains('sqlite_ext_id')){
  //       id = int.parse(temp[categories.indexOf('sqlite_ext_id')]);
  //     }
  //     if(categories.contains('photo_path')){
  //       rawResFromExternalDb[id] = temp[categories.indexOf('photo_path')];
  //     }else{
  //       rawResFromExternalDb[id] = '';
  //     }
  //   }
  //   var res = await _database?.rawQuery('SELECT id,photo_path FROM report ORDER BY id');
  //   if(res == null){
  //     return;
  //   }
  //   for(final raw in res){
  //     if(rawResFromExternalDb.containsKey(raw['id'])){
  //       int externalComas = rawResFromExternalDb[raw['id']]!.split(',').length;
  //       String text = raw['photo_path'] as String;
  //       int internalComas = text.split(',').length;
  //       if(externalComas == internalComas){
  //         await _database?.execute('DELETE FROM report WHERE id=${raw['id']}');
  //       }
  //     }
  //   }
  // }





  void _catchBuild(String text) async
  {
    var answer = text.split('\r');
    if (answer.length < 3) {
      return;
    }
    var categories = answer[1].split(';');
    for (int i = 2; i < answer.length; i++) {
      var temp = answer[i].split(';');
      if(categories.contains('build')){
        if(int.parse(temp[categories.indexOf('build')]) > versionApk){
          await _updateApp?.call();
          return;
        }
      }
      break;
    }
  }

  void _catchAccess(String text)
  {
    var answer = text.split('\r');
    if (answer.length < 3) {
      isLoginFunc?.call(false);
      return;
    }
    var categories = answer[1].split(';');
    bool isLogged = false;
    for (int i=2; i<answer.length; i++) {
      var temp = answer[i].split(';');
      if(categories.contains('id')){
        int userId = int.parse(temp[categories.indexOf('id')]);
        globalHandler.userId = userId;
        isLogged = true;
      }
      break;
    }
    isLoginFunc?.call(isLogged);
  }

  void loadShops(bool reload)
  {
    _sendMessage(text: 'loadShops?id=${globalHandler.userId}', reload: reload);
  }

  void updateCurrentAim(String shopId)
  {
    _sendMessage(text: 'updateCurrentAim?shopId=$shopId;userId=${globalHandler.userId}', reload: true);
  }

  Future<void> _sendMessage({required String text, bool reload=false, int? id}) async
  {
    String question = 'id=${id ?? _getId()};';
    if(reload){
      question += 'reload=true;';
    }
    question += '$text\x17';
    _socket.write(question);
  }

  void checkAccess(String name, String password)
  {
    _sendMessage(text: 'login?login=$name;pwd=$password', reload: true);
  }

// void _getShopPoints(String text) async
// {
//   pointFromDbHandler.pointsFromDb.value.clear();
//   var answer = text.split('\r');
//   if (answer.length < 3) {
//     return;
//   }
//   var categories = answer[1].split(';');
//   for (int i=2; i<answer.length; i++) {
//     PointFromDb point = PointFromDb();
//     var currsAnswer = answer[i].split(';');
//     try {
//       if (categories.contains('x')) {
//         point.x = double.parse(currsAnswer[categories.indexOf('x')]);
//       }
//       if (categories.contains('y')) {
//         point.y = double.parse(currsAnswer[categories.indexOf('y')]);
//       }
//       if (categories.contains('name')) {
//         point.name = currsAnswer[categories.indexOf('name')];
//       }
//       if (categories.contains('description')) {
//         point.description = currsAnswer[categories.indexOf('description')];
//       }
//       if (categories.contains('start_work_time')) {
//         point.startWorkingTime =
//         currsAnswer[categories.indexOf('start_work_time')];
//       }
//       if (categories.contains('finish_work_time')) {
//         point.endWorkingTime =
//         currsAnswer[categories.indexOf('finish_work_time')];
//       }
//       if (categories.contains('date_time_created')) {
//         point.dateTimeCreated = DateTime.tryParse(
//             currsAnswer[categories.indexOf('date_time_created')]) ??
//             DateTime.now();
//       }
//       if (categories.contains('has_report')) {
//         point.isWasReport =
//             currsAnswer[categories.indexOf('has_report')] == 't';
//       }
//       if (categories.contains('id')) {
//         point.id = int.parse(currsAnswer[categories.indexOf('id')]);
//       }
//       if (categories.contains('address')) {
//         point.address = currsAnswer[categories.indexOf('address')];
//       }
//       pointFromDbHandler.pointsFromDb.value.putIfAbsent(
//           point.id, () => point);
//     }catch (e){
//       print('error with this shopId: ${point.id}');
//     }
//   }
//   pointFromDbHandler.pointsFromDb.notifyListeners();
// }
}