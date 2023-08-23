
import 'package:flutter/cupertino.dart';

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
  ValueNotifier<List<PointFromDb>> pointsFromDb = ValueNotifier([]);
  bool isNeedLoad = true;
}