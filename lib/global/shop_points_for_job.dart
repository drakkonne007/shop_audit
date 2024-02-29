import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:shop_audit/component/internal_shop.dart';
import 'package:shop_audit/main.dart';

double metersInOneAngle = 40075.0 / 360.0 * 1000.0;

enum SortType
{
  None,
  Distance,
  DateTimeCreated,
  IsNeedReport,
}

class PointFromDbHandler
{
  ValueNotifier<Map<int,InternalShop>> pointsFromDb = ValueNotifier({});
  SortType sortType = SortType.None;

  bool isNeedShop(int id){
    if(!pointsFromDb.value.containsKey(id)){
      return false;
    }
    return pointsFromDb.value[id]!.isNeedDrawBySort;
  }

  List<InternalShop> getFilteredPoints()
  {
    List<InternalShop> allList = pointsFromDb.value.values.toList();
    List<InternalShop> filteredList = [];
    switch(sortType){
      case SortType.None: {
        for(int i=0;i<allList.length;i++){
          allList[i].isNeedDrawBySort = true;
          if(allList[i].xCoord > 0 && allList[i].yCoord > 0) {
            filteredList.add(allList[i]);
          }
        }
      }
      case SortType.Distance:
        var selfLocation = globalHandler.currentUserPoint;
        for(int i=0;i<allList.length;i++){
          if(sqrt(pow(allList[i].xCoord - selfLocation.latitude,2) + pow(allList[i].yCoord - selfLocation.longitude,2)) *  metersInOneAngle > 5000){
            allList[i].isNeedDrawBySort = false;
            continue;
          }
          allList[i].isNeedDrawBySort = true;
          if(allList[i].xCoord != 0 && allList[i].yCoord != 0) {
            filteredList.add(allList[i]);
          }
        }
      case SortType.DateTimeCreated:
        for(int i=0;i<allList.length;i++){
          if(allList[i].millisecsSinceEpoch < DateTime.now().add(const Duration(days: -30)).millisecondsSinceEpoch){
            allList[i].isNeedDrawBySort = false;
            continue;
          }
          allList[i].isNeedDrawBySort = true;
          if(allList[i].xCoord != 0 && allList[i].yCoord != 0) {
            filteredList.add(allList[i]);
          }
        }
      case SortType.IsNeedReport:
        for(int i=0;i<allList.length;i++){
          if(allList[i].hasReport){
            allList[i].isNeedDrawBySort = false;
            continue;
          }
          allList[i].isNeedDrawBySort = true;
          if(allList[i].xCoord != 0 && allList[i].yCoord != 0) {
            filteredList.add(allList[i]);
          }
        }
    }
    return filteredList;
  }
}