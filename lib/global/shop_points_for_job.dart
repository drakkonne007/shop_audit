
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:shop_audit/component/location_global.dart';

double metersInOneAngle = 40075.0 / 360.0 * 1000.0;

enum SortType
{
  None,
  Distance,
  DateTimeCreated,
  IsNeedReport,
}

class PointFromDb
{
  int id = -1;
  double x = -1;
  double y = -1;
  String name = '';
  String description = '';
  DateTime startWorkingTime = DateTime.now();
  DateTime endWorkingTime = DateTime.now();
  DateTime dateTimeCreated = DateTime.now();
  bool isWasReport = false;
  bool isNeedDrawBySort = true;
  bool isNeedDrawByCustom = true;
}

class PointFromDbHandler
{
  static final PointFromDbHandler _pointFromDb = PointFromDbHandler._internal();
  factory PointFromDbHandler() {
    return _pointFromDb;
  }
  PointFromDbHandler._internal();
  ValueNotifier<Map<int,PointFromDb>> pointsFromDb = ValueNotifier({});
  Set<int> customNeedsPoint = {};
  SortType sortType = SortType.None;
  Map<int,PointFromDb> cachedPoints = {};
  int activeShop = 0; //айди магазина для отчёта

  bool isNeedShop(int id){
    if(!pointsFromDb.value.containsKey(id)){
      return false;
    }
    return pointsFromDb.value[id]!.isNeedDrawByCustom && pointsFromDb.value[id]!.isNeedDrawBySort;
  }

  void showAllPointByUser()
  {
    List<PointFromDb> allList = pointsFromDb.value.values.toList();
    for(int i=0;i<allList.length;i++){
      allList[i].isNeedDrawByCustom = true;
    }
  }

  List<PointFromDb> getFilteredPoints()
  {
    List<PointFromDb> allList = pointsFromDb.value.values.toList();
    List<PointFromDb> filteredList = [];
    switch(sortType){
      case SortType.None: {
        for(int i=0;i<allList.length;i++){
          allList[i].isNeedDrawBySort = true;
          if(allList[i].isNeedDrawByCustom) {
            filteredList.add(allList[i]);
          }
        }
        return filteredList;
      }
      case SortType.Distance:
        var selfLocation = LocationHandler().currentLocation;
        for(int i=0;i<allList.length;i++){
          if(sqrt(pow(allList[i].x - selfLocation.latitude,2) + pow(allList[i].y - selfLocation.longitude,2)) *  metersInOneAngle > 5000){
            allList[i].isNeedDrawBySort = false;
            continue;
          }
          allList[i].isNeedDrawBySort = true;
          if(allList[i].isNeedDrawByCustom) {
            filteredList.add(allList[i]);
          }
        }
        return filteredList;
      case SortType.DateTimeCreated:
        for(int i=0;i<allList.length;i++){
          if(allList[i].dateTimeCreated.millisecondsSinceEpoch < DateTime.now().add(const Duration(days: -30)).millisecondsSinceEpoch){
            allList[i].isNeedDrawBySort = false;
            continue;
          }
          allList[i].isNeedDrawBySort = true;
          if(allList[i].isNeedDrawByCustom) {
            filteredList.add(allList[i]);
          }
        }
        return filteredList;
      case SortType.IsNeedReport:
        for(int i=0;i<allList.length;i++){
          if(allList[i].isWasReport){
            allList[i].isNeedDrawBySort = false;
            continue;
          }
          allList[i].isNeedDrawBySort = true;
          if(allList[i].isNeedDrawByCustom) {
            filteredList.add(allList[i]);
          }
        }
        return filteredList;
    }
  }
}