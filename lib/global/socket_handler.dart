

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:shop_audit/component/location_global.dart';
import 'package:shop_audit/global/shop_points_for_job.dart';
import 'package:shop_audit/main.dart';
import 'package:sqflite/sqflite.dart';

enum SocketState
{
  notInitialize,
  connected,
  disconnected
}

class SocketHandler
{
  static final SocketHandler _socketHandler = SocketHandler._internal();
  factory SocketHandler() {
    return _socketHandler;
  }
  SocketHandler._internal();
  late Socket _socket;
  String _buffer = '';
  bool isLoad = false;
  DateTime? _lastAimUpdate;
  bool isLoading = true;
  ValueNotifier<SocketState> socketState = ValueNotifier(SocketState.notInitialize);
  Database? _database;
  int _id = 0;

  Function(bool isLogged)? isLoginFunc;
  Function()? _updateApp;

  int _getId()
  {
    return _id++;
  }

  Future<void> init() async
  {
    if(_database == null){
      openDb();
    }
    try {
      isLoading = false;
      _socket = await Socket.connect('195.38.167.138', 9891);
      // _socket = await Socket.connect('192.168.56.1', 9891);
      _socket.listen(_dataRecive,
          onDone: () {
            print('onDone');
            if(!isLoading){
              socketState.value = SocketState.disconnected;
              isLoading = true;
              Future.delayed(const Duration(seconds: 1),init);
            }
          },
          onError: (error) {
            print('onError');
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
  //(int@userId,real@xCoord,real@yCoord,text@name,text@description,time without time zone@startHours,time without time zone@finishHours) AS INSERT INTO shop_audit_clear.shop(user_id,x,y,name,description,start_work_time,finish_work_time) VALUES  (@userId,@xCoord,@yCoord,@name,@description,@startHours,@finishHours)
  void addShop(String name, String desc)
  {
    var temp = LocationHandler().currentLocation;
    _sendMessage(text: 'newShop?userId=$globalUserId;description=$desc;name=$name;xCoord=${temp.latitude};yCoord=${temp.longitude}',reload:true);
  }

  void getCurrentBuild(Function() update)
  {
    print('send get BUILD');
    _updateApp = update;
    _sendMessage(text:'getCurrentBuild?version=$versionApk',reload:false);
  }

  void sendMyPosition(double xCoord,double yCoord)
  {
    _sendMessage(text:'setCurrPosition?auditorId=$globalUserId;xCoord=$xCoord;yCoord=$yCoord',reload:true);
  }

  void openDb() async
  {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'reports.db');
    _database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version)async {
      await db.execute('CREATE TABLE report (id INTEGER PRIMARY KEY autoincrement NOT NULL,photo_path TEXT, report_text TEXT, shop_id INTEGER NOT NULL,'
          'user_id INTEGER NOT NULL, millisecs_since_epoch INTEGER NOT NULL)');
    });
  }

  Future _createDbDump(List<String> files, String text, int shopId) async
  {
    await _database?.execute('INSERT INTO report(photo_path, report_text, shop_id, user_id, millisecs_since_epoch) VALUES '
        '("${files.join(',')}", "$text", $shopId, $globalUserId, ${DateTime.now().millisecondsSinceEpoch})');
  }

  Future<int> getLastRawInt() async
  {
    var res = await _database?.rawQuery('SELECT id FROM report ORDER BY id DESC LIMIT 1');
    if(res != null){
        return res[0]['id']! as int;
    }
    return 0;
  }

  void checkLostReports() async
  {
    var res = await _database?.rawQuery('SELECT * FROM report ORDER BY id');
    if(res != null){
      for(final raw in res){
        _sendMessage(text:'checkReport?extId=${raw['id']};userId=${raw['user_id']};shopId=${raw['shop_id']}',reload:true);
      }
    }
    Future.delayed(const Duration(minutes: 2),_reSendReports);
  }

  void sendReport(List<String> files, String text, int shopId, {bool needCache = true, int extId=0})
  {
    int ext = extId;
    if(needCache){
      _createDbDump(files, text, shopId).then((value){
        getLastRawInt().then((value){
          ext = value;
          print('current id in sqlite = $ext');
          _socket.write('id=10;reload=true;addReport?report=$text;${ext == 0 ? '' : 'extId=$ext;'}shopId=$shopId;userId=$globalUserId');
          for(int i=0;i<files.length;i++){
            if(i == 0) {
              _socket.write(';photoPaths=');
            }
            _socket.write(File(files[i]).readAsBytesSync());
          }
          _socket.write('\x17');
        });
      });
    }else{
      _socket.write('id=10;reload=true;addReport?report=$text;${ext == 0 ? '' : 'extId=$ext;'}shopId=$shopId;userId=$globalUserId');
      for(int i=0;i<files.length;i++){
        if(i == 0) {
          _socket.write(';photoPaths=');
        }
        _socket.write(File(files[i]).readAsBytesSync());
      }
      _socket.write('\x17');
    }
  }

  void _dataRecive(data) async{
    _buffer += utf8.decode(data);
    if (_buffer.contains('\x17')) {
      var answer = _buffer.split('\x17');
      for (int i = 0; i < answer.length; i++) {
        _answersHub(answer[i]);
      }
      _buffer = answer[answer.length - 1];
    }
  }

  void _catchCheckReport(String text) async
  {
    var answer = text.split('\r');
    if (answer.length < 3) {
      return;
    }
    var categories = answer[1].split(';');
    for (int i=2; i<answer.length; i++) {
      var temp = answer[i].split(';');
      if(categories.contains('sqlite_ext_id')){
        int id = int.parse(temp[categories.indexOf('sqlite_ext_id')]);
        await _database?.execute('DELETE FROM report WHERE id=$id');
      }
    }
  }

  void _reSendReports() async
  {
    var res = await _database?.rawQuery('SELECT * FROM report ORDER BY id');
    if(res != null) {
      for (final raw in res) {
        DateTime dtime = DateTime.fromMillisecondsSinceEpoch(raw['millisecs_since_epoch'] as int);
        if(dtime.difference(DateTime.now()).inMinutes.abs() > 5) {
          List<String> files = [];
          String? text = raw['photo_path'] as String?;
          if(text != null && text != ''){
            files = text.split(',');
          }
          sendReport(files, raw['report_text'] as String,
              raw['shop_id'] as int, needCache: false, extId: raw['id'] as int);
        }
      }
    }
  }

  void _answersHub(String text)
  {
    if(text.contains('checkReport')){
      _catchCheckReport(text);
    }
    if(text.contains('loadShops') || text.contains('10shops')){
      _getShopPoints(text);
      return;
    }
    if(text.contains('login')){
      _catchAccess(text);
      return;
    }
    if(text.contains('shopAims')){
      _catchAims(text);
      return;
    }
    if(text.contains('getCurrentBuild')){
      _catchBuild(text);
      return;
    }
  }

  void _catchBuild(String text)
  {
    print('catch get BUILD');
    var answer = text.split('\r');
    if (answer.length < 3) {
      return;
    }
    var categories = answer[1].split(';');
    for (int i = 2; i < answer.length; i++) {
      var temp = answer[i].split(';');
      if(categories.contains('build')){
        if(int.parse(temp[categories.indexOf('build')]) > versionApk){
          _updateApp?.call();
          return;
        }
      }
      break;
    }
  }

  void _catchAims(String text) {
    var answer = text.split('\r');
    Map<int,int> activeShops = {};
    if (answer.length < 3) {
      return;
    }
    var categories = answer[1].split(';');
    bool isDate = false;
    for (int i = 2; i < answer.length; i++) {
      var temp = answer[i].split(';');
      int userId=0, shopId=0;
      if (categories.contains('user_id')) {
        userId = int.parse(temp[categories.indexOf('user_id')]);
      }
      if (categories.contains('current_shop_aim')) {
        shopId = int.parse(temp[categories.indexOf('current_shop_aim')]);
      }
      if (categories.contains('date_time_updated') && !isDate) {
        isDate = true;
        _lastAimUpdate =
            DateTime.parse(temp[categories.indexOf('date_time_updated')]);
      }
      activeShops.putIfAbsent(userId, () => shopId);
    }
    for(var key in activeShops.keys){
      PointFromDbHandler().userActivePoints.value[key] = activeShops[key]!;
    }
    PointFromDbHandler().userActivePoints.notifyListeners();
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
        globalUserId = userId;
        isLogged = true;
      }
      break;
    }
    isLoginFunc?.call(isLogged);
  }

  void loadShops(bool reload)
  {
    _sendMessage(text: 'loadShops?id=$globalUserId', reload: reload);
  }

  void updateCurrentAim(String shopId)
  {
    _sendMessage(text: 'updateCurrentAim?shopId=$shopId;userId=$globalUserId', reload: true);
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

  void getAims(bool reload)
  {
    if(_lastAimUpdate == null) {
      _sendMessage(text: 'shopAims', reload: reload);
    }else{
      _sendMessage(text: 'shopAimsByDate?dateTime=${presentDateTime(_lastAimUpdate!,seconds: true)}', reload: reload);
    }
  }

  void _getShopPoints(String text) async
  {
    PointFromDbHandler().pointsFromDb.value.clear();
    var answer = text.split('\r');
    if (answer.length < 3) {
      return;
    }
    var categories = answer[1].split(';');
    for (int i=2; i<answer.length; i++) {
      PointFromDb point = PointFromDb();
      var currsAnswer = answer[i].split(';');
      try {
        if (categories.contains('x')) {
          point.x = double.parse(currsAnswer[categories.indexOf('x')]);
        }
        if (categories.contains('y')) {
          point.y = double.parse(currsAnswer[categories.indexOf('y')]);
        }
        if (categories.contains('name')) {
          point.name = currsAnswer[categories.indexOf('name')];
        }
        if (categories.contains('description')) {
          point.description = currsAnswer[categories.indexOf('description')];
        }
        if (categories.contains('start_work_time')) {
          point.startWorkingTime =
          currsAnswer[categories.indexOf('start_work_time')];
        }
        if (categories.contains('finish_work_time')) {
          point.endWorkingTime =
          currsAnswer[categories.indexOf('finish_work_time')];
        }
        if (categories.contains('date_time_created')) {
          point.dateTimeCreated = DateTime.tryParse(
              currsAnswer[categories.indexOf('date_time_created')]) ??
              DateTime.now();
        }
        if (categories.contains('has_report')) {
          point.isWasReport =
              currsAnswer[categories.indexOf('has_report')] == 't';
        }
        if (categories.contains('id')) {
          point.id = int.parse(currsAnswer[categories.indexOf('id')]);
        }
        if (categories.contains('address')) {
          point.address = currsAnswer[categories.indexOf('address')];
        }
        PointFromDbHandler().pointsFromDb.value.putIfAbsent(
            point.id, () => point);
      }catch (e){
        print('error with this shopId: ${point.id}');
      }
    }
    PointFromDbHandler().pointsFromDb.notifyListeners();
  }
}