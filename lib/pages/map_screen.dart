import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shop_audit/component/app_location.dart';
import 'package:shop_audit/component/location.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
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
  int _aimShopPoint = 0;

  @override
  void initState()
  {
    super.initState();
    _mapObjects = returnListMapObjects();
    _initPermission().ignore();
    PointFromDbHandler().pointsFromDb.addListener(_changeObjects);
  }

  @override
  void dispose()
  {
    super.dispose();
    PointFromDbHandler().pointsFromDb.removeListener(_changeObjects);
  }

  List<MapObject>  returnListMapObjects()
  {
    List<MapObject> newList = [];
    var list = PointFromDbHandler().getUserPoints();
    for(var key in list)
    {
      newList.add(createPlaceMark(key));
    }
    return newList;
  }

  Future<void> _changeObjects() async
  {
    var pastObjs = _mapObjects;
    List<MapObject> newList = returnListMapObjects();
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
        onTap: (PlacemarkMapObject mapObject, Point point) async{
          await _dialogBuilder(context, mapObject);
          print('onTap');
        },
        opacity: 1,
        direction: 0,
        consumeTapEvents: true,
        isDraggable: false,
        icon: PlacemarkIcon.single(PlacemarkIconStyle(
            image: point.id == _aimShopPoint ? BitmapDescriptor.fromAssetImage('assets/red_point.png')  : BitmapDescriptor.fromAssetImage('assets/black_point.png'),
            rotationType: RotationType.noRotation,
            scale: 2
        )),
        text: PlacemarkText(
            text: point.name,
            style:const PlacemarkTextStyle(
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
                    child: const Icon(Icons.gps_fixed),
                    onPressed: () async {
                      print('Hohohoho');
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
    const defLocation = MoscowLocation();
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
      ) async {
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

  Future<void> _dialogBuilder(BuildContext context,PlacemarkMapObject mapObject) async
  {
    int shopId = int.parse(mapObject.mapId.value);
    print(shopId);
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:  Text(PointFromDbHandler().pointsFromDb.value[shopId]!.name),
          content:  Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children:[
                Text('Описание: ${PointFromDbHandler().pointsFromDb.value[shopId]!.description}'),
                Text('Начало работы: ${PointFromDbHandler().pointsFromDb.value[shopId]!.startWorkingTime.hour.toString()}: ${PointFromDbHandler().pointsFromDb.value[shopId]!.startWorkingTime.minute.toString()}'),
                Text('Конец работы:  ${PointFromDbHandler().pointsFromDb.value[shopId]!.endWorkingTime.hour.toString()}: ${PointFromDbHandler().pointsFromDb.value[shopId]!.endWorkingTime.minute.toString()}'),
                Text('Дата создания: ${presentDateTime(PointFromDbHandler().pointsFromDb.value[shopId]!.dateTimeCreated)}'),
              ]
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Отслеживать'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _aimShopPoint = shopId;
                  _mapObjects = returnListMapObjects();
                });
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Ок'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String presentDateTime(DateTime dateTime)
  {
    return '${dateTime.year}.${dateTime.month}.${dateTime.day} ${dateTime.hour}:${dateTime.minute}';
  }
}