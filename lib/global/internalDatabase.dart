import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path/path.dart';
import 'package:shop_audit/component/internal_shop.dart';
import 'package:shop_audit/main.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

enum SortType
{
  none,
  distance,
  dateTimeCreated,
}

const String newReport = 'CREATE TABLE IF NOT EXISTS report_shop '
    '(id INTEGER PRIMARY KEY NOT NULL'
    ',user_id INTEGER NOT NULL'
    ',report_photo TEXT'
    ',week_day INTEGER NOT NULL'
    ',folder_path TEXT'
    ',water TEXT'
    ',juice TEXT'
    ',gazirovka TEXT'
    ',candy_ves TEXT'
    ',chocolate TEXT'
    ',korobka_candy TEXT'
    ',pirogi TEXT'
    ',tea TEXT'
    ',coffee TEXT'
    ',macarons TEXT'
    ',meat_konserv TEXT'
    ',fish_konserv TEXT'
    ',fruit_konserv TEXT'
    ',milk_konserv TEXT'
    ',shop_name TEXT NOT NULL'
    ',shop_type TEXT'
    ',yuridic_form TEXT'
    ',has_report INTEGER NOT NULL DEFAULT 0'
    ',was_sending INTEGER NOT NULL DEFAULT 0'
    ',address TEXT'
    ',x REAL'
    ',y REAL'
    ',external_photo TEXT'
    ',shop_label_photo TEXT'
    ',alkohol_photo TEXT'
    ',kolbasa_syr TEXT'
    ',milk TEXT'
    ',snack TEXT'
    ',mylomoika TEXT'
    ',vegetables_fruits TEXT'
    ',cigarettes TEXT'
    ',kassovaya_zona TEXT'
    ',toys TEXT'
    ',butter TEXT'
    ',phone_number TEXT'
    ',shop_square_meter REAL'
    ',cass_count INTEGER'
    ',prodavec_manager_count INTEGER'
    ',halal INTEGER'
    ',paymanet_terminal INTEGER'
    ',empty_space TEXT'
    ',millisecs_since_epoch INTEGER DEFAULT 0);';

const String newShopSql = 'CREATE TABLE IF NOT EXISTS travel_shop '
    '(id INTEGER PRIMARY KEY autoincrement NOT NULL'
    ',user_id INTEGER NOT NULL'
    ',water TEXT'
    ',juice TEXT'
    ',gazirovka TEXT'
    ',candy_ves TEXT'
    ',chocolate TEXT'
    ',korobka_candy TEXT'
    ',pirogi TEXT'
    ',tea TEXT'
    ',coffee TEXT'
    ',macarons TEXT'
    ',meat_konserv TEXT'
    ',fish_konserv TEXT'
    ',fruit_konserv TEXT'
    ',milk_konserv TEXT'
    ',shop_name TEXT NOT NULL'
    ',shop_type TEXT'
    ',yuridic_form TEXT'
    ',has_report INTEGER NOT NULL DEFAULT 0'
    ',was_sending INTEGER NOT NULL DEFAULT 0'
    ',address TEXT'
    ',x REAL'
    ',y REAL'
    ',external_photo TEXT'
    ',shop_label_photo TEXT'
    ',alkohol_photo TEXT'
    ',kolbasa_syr TEXT'
    ',milk TEXT'
    ',snack TEXT'
    ',mylomoika TEXT'
    ',vegetables_fruits TEXT'
    ',cigarettes TEXT'
    ',kassovaya_zona TEXT'
    ',toys TEXT'
    ',butter TEXT'
    ',phone_number TEXT'
    ',shop_square_meter REAL'
    ',cass_count INTEGER'
    ',prodavec_manager_count INTEGER'
    ',halal INTEGER'
    ',paymanet_terminal INTEGER'
    ',empty_space TEXT'
    ',millisecs_since_epoch INTEGER NOT NULL);';

class SqlFliteDB
{
  Database? _database;
  Map<int, InternalShop> shops = {};
  Map<int,Map<int,InternalShop>> _tasksOnWeek = {};
  Map<int, InternalShop> filteredShops = {};
  int hasReportCount = 0;
  String _weekDay = '';
  ValueNotifier<int> shopList = ValueNotifier(0); //TODO ЭТО ЗАГЛУШКА ДЛЯ ОБНОВЛЕНИЯ КАРТЫ!!!

  void openDb() async
  {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'internalShops.db');
    _database = await openDatabase(path, version: 16,
        onCreate: (Database db, int v) async{
          await db.execute(newShopSql);
          await db.execute(newReport);
        }
        ,onUpgrade: (Database db, int oldVersion, int newVersion) async{
          await db.rawQuery('DROP TABLE IF EXISTS report_shop');
          await db.execute(newShopSql);
          await db.execute(newReport);
        });
    // await _database?.execute('DELETE FROM travel_shop');
    await getShops();
    await loadInternalReports();
    nonReportShops();
    // socketHandler.checkLostReports();
  }

  Future<void> loadInternalReports()async
  {
    var resReport = await _database?.rawQuery('SELECT * FROM report_shop ORDER BY id');
    if(resReport != null){
      final allList = _createShopsFromDB(resReport);
      for(final dd in allList.values){
        dd.isReport = true;
        _tasksOnWeek.putIfAbsent(dd.weekDay, ()=> {});
        _tasksOnWeek[dd.weekDay]![dd.id] = dd;
      }
    }
  }

  Future<void> getShops()async
  {
    var res = await _database?.rawQuery('SELECT * FROM travel_shop ORDER BY id');
    if(res != null){
      shops = _createShopsFromDB(res);
    }
  }

  void setReports(List<InternalShop> map)async
  {
    List<InternalShop> newShops = [];
    for(final shop in map){
      if(_tasksOnWeek[shop.weekDay] != null && _tasksOnWeek[shop.weekDay]!.containsKey(shop.id)){
        continue;
      }
      newShops.add(shop);
      _tasksOnWeek.putIfAbsent(shop.weekDay, ()=> {});
      _tasksOnWeek[shop.weekDay]![shop.id] = shop;
    }
    for(final val in newShops){
      await _database?.rawQuery('INSERT INTO report_shop(id, week_day,shop_name, user_id, folder_path) VALUES(?,?,?,?,?)', [val.id, val.weekDay
        , val.shopName, val.userId
      , val.folderPath]);
      updateShop(val, notify: false);
    }
    shopList.notifyListeners();
  }

  Map<int,InternalShop>  getDaysMap()
  {
    switch(_weekDay){
      case 'Понедельник': return _tasksOnWeek[1] ?? {};
      case 'Вторник': return _tasksOnWeek[2] ?? {};
      case 'Среда': return _tasksOnWeek[3] ?? {};
      case 'Четверг': return _tasksOnWeek[4] ?? {};
      case 'Пятница': return _tasksOnWeek[5] ?? {};
      case 'Суббота': return _tasksOnWeek[6] ?? {};
      case 'Воскресенье': return _tasksOnWeek[7] ?? {};
      default: return {};
    }
  }

  List<InternalShop> getDayList(String weekDay)
  {
    _weekDay = weekDay;
    switch(weekDay){
      case 'Понедельник': return _tasksOnWeek[1]?.values.toList(growable: false) ?? [];
      case 'Понедельник': return _tasksOnWeek[1]?.values.toList(growable: false) ?? [];
      case 'Вторник': return _tasksOnWeek[2]?.values.toList(growable: false) ?? [];
      case 'Среда': return _tasksOnWeek[3]?.values.toList(growable: false) ?? [];
      case 'Четверг': return _tasksOnWeek[4]?.values.toList(growable: false) ?? [];
      case 'Пятница': return _tasksOnWeek[5]?.values.toList(growable: false) ?? [];
      case 'Суббота': return _tasksOnWeek[6]?.values.toList(growable: false) ?? [];
      case 'Воскресенье': return _tasksOnWeek[7]?.values.toList(growable: false) ?? [];
      default: return [];
    }
  }

  // Future<void>

  Future nonReportShops() async
  {
    var res = await _database?.rawQuery('SELECT COUNT(*) as count FROM travel_shop WHERE has_report = true');
    if (res == null) {
      return;
    }
    hasReportCount = res[0]['count'] as int;
  }

  Map<int, InternalShop> _createShopsFromDB(List<Map<String,Object?>> res)
  {
    Map<int, InternalShop>  temp = {};
    for (final raw in res) {
      InternalShop shop = InternalShop(raw['id'] as int);
      shop.userId = raw['user_id'] as int;
      shop.shopName = raw['shop_name'].toString();
      shop.address = raw['address']== null ? '' : raw['address'].toString();
      shop.xCoord = raw['x'] == null ? 0 : raw['x'] as double;
      shop.yCoord = raw['y'] == null ? 0 : raw['y'] as double;
      shop.photoMap['externalPhoto'] = raw['external_photo'] == null ? '' : raw['external_photo'].toString();
      shop.photoMap['shopLabelPhoto'] = raw['shop_label_photo'] == null ? '' : raw['shop_label_photo'].toString();
      shop.photoMap['alkoholPhoto'] = raw['alkohol_photo'] == null ? '' : raw['alkohol_photo'].toString();
      shop.photoMap['kolbasaSyr'] = raw['kolbasa_syr'] == null ? '' : raw['kolbasa_syr'].toString();
      shop.photoMap['milk'] = raw['milk'] == null ? '' : raw['milk'].toString();
      shop.photoMap['snack'] = raw['snack'] == null ? '' : raw['snack'].toString();
      shop.photoMap['mylomoika'] = raw['mylomoika'] == null ? '' : raw['mylomoika'].toString();
      shop.photoMap['vegetablesFruits'] = raw['vegetables_fruits'] == null ? '' : raw['vegetables_fruits'].toString();
      shop.photoMap['cigarettes'] = raw['cigarettes'] == null ? '' : raw['cigarettes'].toString();
      shop.photoMap['kassovayaZona'] = raw['kassovaya_zona'] == null ? '' : raw['kassovaya_zona'].toString();
      shop.photoMap['toys'] = raw['toys'] == null ? '' : raw['toys'].toString();
      shop.photoMap['butter'] = raw['butter'] == null ? '' : raw['butter'].toString();
      shop.phoneNumber = raw['phone_number'] == null ? '' : raw['phone_number'].toString();
      shop.shopSquareMeter = raw['shop_square_meter'] == null ? 0 : raw['shop_square_meter'] as double;
      shop.hasReport = raw['has_report'] == null ? false : raw['has_report'] as int == 1;
      shop.isSending = raw['was_sending'] == null ? false : raw['was_sending'] as int == 1;
      shop.millisecsSinceEpoch = raw['millisecs_since_epoch'] == null ? 0 : raw['millisecs_since_epoch'] as int;
      shop.shopType = raw['shop_type'] == null ? ShopType.none : ShopType.values.byName(raw['shop_type'].toString());
      shop.cassCount = raw['cass_count'] == null ? 0 : raw['cass_count'] as int;
      shop.prodavecManagerCount = raw['prodavec_manager_count'] == null ? 0 : raw['prodavec_manager_count'] as int;
      shop.halal = raw['halal'] == null ? false : raw['halal'] as int == 1;
      shop.paymentTerminal = raw['paymanet_terminal'] == null ? 0 : raw['paymanet_terminal'] as int;
      shop.emptySpace = raw['empty_space'] == null ? EmptySpace.few : EmptySpace.values.byName(raw['empty_space'].toString());
      shop.yuridicForm = raw['yuridic_form'] == null ? YuridicForm.none : YuridicForm.values.byName(raw['yuridic_form'].toString());
      shop.millisecsSinceEpoch = raw['millisecs_since_epoch'] as int;
      shop.photoMap['water'] = raw['water'] == null ? '' : raw['water'].toString();
      shop.photoMap['juice'] = raw['juice'] == null ? '' : raw['juice'].toString();
      shop.photoMap['gazirovka'] = raw['gazirovka'] == null ? '' : raw['gazirovka'].toString();
      shop.photoMap['candyVes'] = raw['candy_ves'] == null ? '' : raw['candy_ves'].toString();
      shop.photoMap['chocolate'] = raw['chocolate'] == null ? '' : raw['chocolate'].toString();
      shop.photoMap['korobkaCandy'] = raw['korobka_candy'] == null ? '' : raw['korobka_candy'].toString();
      shop.photoMap['pirogi'] = raw['pirogi'] == null ? '' : raw['pirogi'].toString();
      shop.photoMap['tea'] = raw['tea'] == null ? '' : raw['tea'].toString();
      shop.photoMap['coffee'] = raw['coffee'] == null ? '' : raw['coffee'].toString();
      shop.photoMap['macarons'] = raw['macarons'] == null ? '' : raw['macarons'].toString();
      shop.photoMap['meatKonserv'] = raw['meat_konserv'] == null ? '' : raw['meat_konserv'].toString();
      shop.photoMap['fishKonserv'] = raw['fish_konserv'] == null ? '' : raw['fish_konserv'].toString();
      shop.photoMap['fruitKonserv'] = raw['fruit_konserv'] == null ? '' : raw['fruit_konserv'].toString();
      shop.photoMap['milkKonserv'] = raw['milk_konserv'] == null ? '' : raw['milk_konserv'].toString();
      shop.weekDay = raw['week_day'] == null ? 0 : raw['week_day'] as int;
      shop.reportPhoto = raw['report_photo'] == null ? '' : raw['report_photo'].toString();
      shop.folderPath = raw['folder_path'] == null ? '' : raw['folder_path'].toString();
      temp[shop.id] = shop;
    }
    return temp;
  }

  Future<int> addShop(String shopName, ShopType shopType) async
  {
    int? dd = await _database?.rawInsert('INSERT INTO travel_shop(user_id, shop_name, millisecs_since_epoch, shop_type,x,y) VALUES '
        '(${globalHandler.userId},"$shopName", ${DateTime.now().millisecondsSinceEpoch}, "${shopType.name}", ${globalHandler.currentUserPoint.latitude}, ${globalHandler.currentUserPoint.longitude})');
    if(dd == null || dd == 0){
      throw 'ERROR IN INTERNAL DB!!!';
    };
    await getShops();
    await nonReportShops();
    shopList.notifyListeners();
    return dd;
  }

  void setReportPhoto(int shopId, String path)
  {
    var newShop = getDaysMap()[shopId];
    if(newShop == null){
      return;
    }
    if(newShop.reportPhoto != '' && File(newShop.reportPhoto).existsSync() && !newShop.reportPhoto.contains('greenGalk')){
      File(newShop.reportPhoto).deleteSync();
    }
    newShop.reportPhoto = path;
    updateShop(newShop);
  }

  void setPhoto(InternalShop newShop, PhotoType type, String path)
  {
    if(newShop.photoMap.containsKey(type.name)) {
      if(File(newShop.photoMap[type.name]!).existsSync() && !newShop.photoMap[type.name]!.contains('greenGalk')){
        File(newShop.photoMap[type.name]!).deleteSync();
      }
      if(path == 'yes'){
        newShop.photoMap[type.name] = mainShared?.getString('greenGalk') ?? '';
      }else {
        newShop.photoMap[type.name] = path;
      }
      updateShop(newShop);
    }
  }

  void updateShop(InternalShop newShop, {bool notify = true})
  {
    _database?.rawUpdate(''
        'UPDATE ${newShop.isReport ? 'report_shop' : 'travel_shop'} SET '
        'shop_name = "${newShop.shopName}", '
        'x = ${newShop.xCoord}, '
        'y = ${newShop.yCoord}, '
        'external_photo = "${newShop.photoMap['externalPhoto']}", '
        'shop_label_photo = "${newShop.photoMap['shopLabelPhoto']}", '
        'water = "${newShop.photoMap['water']}",'
        'juice = "${newShop.photoMap['juice']}", '
        'gazirovka = "${newShop.photoMap['gazirovka']}", '
        'candy_ves = "${newShop.photoMap['candyVes']}", '
        'chocolate = "${newShop.photoMap['chocolate']}", '
        'korobka_candy = "${newShop.photoMap['korobkaCandy']}", '
        'pirogi = "${newShop.photoMap['pirogi']}", '
        'tea = "${newShop.photoMap['tea']}", '
        'coffee = "${newShop.photoMap['coffee']}", '
        'macarons = "${newShop.photoMap['macarons']}", '
        'meat_konserv = "${newShop.photoMap['meatKonserv']}", '
        'fish_konserv = "${newShop.photoMap['fishKonserv']}", '
        'fruit_konserv = "${newShop.photoMap['fruitKonserv']}", '
        'milk_konserv = "${newShop.photoMap['milkKonserv']}", '
        'alkohol_photo = "${newShop.photoMap['alkoholPhoto']}", '
        'kolbasa_syr = "${newShop.photoMap['kolbasaSyr']}", '
        'milk = "${newShop.photoMap['milk']}", '
        'snack = "${newShop.photoMap['snack']}", '
        'mylomoika = "${newShop.photoMap['mylomoika']}", '
        'vegetables_fruits = "${newShop.photoMap['vegetablesFruits']}", '
        'cigarettes = "${newShop.photoMap['cigarettes']}", '
        'kassovaya_zona = "${newShop.photoMap['kassovayaZona']}", '
        'toys = "${newShop.photoMap['toys']}", '
        'butter = "${newShop.photoMap['butter']}", '
        'phone_number = "${newShop.phoneNumber}", '
        'shop_square_meter = ${newShop.shopSquareMeter}, '
        'yuridic_form = "${newShop.yuridicForm.name}", '
        'cass_count = ${newShop.cassCount}, '
        'prodavec_manager_count = ${newShop.prodavecManagerCount}, '
        'halal = ${newShop.halal ? 1 : 0},'
        'has_report = false, '
        'was_sending = false, '
        'paymanet_terminal = ${newShop.paymentTerminal},'
        'shop_type = "${newShop.shopType.name}", '
        'empty_space = "${newShop.emptySpace.name}",'
        'address = "${newShop.address}"'
        'WHERE id = ${newShop.id}');
    newShop.hasReport = false;
    newShop.isSending = false;
    if(newShop.isReport){
      _database?.rawUpdate('UPDATE report_shop SET report_photo = "${newShop.reportPhoto}" WHERE id = ${newShop.id}');
      getDaysMap()[newShop.id] = newShop;
    }else {
      shops[newShop.id] = newShop;
    }
    nonReportShops();
    if(notify) {
      shopList.notifyListeners();
    }
  }

  void deleteShop(int id)
  {
    _database?.execute('DELETE FROM travel_shop WHERE id = $id');
    if(shops.containsKey(id)) {
      socketHandler.deleteShop(shops[id]!);
      try {
        if (File(shops[id]!.photoMap['externalPhoto']!).existsSync()) {
          File(shops[id]!.photoMap['externalPhoto']!).deleteSync();
        }
        if (File(shops[id]!.photoMap['shopLabelPhoto']!).existsSync()) {
          File(shops[id]!.photoMap['shopLabelPhoto']!).deleteSync();
        }
        if (File(shops[id]!.photoMap['alkoholPhoto']!).existsSync()) {
          File(shops[id]!.photoMap['alkoholPhoto']!).deleteSync();
        }
        if (File(shops[id]!.photoMap['kolbasaSyr']!).existsSync()) {
          File(shops[id]!.photoMap['kolbasaSyr']!).deleteSync();
        }
        if (File(shops[id]!.photoMap['milk']!).existsSync()) {
          File(shops[id]!.photoMap['milk']!).deleteSync();
        }
        if (File(shops[id]!.photoMap['snack']!).existsSync()) {
          File(shops[id]!.photoMap['snack']!).deleteSync();
        }
        if (File(shops[id]!.photoMap['mylomoika']!).existsSync()) {
          File(shops[id]!.photoMap['mylomoika']!).deleteSync();
        }
        if (File(shops[id]!.photoMap['vegetablesFruits']!).existsSync()) {
          File(shops[id]!.photoMap['vegetablesFruits']!).deleteSync();
        }
        if (File(shops[id]!.photoMap['cigarettes']!).existsSync()) {
          File(shops[id]!.photoMap['cigarettes']!).deleteSync();
        }
        if (File(shops[id]!.photoMap['kassovayaZona']!).existsSync()) {
          File(shops[id]!.photoMap['kassovayaZona']!).deleteSync();
        }
        if (File(shops[id]!.photoMap['toys']!).existsSync()) {
          File(shops[id]!.photoMap['toys']!).deleteSync();
        }
        if (File(shops[id]!.photoMap['butter']!).existsSync()) {
          File(shops[id]!.photoMap['butter']!).deleteSync();
        }
        if (File(shops[id]!.photoMap['water']!).existsSync()) {
          File(shops[id]!.photoMap['water']!).deleteSync();
        }
        if (File(shops[id]!.photoMap['juice']!).existsSync()) {
          File(shops[id]!.photoMap['juice']!).deleteSync();
        }
        if (File(shops[id]!.photoMap['gazirovka']!).existsSync()) {
          File(shops[id]!.photoMap['gazirovka']!).deleteSync();
        }
        if (File(shops[id]!.photoMap['candyVes']!).existsSync()) {
          File(shops[id]!.photoMap['candyVes']!).deleteSync();
        }
        if (File(shops[id]!.photoMap['chocolate']!).existsSync()) {
          File(shops[id]!.photoMap['chocolate']!).deleteSync();
        }
        if (File(shops[id]!.photoMap['korobkaCandy']!).existsSync()) {
          File(shops[id]!.photoMap['korobkaCandy']!).deleteSync();
        }
        if (File(shops[id]!.photoMap['pirogi']!).existsSync()) {
          File(shops[id]!.photoMap['pirogi']!).deleteSync();
        }
        if (File(shops[id]!.photoMap['tea']!).existsSync()) {
          File(shops[id]!.photoMap['tea']!).deleteSync();
        }
        if (File(shops[id]!.photoMap['coffee']!).existsSync()) {
          File(shops[id]!.photoMap['coffee']!).deleteSync();
        }
        if (File(shops[id]!.photoMap['macarons']!).existsSync()) {
          File(shops[id]!.photoMap['macarons']!).deleteSync();
        }
        if (File(shops[id]!.photoMap['meatKonserv']!).existsSync()) {
          File(shops[id]!.photoMap['meatKonserv']!).deleteSync();
        }
        if (File(shops[id]!.photoMap['fishKonserv']!).existsSync()) {
          File(shops[id]!.photoMap['fishKonserv']!).deleteSync();
        }
        if (File(shops[id]!.photoMap['fruitKonserv']!).existsSync()) {
          File(shops[id]!.photoMap['fruitKonserv']!).deleteSync();
        }
        if (File(shops[id]!.photoMap['milkKonserv']!).existsSync()) {
          File(shops[id]!.photoMap['milkKonserv']!).deleteSync();
        }
      }catch(e){
        null;
      }
      shops.remove(id);
      nonReportShops();
      shopList.notifyListeners();
    }
  }

  void sendShopToServer(List<InternalShop> shop)
  {
    List<InternalShop> temp = [];
    for (final shopTemp in shop) {
      if (shopTemp.hasReport == false && shopTemp.isSending == false &&
          shopTemp.photoMap['externalPhoto'] != '' && shopTemp.photoMap['shopLabelPhoto'] != ''
          && shopTemp.cassCount != 0 && shopTemp.prodavecManagerCount != 0 && shopTemp.address != '') {
        _database?.execute('UPDATE travel_shop SET was_sending=true WHERE id=${shopTemp.id}');
        shopTemp.isSending = true;
        temp.add(shopTemp);
      }
    }
    socketHandler.sendShop(temp);
    nonReportShops();
    shopList.notifyListeners();
  }

  List<InternalShop> getNonHasReport()
  {
    var list = shops.values.toList(growable: false);
    List<InternalShop> temp = [];
    for(final dd in list){
      if(dd.hasReport == false){
        temp.add(dd);
      }
    }
    return temp;
  }

  void setUnsend()
  {
    var list = shops.values.toList(growable: false);
    for(final dd in list){
      if(dd.hasReport == false){
        _database?.execute('UPDATE travel_shop SET was_sending=false WHERE id=${dd.id}');
        dd.isSending = false;
      }
    }
    nonReportShops();
    shopList.notifyListeners();
  }

  double getDistance(InternalShop a)
  {
    final selfLocation = globalHandler.currentUserPoint;

    print(selfLocation.latitude);
    print(selfLocation.longitude);
    print(a.yCoord);
    print(a.xCoord);


    return Geolocator.distanceBetween(selfLocation.latitude,
      selfLocation.longitude,
      a.xCoord,
      a.yCoord,);
  }

  List<InternalShop> getFilteredPoints()
  {
    List<InternalShop> allList = shops.values.toList(growable: false);
    filteredShops.clear();

    allList.sort((a,b) => getDistance(a).compareTo(getDistance(b)));

    for(int i=0;i<allList.length;i++){
      filteredShops[allList[i].id] = allList[i];
    }

    return filteredShops.values.toList(growable: false);
  }

  void resendShops()
  {
    sendShopToServer(shops.values.toList(growable: false));
  }

  void setSuccessShop(List<int> success)
  {
    for(final id in success){
      shops[id]?.hasReport = true;
      shops[id]?.isSending = false;
      _database?.execute('UPDATE travel_shop SET has_report=true,was_sending=false WHERE id = $id');
    }
    nonReportShops();
    shopList.notifyListeners();
  }

  Future<Map<int, InternalShop>> shopFilteredReport(bool hasReport) async
  {
    Map<int, InternalShop> temp = {};
    var list = shops.values.toList(growable: false);
    for(final shop in list){
      if(shop.hasReport == hasReport){
        temp[shop.id] = shop;
      }
    }
    return temp;
  }
}