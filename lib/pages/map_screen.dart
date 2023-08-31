import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shop_audit/component/app_location.dart';
import 'package:shop_audit/component/dynamic_alert_msg.dart';
import 'package:shop_audit/component/location.dart';
import 'package:shop_audit/component/location_global.dart';
import 'package:shop_audit/global/socket_handler.dart';
import 'package:shop_audit/main.dart';
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
  Map<int,PlacemarkMapObject> _mapObjects = {};
  List<PointFromDb> _sourcePoints  = [];
  List<int> _activeShops = [];
  Map<int,int> _shopIdAim = {}; //shopId userId
  late Timer _timerSelfLocation;
  int _lastAimId = 0;
  int selfId = 0;
  AppLatLong _myLocation = BishkekLocation();

  @override
  void initState()
  {
    _mapObjects = returnListMapObjects();
    _initPermission().ignore();
    PointFromDbHandler().pointsFromDb.addListener(_changeObjects);
    PointFromDbHandler().userActivePoints.addListener(_changeUsersAim);
    _shopIdAim = PointFromDbHandler().userActivePoints.value;
    _timerSelfLocation = Timer.periodic(const Duration(seconds: 5),(timer){
      SocketHandler().getAims(false);
      _fetchCurrentLocation(false);
    });
    super.initState();
  }

  @override
  void dispose()
  {
    _timerSelfLocation.cancel();
    PointFromDbHandler().pointsFromDb.removeListener(_changeObjects);
    PointFromDbHandler().userActivePoints.removeListener(_changeUsersAim);
    super.dispose();
  }

  void _changeUsersAim()
  {
    setState(() {
      _shopIdAim = PointFromDbHandler().userActivePoints.value;
    });
  }

  void _refreshActiveShops()
  {
    var currLoc = LocationHandler().currentLocation;
    for(int i=0;i<_sourcePoints.length;i++){
      if(((_sourcePoints[i].x - currLoc.latitude) * metersInOneAngle).abs() > 150){
        continue;
      }
      if(((_sourcePoints[i].y - currLoc.longitude) * metersInOneAngle).abs() > 150){
        continue;
      }
      if( pow(_sourcePoints[i].x - currLoc.latitude,2) + pow(_sourcePoints[i].y - currLoc.longitude,2) *  metersInOneAngle > pow(100,2)){
        continue;
      }
      _activeShops.add(_sourcePoints[i].id);
    }
  }


  Map<int,PlacemarkMapObject>  returnListMapObjects()
  {
    Map<int,PlacemarkMapObject> newList = {};
    _sourcePoints = PointFromDbHandler().getFilteredPoints();
    for(var key in _sourcePoints)
    {
      newList.putIfAbsent( key.id, () => createPlaceMark(key));
    }
    newList.putIfAbsent(0,() =>  selfPoint());
    return newList;
  }



  void _changeObjects()
  {
    Map<int,PlacemarkMapObject> newList = returnListMapObjects();
    setState(() {
      _mapObjects = newList;
    });
  }

  BitmapDescriptor getShopIcon(int shopId)
  {
    if(_shopIdAim.containsValue(shopId)){
      if(_shopIdAim[mainShared?.getInt('userId')] == shopId){
        _lastAimId = shopId;
        return BitmapDescriptor.fromAssetImage('assets/red_point.png');
      }
      return BitmapDescriptor.fromAssetImage('assets/yellow_point.png');
    }
    return BitmapDescriptor.fromAssetImage('assets/black_point.png');
  }

  PlacemarkMapObject createPlaceMark(PointFromDb point)
  {
    final mapObject = PlacemarkMapObject(
        mapId: MapObjectId('${point.id}'),
        point: Point(latitude: point.x, longitude: point.y),
        onTap: (PlacemarkMapObject mapObject, Point point) async{
          await _shopInfo(context, mapObject);
        },
        opacity: 1,
        direction: 0,
        consumeTapEvents: true,
        isDraggable: false,
        icon: PlacemarkIcon.single(PlacemarkIconStyle(
            image: getShopIcon(point.id),
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

  PlacemarkMapObject selfPoint()
  {
    final mapObject = PlacemarkMapObject(
      mapId: MapObjectId(selfId.toString()),
      point: Point(latitude: LocationHandler().currentLocation.latitude, longitude: LocationHandler().currentLocation.longitude ),
      opacity: 1,
      direction: 0,
      consumeTapEvents: true,
      onTap: (PlacemarkMapObject mapObject, Point point) async{
        await customAlertMsg(context,'Это я');
      },
      isDraggable: false,
      icon: PlacemarkIcon.single(PlacemarkIconStyle(
          image: BitmapDescriptor.fromAssetImage('assets/self_point.png'),
          rotationType: RotationType.noRotation,
          scale: 1
      )),
    );
    return mapObject;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(onPressed: (){Navigator.of(context).pushNamed('/points');}, icon: const Icon(Icons.settings)),
            ElevatedButton(onPressed: () async{
              switch(_activeShops.length){
                case 0: {
                  await customAlertMsg(context,'Рядом нет магазина!');
                }
                break;
                case 1: {
                  PointFromDbHandler().activeShop = _activeShops[0];
                  Navigator.of(context).pushNamed('/report');
                }
                break;
                default:{
                  _variantsShops(context);
                }
                break;
              }
            },
                child: const Text('отправить отчёт'))
          ],
        ),
        body: Stack(
            fit: StackFit.passthrough,
            children:[
              YandexMap(
                tiltGesturesEnabled: false,
                mapObjects: _mapObjects.values.toList(),
                onMapCreated: (controller) {
                  mapControllerCompleter.complete(controller);
                },
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                    child: const Icon(Icons.gps_fixed),
                    onPressed: () async {
                      _fetchCurrentLocation(true);
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
    await _fetchCurrentLocation(true);
  }

  /// Получение текущей геопозиции пользователя
  Future<void> _fetchCurrentLocation(bool isNeedMove) async
  {
    AppLatLong location;
    const defLocation = MoscowLocation();
    try {
      location = await LocationService().getCurrentLocation();
    } catch (_) {
      location = defLocation;
    }
    if(_myLocation.latitude != location.latitude || _myLocation.longitude != location.longitude) {
      _myLocation = location;
      _refreshActiveShops();
      _changeObjects();
    }
    if(isNeedMove) {
      _moveToCurrentLocation(location);
    }
  }

  /// Метод для показа текущей позиции
  Future<void> _moveToCurrentLocation(AppLatLong appLatLong) async
  {
    (await mapControllerCompleter.future).moveCamera(
      animation: const MapAnimation(type: MapAnimationType.linear, duration: 1),
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: Point(
            latitude: appLatLong.latitude,
            longitude: appLatLong.longitude,
          ),
          zoom: 12,
        ),
      ),
    );
  }

  Future<void> _shopInfo(BuildContext context,PlacemarkMapObject mapObject) async
  {
    int shopId = int.parse(mapObject.mapId.value);
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
                Text('Начало работы: ${PointFromDbHandler().pointsFromDb.value[shopId]!.startWorkingTime}'),
                Text('Конец работы:  ${PointFromDbHandler().pointsFromDb.value[shopId]!.endWorkingTime}'),
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
                if(PointFromDbHandler().userActivePoints.value.containsValue(shopId)){
                  return;
                }
                setState(() {
                  _mapObjects[shopId] = _mapObjects[shopId]!.copyWith(icon: PlacemarkIcon.single(PlacemarkIconStyle(
                      image: BitmapDescriptor.fromAssetImage('assets/red_point.png'),
                      rotationType: RotationType.noRotation,
                      scale: 2)));
                  SocketHandler().updateCurrentAim(mapObject.mapId.value);
                  _mapObjects[_lastAimId] = _mapObjects[_lastAimId]!.copyWith(icon: PlacemarkIcon.single(PlacemarkIconStyle(
                      image: BitmapDescriptor.fromAssetImage('assets/black_point.png'),
                      rotationType: RotationType.noRotation,
                      scale: 2)));
                  _lastAimId = shopId;
                  SocketHandler().getAims(true);
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

  Future<void> _variantsShops(BuildContext context) async
  {
    return showDialog<void>(
      //PointFromDbHandler().activeShop = _activeShops[0];
      context: context,
      builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(),
          body: Column(
              children: [
                Expanded(
                    child:ListView.separated(
                        separatorBuilder: (BuildContext context, int index) => const Divider(),
                        itemCount: _activeShops.length,
                        itemBuilder: (BuildContext context, int index){
                          return ElevatedButton(onPressed: (){
                            PointFromDbHandler().activeShop = _activeShops[index];
                            Navigator.of(context).pushNamed('/report');
                          }, child: Text( PointFromDbHandler().pointsFromDb.value[_activeShops[index]]!.name));
                        }
                    )
                ),
                const SizedBox(height: 20),
                ElevatedButton(onPressed: (){
                  Navigator.of(context).pop();
                }, child: Text('Отмена'))
              ]
          ),
        );
      },
    );
  }
}