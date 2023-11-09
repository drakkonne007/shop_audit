

import 'package:shop_audit/component/location.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class GlobalHandler
{
  static int activeShop = 0;
  static String activeShopName = '';
  static Point currentUserPoint = const BishkekLocation();
}