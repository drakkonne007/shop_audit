

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shop_audit/component/internal_shop.dart';
import 'package:shop_audit/component/location.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';


Widget getPhotoUniversal(String photoPath, String rootPath, Size size)
{
  return File(photoPath).existsSync() ? Image.file(File(photoPath),width: size.width,height: size.height, filterQuality: FilterQuality.none)
      : Image.network(rootPath + '/' + photoPath,width: size.width,height: size.height, filterQuality: FilterQuality.none, errorBuilder: (context, error, stackTrace) => SizedBox(width: size.width,height: size.height),);
}

double metersInOneAngle = 40075.0 / 360.0 * 1000.0;

class GlobalHandler
{
  bool wasHintAnket = false;
  bool wasNewShopHint = false;
  int userId = 0;
  Point currentUserPoint = const BishkekLocation();
  ValueNotifier<bool> isResendReports = ValueNotifier<bool>(false);
}

class CustomArgument
{
  CustomArgument({required this.shopId, this.photoPath = '', this.photoType = PhotoType.none, this.isFromReport = false});
  String photoPath = '';
  int shopId=0;
  PhotoType photoType;
  bool isFromReport = false;
}

final defaultNoneButtonStyle = ButtonStyle(
  minimumSize: MaterialStateProperty.all<Size>(const Size(200,50)),
  foregroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
  backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
  overlayColor: MaterialStateProperty.all<Color>(Colors.transparent),
  shadowColor: MaterialStateProperty.all<Color>(Colors.transparent),
  surfaceTintColor: MaterialStateProperty.all<Color>(Colors.red),
  elevation: MaterialStateProperty.all<double>(5),
  shape: MaterialStateProperty.all<RoundedRectangleBorder>(const RoundedRectangleBorder()),
  padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.zero),
);