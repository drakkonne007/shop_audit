import 'package:shop_audit/component/app_location.dart';
import 'package:shop_audit/component/location.dart';

class LocationHandler
{
  static final LocationHandler _locationHandler = LocationHandler._internal();
  factory LocationHandler() {
    return _locationHandler;
  }
  LocationHandler._internal();


  AppLatLong currentLocation = BishkekLocation();

}


Future<AppLatLong> initPermissionAndGetCurrentLocation() async
{
  if (!await LocationService().checkPermission()) {
    await LocationService().requestPermission();
  }
  return await _fetchCurrentLocation();
}

/// Получение текущей геопозиции пользователя
Future<AppLatLong> _fetchCurrentLocation() async
{
  AppLatLong location;
  const defLocation = BishkekLocation();
  try {
    location = await LocationService().getCurrentLocation();
  } catch (_) {
    location = defLocation;
  }
  return location;
}