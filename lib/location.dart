class AppLatLong
{
  final double lat;
  final double long;

  const AppLatLong({
    required this.lat,
    required this.long,
  });
}

class MoscowLocation extends AppLatLong
{
  const MoscowLocation({
    super.lat = 55.7522200,
    super.long = 37.6155600,
  });
}

class BishkekLocation extends AppLatLong
{
  const BishkekLocation({
    super.lat = 42.882004,
    super.long = 74.582748,
  });
}
