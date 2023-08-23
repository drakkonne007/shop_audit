import 'package:geolocator/geolocator.dart';
import 'package:shop_audit/location.dart';

abstract class AppLocation
{
  Future<AppLatLong> getCurrentLocation();
  Future<bool> requestPermission();
  Future<bool> checkPermission();
}

class LocationService implements AppLocation
{
  final defLocation = const MoscowLocation();

  @override
  Future<bool> checkPermission() async
  {
    return Geolocator.checkPermission()
        .then((value) =>
    value == LocationPermission.always ||
        value == LocationPermission.whileInUse)
        .catchError((_) => false);
  }

  @override
  Future<AppLatLong> getCurrentLocation() async
  {
    return Geolocator.getCurrentPosition().then((value) {
      return AppLatLong(lat: value.latitude, long: value.longitude);
    }).catchError(
          (_) => defLocation,
    );
  }

  @override
  Future<bool> requestPermission() async
  {
    return Geolocator.requestPermission()
        .then((value) =>
    value == LocationPermission.always ||
        value == LocationPermission.whileInUse)
        .catchError((_) => false);
  }
}