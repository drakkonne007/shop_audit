
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:shop_audit/component/location_global.dart';

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
}

class PointFromDbHandler
{
  static final PointFromDbHandler _pointFromDb = PointFromDbHandler._internal();
  factory PointFromDbHandler() {
    return _pointFromDb;
  }
  PointFromDbHandler._internal();
  ValueNotifier<Map<int,PointFromDb>> pointsFromDb = ValueNotifier({});
  bool isNeedLoad = true;
  Set<int> uselessPoints = {};
  SortType sortType = SortType.None;

  List<PointFromDb> getUserPoints()
  {
    print('parent uselessPoints $uselessPoints');
    List<PointFromDb> list = [];
    List<PointFromDb> allList = pointsFromDb.value.values.toList();
    uselessPoints = {};
    switch(sortType){
      case SortType.None: {
        for(int i=0;i<allList.length;i++){
          list.add(allList[i]);
        }
        return list;
      }
      case SortType.Distance:
        var selfLocation = LocationHandler().currentLocation;
        for(int i=0;i<allList.length;i++){
          if(sqrt(pow(allList[i].x - selfLocation.lat,2) + pow(allList[i].y - selfLocation.long,2)) *  40075.0 / 360.0 * 1000.0 > 5000){
            uselessPoints.add(allList[i].id);
            print('add useless by distance');
            continue;
          }
          list.add(allList[i]);
        }
        return list;
      case SortType.DateTimeCreated:
        for(int i=0;i<allList.length;i++){
          if(allList[i].dateTimeCreated.millisecondsSinceEpoch < DateTime.now().add(const Duration(days: -30)).millisecondsSinceEpoch){
            uselessPoints.add(allList[i].id);
            continue;
          }
          list.add(allList[i]);
        }
        return list;
      case SortType.IsNeedReport:
        for(int i=0;i<allList.length;i++){
          if(allList[i].isWasReport){
            uselessPoints.add(allList[i].id);
            continue;
          }
          list.add(allList[i]);
        }
        return list;
    }
  }
}