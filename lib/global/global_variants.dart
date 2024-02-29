

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shop_audit/component/internal_shop.dart';
import 'package:shop_audit/component/location.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class GlobalHandler
{
  int userId = 0;
  int activeShopId = 0;
  Point currentUserPoint = const BishkekLocation();
  ValueNotifier<bool> isResendReports = ValueNotifier<bool>(false);
}

class CustomArgument
{
  CustomArgument({required this.shopId, this.photoPath = '', this.photoType = PhotoType.none});
  String photoPath = '';
  int shopId=0;
  PhotoType photoType;
}

final defaultNoneButtonStyle = ButtonStyle(
  minimumSize: MaterialStateProperty.all<Size>(Size.zero),
  foregroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
  backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
  overlayColor: MaterialStateProperty.all<Color>(Colors.transparent),
  shadowColor: MaterialStateProperty.all<Color>(Colors.transparent),
  surfaceTintColor: MaterialStateProperty.all<Color>(Colors.transparent),
  elevation: MaterialStateProperty.all<double>(0),
  shape: MaterialStateProperty.all<RoundedRectangleBorder>(const RoundedRectangleBorder()),
  padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.zero),
);