import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shop_audit/app_location.dart';
import 'package:shop_audit/location.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:shop_audit/global/database.dart';
import 'package:shop_audit/global/shop_points_for_job.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}



class _MapScreenState extends State<MapScreen>
{
  final mapControllerCompleter = Completer<YandexMapController>();
  List<MapObject> _mapObjects = [];

  @override
  void initState()
  {
    super.initState();
    _mapObjects = [];
    _initPermission().ignore();
    PointFromDbHandler().pointsFromDb.addListener(_changeObjects);
    DatabaseClient().getShopPoints();
  }

  @override
  void dispose()
  {
    super.dispose();
    PointFromDbHandler().pointsFromDb.addListener(_changeObjects);
  }

  void _changeObjects()
  {
    var pastObjs = _mapObjects;
    List<MapObject> newList = [];
    var list = PointFromDbHandler().pointsFromDb.value;
    print('_changeObjects() ${list.length}');
    for(var i = 0; i < list.length; i++)
    {
      newList.add(createPlaceMark(list[i]));
    }
    if(pastObjs != newList) {
      setState(() {
        _mapObjects = newList;
      });
    }
  }

  PlacemarkMapObject createPlaceMark(PointFromDb point)
  {
    print('createPlaceMark()');
    final mapObject = PlacemarkMapObject(
        mapId: MapObjectId('${point.id}'),
        point: Point(latitude: point.x, longitude: point.y),
        onTap: (PlacemarkMapObject self, Point point) => print('Tapped me at $point'),
        opacity: 0.7,
        direction: 90,
        isDraggable: false,
        icon: PlacemarkIcon.single(PlacemarkIconStyle(
            image: BitmapDescriptor.fromAssetImage('assets/0-0.png'),
            rotationType: RotationType.rotate,
            scale: 10
        )),
        text: const PlacemarkText(
            text: 'Point',
            style: PlacemarkTextStyle(
                placement: TextStylePlacement.top,
                color: Colors.amber,
                outlineColor: Colors.black
            )
        )
    );
    return mapObject;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(onPressed: (){Navigator.of(context).pushNamed('/points');}, icon: const Icon(Icons.settings)),
            ElevatedButton(onPressed: (){Navigator.of(context).pushNamed('/report');}, child: const Text('отправить отчёт'))
          ],
        ),
        body: Stack(
            fit: StackFit.passthrough,
            children:[
              YandexMap(
                tiltGesturesEnabled: false,
                mapObjects: _mapObjects,
                onMapCreated: (controller) {
                  mapControllerCompleter.complete(controller);
                },
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                    child: Icon(Icons.gps_fixed),
                    onPressed: (){
                      _fetchCurrentLocation();
                    }
                ),
              )
            ]
        )
    );
  }

  /// Проверка разрешений на доступ к геопозиции пользователя
  Future<void> _initPermission() async
  {
    if (!await LocationService().checkPermission()) {
      await LocationService().requestPermission();
    }
    await _fetchCurrentLocation();
  }

  /// Получение текущей геопозиции пользователя
  Future<void> _fetchCurrentLocation() async
  {
    AppLatLong location;
    const defLocation = BishkekLocation();
    try {
      location = await LocationService().getCurrentLocation();
    } catch (_) {
      location = defLocation;
    }
    _moveToCurrentLocation(location);
  }

  /// Метод для показа текущей позиции
  Future<void> _moveToCurrentLocation(
      AppLatLong appLatLong,
      ) async
  {
    (await mapControllerCompleter.future).moveCamera(
      animation: const MapAnimation(type: MapAnimationType.linear, duration: 1),
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: Point(
            latitude: appLatLong.lat,
            longitude: appLatLong.long,
          ),
          zoom: 12,
        ),
      ),
    );
  }
}