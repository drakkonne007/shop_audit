

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shop_audit/global/shop_points_for_job.dart';
import 'package:shop_audit/main.dart';

Uint8List _imgsDecode(String file)
{
  var bytes = File(file).readAsBytesSync();
  return bytes;
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
  int countOfReconnect = 0;

  Function(bool isLogged)? isLoginFunc;
  Future<void> init() async
  {
    try {
      _socket = await Socket.connect('192.168.0.104', 9891);
      _socket.listen(_dataRecive,
          onDone: () {countOfReconnect = 0;},
          onError: (error) {
            if(countOfReconnect < 30){
              init();
            }
          },
          cancelOnError: false);
      _socket.write('auditor:12345\x17');
      isLoad = true;
    }catch (e){
      isLoad = false;
    }
  }



  Future<void> sendReport(List<String> files, String text, int shopId) async
  {
    _socket.write('id=10;reload=true;addReport?report=$text;shopId=$shopId;userId=${mainShared?.getInt('userId')}');
    PointFromDbHandler().activeShop = 0;
    for(int i=0;i<files.length;i++){
      if(i == 0) {
        _socket.write(';photoPaths=');
      }
      _socket.write(await compute(_imgsDecode, files[i]));
    }
    print('end parse imgs');
    _socket.write('\x17');
    // _sendMessageByte(text: temp,reload: true);
  }

void _dataRecive(data){
  _buffer += utf8.decode(data);
  if (_buffer.contains('\x17')) {
    var answer = _buffer.split('\x17');
    for (int i = 0; i < answer.length; i++) {
      _answersHub(answer[i]);
    }
    _buffer = answer[answer.length - 1];
  }
}

void _answersHub(String text)
{
  if(text.contains('loadShops')){
    _getShopPoints(text);
    return;
  }
  if(text.contains('login')){
    _catchAccess(text);
    return;
  }
  if(text.contains('shopAims')){
    _catchAims(text);
  }
}

void _catchAims(String text) {
  var answer = text.split('\r');
  Map<int,int> activeShops = {};
  if (answer.length < 3) {
    isLoginFunc?.call(false);
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
      mainShared?.setInt('userId', userId);
      isLogged = true;
    }
    break;
  }
  isLoginFunc?.call(isLogged);
}

void loadShops(bool reload)
{
  _sendMessage(text: 'loadShops', reload: reload);
}

void updateCurrentAim(String shopId)
{
  _sendMessage(text: 'updateCurrentAim?shopId=$shopId;userId=${mainShared?.getInt('userId')}', reload: true);
}

Future<void> _sendMessage({required String text, bool reload=false}) async
{
  String question = 'id=10;';
  if(reload){
    question += 'reload=true;';
  }
  question += text + '\x17';
  _socket.write(question);
}

  void _sendMessageByte({required List<int> text, bool reload=false})
  {
    var question = utf8.encode('id=10;');
    if(reload){
      question += utf8.encode('reload=true;');
    }
    question += text;
    _socket.write(question);
    _socket.write('\x17');
  }

void checkAccess(String name, String password)
{
  _sendMessage(text: 'login?login=$name;pwd=$password', reload: true);
}

void getAims(bool reload)
{
  // if(_lastAimUpdate == null) {
  //   _sendMessage(text: 'shopAims', reload: reload);
  // }else{
  //   _sendMessage(text: 'shopAimsByDate?dateTime=${presentDateTime(_lastAimUpdate!,seconds: true)}', reload: reload);
  // }
}

void _getShopPoints(String text) async
{
  var answer = text.split('\r');
  if (answer.length < 3) {
    return;
  }
  var categories = answer[1].split(';');
  for (int i=2; i<answer.length; i++) {
    PointFromDb point = PointFromDb();
    var currsAnswer = answer[i].split(';');
    if(categories.contains('x')){
      point.x = double.parse(currsAnswer[categories.indexOf('x')]);
    }
    if(categories.contains('y')){
      point.y = double.parse(currsAnswer[categories.indexOf('y')]);
    }
    if(categories.contains('name')){
      point.name = currsAnswer[categories.indexOf('name')];
    }
    if(categories.contains('description')){
      point.description = currsAnswer[categories.indexOf('description')];
    }
    if(categories.contains('start_work_time')){
      point.startWorkingTime = currsAnswer[categories.indexOf('start_work_time')];
    }
    if(categories.contains('finish_work_time')){
      point.endWorkingTime = currsAnswer[categories.indexOf('finish_work_time')];
    }
    if(categories.contains('date_time_created')){
      point.dateTimeCreated = DateTime.tryParse(currsAnswer[categories.indexOf('date_time_created')]) ?? DateTime.now();
    }
    if(categories.contains('has_report')){
      point.isWasReport = currsAnswer[categories.indexOf('has_report')] == 't';
    }
    if(categories.contains('id')){
      point.id = int.parse(currsAnswer[categories.indexOf('id')]);
    }
    PointFromDbHandler().pointsFromDb.value.putIfAbsent(point.id, () => point);
  }
  PointFromDbHandler().pointsFromDb.notifyListeners();
}
}