class AppLatLong
{
  final double latitude;
  final double longitude;

  const AppLatLong({
    required this.latitude,
    required this.longitude,
  });
}

class MoscowLocation extends AppLatLong
{
  const MoscowLocation({
    super.latitude = 55.7522200,
    super.longitude = 37.6155600,
  });
}

class BishkekLocation extends AppLatLong
{
  const BishkekLocation({
    super.latitude = 42.882004,
    super.longitude = 74.582748,
  });
}
