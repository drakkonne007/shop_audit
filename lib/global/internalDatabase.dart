import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:shop_audit/component/internal_shop.dart';
import 'package:shop_audit/global/global_variants.dart';
import 'package:shop_audit/main.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

enum SortType
{
  none,
  distance,
  dateTimeCreated,
}

bool isNeedShop(int id){
  if(!pointsFromDb.value.containsKey(id)){
    return false;
  }
  return pointsFromDb.value[id]!.isNeedDrawBySort;
}

class SqlFliteDB
{
  Database? _database;
  Map<int, InternalShop> shops = {};
  Map<int, InternalShop> filteredShops = {};
  ValueNotifier<int> allShops = ValueNotifier(0);
  ValueNotifier<int> hasReports = ValueNotifier(0);
  SortType _sortType = SortType.none;

  SqlFliteDB()
  {
    if (_database == null) openDb();
  }

  void openDb() async
  {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'internalShops.db');
    _database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) {
          db.execute('CREATE TABLE shop '
              '(id INTEGER PRIMARY KEY autoincrement NOT NULL'
              ',user_id INTEGER NOT NULL'
              ',shop_name TEXT NOT NULL'
              ',shop_type TEXT'
              ',yuridic_form TEXT'
              ',has_report INTEGER NOT NULL DEFAULT 0'
              ',was_sending INTEGER NOT NULL DEFAULT 0'
              ',x REAL'
              ',y REAL'
              ',external_photo TEXT'
              ',shop_label_photo TEXT'
              ',non_alkohol_photo TEXT'
              ',alkohol_photo TEXT'
              ',kolbasa_syr TEXT'
              ',milk TEXT'
              ',snack TEXT'
              ',konditer TEXT'
              ',konserv TEXT'
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
              ',millisecs_since_epoch INTEGER NOT NULL'
              ',)');
        });
  }

  Future<Map<int, InternalShop>> getShops()async
  {
    var res = await _database?.rawQuery('SELECT * FROM shop ORDER BY id');
    if (res == null) {
      return {};
    }else{
      shops = _createShopsFromDB(res);
      return shops;
    }
  }

  Map<int, InternalShop> _createShopsFromDB(List<Map<String,Object?>> res)
  {
    Map<int, InternalShop>  temp = {};
    for (final raw in res) {
      InternalShop shop = InternalShop(raw['id'] as int);
      shop.userId = raw['user_id'] as int;
      shop.shopName = raw['shop_name'].toString();
      shop.xCoord = raw['x'] == null ? 0 : raw['x'] as double;
      shop.yCoord = raw['y'] == null ? 0 : raw['y'] as double;
      shop.photoMap['externalPhoto'] = raw['external_photo'] == null ? '' : raw['external_photo'].toString();
      shop.photoMap['shopLabelPhoto'] = raw['shop_label_photo'] == null ? '' : raw['shop_label_photo'].toString();
      shop.photoMap['nonAlkoholPhoto'] = raw['non_alkohol_photo'] == null ? '' : raw['non_alkohol_photo'].toString();
      shop.photoMap['alkoholPhoto'] = raw['alkohol_photo'] == null ? '' : raw['alkohol_photo'].toString();
      shop.photoMap['kolbasaSyr'] = raw['kolbasa_syr'] == null ? '' : raw['kolbasa_syr'].toString();
      shop.photoMap['milk'] = raw['milk'] == null ? '' : raw['milk'].toString();
      shop.photoMap['snack'] = raw['snack'] == null ? '' : raw['snack'].toString();
      shop.photoMap['konditer'] = raw['konditer'] == null ? '' : raw['konditer'].toString();
      shop.photoMap['konserv'] = raw['konserv'] == null ? '' : raw['konserv'].toString();
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
      shop.paymanetTerminal = raw['paymanet_terminal'] == null ? 0 : raw['paymanet_terminal'] as int;
      shop.emptySpace = raw['empty_space'] == null ? EmptySpace.few : EmptySpace.values.byName(raw['empty_space'].toString());
      shop.yuridicForm = raw['yuridic_form'] == null ? YuridicForm.none : YuridicForm.values.byName(raw['yuridic_form'].toString());
      shop.millisecsSinceEpoch = raw['millisecs_since_epoch'] as int;
      temp[shop.id] = shop;
    }
    return temp;
  }

  Future<int> addShop(String shopName, ShopType shopType) async
  {
    var dd = await _database?.rawQuery('INSERT INTO shop(user_id, shop_name, millisecs_since_epoch, shop_type) VALUES '
        '(${globalHandler.userId},"$shopName", ${DateTime.now().millisecondsSinceEpoch}, ${shopType.index}) returning id');
    if(dd == null) return 0;
    _sortType = SortType.none;
    getShops();
    return dd[0]['id'] as int;
  }

  void setPhoto(int shopId, PhotoType type, String path)
  {
    var newShop = shops[shopId]!;
    if(newShop.photoMap.containsKey(type.name)) {
      newShop.photoMap[type.name] = path;
      updateShop(newShop);
    }
  }

  void updateShop(InternalShop newShop)
  {
    _database?.execute('UPDATE shop SET '
        'shop_name = "${newShop.shopName}", '
        'x = ${newShop.xCoord}, '
        'y = ${newShop.yCoord}, '
        'external_photo = "${newShop.photoMap['externalPhoto']}", '
        'shop_label_photo = "${newShop.photoMap['shopLabelPhoto']}", '
        'non_alkohol_photo = "${newShop.photoMap['nonAlkoholPhoto']}", '
        'alkohol_photo = "${newShop.photoMap['alkoholPhoto']}", '
        'kolbasa_syr = "${newShop.photoMap['kolbasaSyr']}", '
        'milk = "${newShop.photoMap['milk']}", '
        'snack = "${newShop.photoMap['snack']}", '
        'konditer = "${newShop.photoMap['konditer']}", '
        'konserv = "${newShop.photoMap['konserv']}", '
        'mylomoika = "${newShop.photoMap['mylomoika']}", '
        'vegetables_fruits = "${newShop.photoMap['vegetablesFruits']}", '
        'cigarettes = "${newShop.photoMap['cigarettes']}", '
        'kassovaya_zona = "${newShop.photoMap['kassovayaZona']}", '
        'toys = "${newShop.photoMap['toys']}", '
        'butter = "${newShop.photoMap['butter']}", '
        'phone_number = "${newShop.phoneNumber}", '
        'shop_square_meter = ${newShop.shopSquareMeter}, '
        'yuridic_form = ${newShop.yuridicForm.name}, '
        'cass_count = ${newShop.cassCount}, '
        'prodavec_manager_count = ${newShop.prodavecManagerCount}, '
        'halyal = ${newShop.halal ? 1 : 0}, '
        'paymanet_terminal = ${newShop.paymanetTerminal},'
        'shop_type = ${newShop.shopType.name}, '
        'empty_space = ${newShop.emptySpace.name}'
        'WHERE id = ${newShop.id}');
    newShop.hasReport = false;
    newShop.isSending = false;
    shops[newShop.id] = newShop;
  }

  void deleteShop(int id)
  {
    _database?.execute('DELETE FROM shop WHERE id = $id');
    if(shops.containsKey(id)) {
      socketHandler.deleteShop(shops[id]!);
      shops.remove(id);
    }
  }

  void sendShopToServer(List<InternalShop> shop)
  {
    List<InternalShop> temp = [];
    for (final shopTemp in shop) {
      if (shopTemp.hasReport == false && shopTemp.isSending == false) {
        shopTemp.isSending = true;
        temp.add(shopTemp);
      }
      socketHandler.sendShop(temp);
    }
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
        dd.isSending = false;
      }
    }
  }

  List<InternalShop> getFilteredPoints(SortType type)
  {
    if(_sortType == SortType.none) {
      return shops.values.toList(growable: false);
    }
    if(_sortType == type) {
      return filteredShops.values.toList(growable: false);
    }
    _sortType = type;
    List<InternalShop> allList = shops.values.toList(growable: false);
    filteredShops.clear();
    switch(_sortType){
      case SortType.none: {
        for(int i=0;i<allList.length;i++){
          allList[i].isNeedDrawBySort = true;
          if(allList[i].xCoord > 0 && allList[i].yCoord > 0) {
            filteredShops[allList[i].id] = allList[i];
          }
        }
      }
      case SortType.distance:
        var selfLocation = globalHandler.currentUserPoint;
        for(int i=0;i<allList.length;i++){
          if(sqrt(pow(allList[i].xCoord - selfLocation.latitude,2) + pow(allList[i].yCoord - selfLocation.longitude,2)) *  metersInOneAngle > 5000){
            allList[i].isNeedDrawBySort = false;
            continue;
          }
          allList[i].isNeedDrawBySort = true;
          if(allList[i].xCoord != 0 && allList[i].yCoord != 0) {
            filteredShops[allList[i].id] = allList[i];
          }
        }
      case SortType.dateTimeCreated:
        for(int i=0;i<allList.length;i++){
          if(allList[i].millisecsSinceEpoch < DateTime.now().add(const Duration(days: -30)).millisecondsSinceEpoch){
            allList[i].isNeedDrawBySort = false;
            continue;
          }
          allList[i].isNeedDrawBySort = true;
          if(allList[i].xCoord != 0 && allList[i].yCoord != 0) {
            filteredShops[allList[i].id] = allList[i];
          }
        }
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
      _database?.execute('UPDATE shop SET has_report=true WHERE id = $id');
    }
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