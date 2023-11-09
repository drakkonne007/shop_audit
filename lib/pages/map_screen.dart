import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shop_audit/component/dynamic_alert_msg.dart';
import 'package:shop_audit/global/global_variants.dart';
import 'package:shop_audit/global/socket_handler.dart';
import 'package:shop_audit/main.dart';
import 'package:shop_audit/pages/camera_handler.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:shop_audit/global/shop_points_for_job.dart';
import 'package:http/http.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
{
  YandexMapController? _mapController;
  Map<int,PlacemarkMapObject> _mapObjects = {};
  List<PointFromDb> _sourcePoints  = [];
  final List<int> _activeShops = [];
  Map<int,int> _shopIdAim = {}; //shopId userId
  late Timer _timerSelfLocation;
  late Timer _timerSetMyLocation;
  late Timer _timerResendReport;
  int _lastAimId = -1;
  bool _isReconnect = false;

  @override
  void initState()
  {
    _mapObjects = returnListMapObjects();
    PointFromDbHandler().pointsFromDb.addListener(_changeObjects);
    PointFromDbHandler().userActivePoints.addListener(_changeUsersAim);
    SocketHandler().socketState.addListener(checkReconnect);
    _shopIdAim = PointFromDbHandler().userActivePoints.value;
    _timerSelfLocation = Timer.periodic(const Duration(seconds: 1),(timer) async{
      _fetchCurrentLocation(false);
    });
    _timerSetMyLocation = Timer.periodic(const Duration(seconds: 30),(timer){
      SocketHandler().sendMyPosition(GlobalHandler.currentUserPoint.latitude, GlobalHandler.currentUserPoint.longitude);
    });
    _timerResendReport = Timer.periodic(const Duration(minutes: 1),(timer){
      SocketHandler().checkLostReports();
    });
    SocketHandler().getCurrentBuild(_downloadFile);
    super.initState();
  }

  void reloadAll()
  {
    SocketHandler().loadShops(true);
    setState(() {
      _mapObjects = returnListMapObjects();
    });
    _refreshActiveShops();
  }

  void _downloadFile() async {
    var dir = await getExternalCacheDirectories();
    File file = File('${dir![0].path}/SmartConSol.apk');
    String myUrl = 'http://shop-audit.icu/pages/apk_page/SmartConSol.apk';
    var res = await get(Uri.parse(myUrl));
    await file.writeAsBytes(res.bodyBytes);
    await customAlertMsg(context,'Скачано обновление, установите пожалуйста');
    var ss = await OpenFile.open('${dir[0].path}/SmartConSol.apk');
  }

  @override
  void dispose()
  {
    _mapController?.dispose();
    _timerSelfLocation.cancel();
    _timerSetMyLocation.cancel();
    _timerResendReport.cancel();
    PointFromDbHandler().pointsFromDb.removeListener(_changeObjects);
    PointFromDbHandler().userActivePoints.removeListener(_changeUsersAim);
    SocketHandler().socketState.removeListener(checkReconnect);
    super.dispose();
  }

  void checkReconnect()
  {
    if(SocketHandler().socketState.value == SocketState.disconnected && !_isReconnect){
      setState(() {
        _isReconnect = true;
      });
    }
    if(SocketHandler().socketState.value == SocketState.connected && _isReconnect){
      setState(() {
        _isReconnect = false;
      });
    }
  }

  void _changeUsersAim()
  {
    setState(() {
      _shopIdAim = PointFromDbHandler().userActivePoints.value;
      SocketHandler().loadShops(true);
    });
  }

  void _refreshActiveShops()
  {
    _activeShops.clear();
    var currLoc = GlobalHandler.currentUserPoint;
    for(int i=0;i<_sourcePoints.length;i++){
      if(((_sourcePoints[i].x - currLoc.latitude) * metersInOneAngle).abs() > 30){
        continue;
      }
      if(((_sourcePoints[i].y - currLoc.longitude) * metersInOneAngle).abs() > 30){
        continue;
      }
      if((pow(_sourcePoints[i].x - currLoc.latitude,2) + pow(_sourcePoints[i].y - currLoc.longitude,2)) *  metersInOneAngle > pow(30,2)){
        continue;
      }
      _activeShops.add(_sourcePoints[i].id);
    }
  }


  Map<int,PlacemarkMapObject>  returnListMapObjects()
  {
    Map<int,PlacemarkMapObject> newList = {};
    _sourcePoints.clear();
    _sourcePoints = PointFromDbHandler().getFilteredPoints();
    for(var key in _sourcePoints)
    {
      newList.putIfAbsent( key.id, () => createPlaceMark(key));
    }
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
      if(_shopIdAim[globalUserId!] == shopId){
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

  @override
  Widget build(BuildContext context) {
    var allList = PointFromDbHandler().pointsFromDb.value.values.toList();
    return Scaffold(
        drawerEnableOpenDragGesture: false,
        drawer: Drawer(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                  const SizedBox(height: 30,),
                  ElevatedButton(onPressed: (){
                    if(SocketHandler().socketState.value != SocketState.connected){
                      customAlertMsg(context, 'Нет соединения с сервером! Подождите немного!');
                      return;
                    }
                    Navigator.of(context).pushNamed('/newShop');
                  }, child: const Text('Добавить магазин')
                  ),
                  ElevatedButton(onPressed: (){
                    PointFromDbHandler().showAllPointByUser();
                    PointFromDbHandler().pointsFromDb.notifyListeners();
                  }, child: const Text('Сбросить отмеченные вручную')
                  ),
                  ElevatedButton(onPressed: (){
                    PointFromDbHandler().sortType = SortType.None;
                    PointFromDbHandler().showAllPointByUser();
                    PointFromDbHandler().pointsFromDb.notifyListeners();
                  }, child: const Text('Все')
                  ),
                  ElevatedButton(onPressed: (){
                    PointFromDbHandler().sortType = SortType.Distance;
                    PointFromDbHandler().showAllPointByUser();
                    PointFromDbHandler().pointsFromDb.notifyListeners();
                  }, child: const Text('Ближе 5 километров')
                  ),
                  Expanded(
                      child:
                      ListView.builder(
                          itemCount: allList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Row(children:
                            [
                              Checkbox(
                                value: PointFromDbHandler().isNeedShop(allList[index].id),
                                onChanged: (val){
                                  if(val == true){
                                    PointFromDbHandler().pointsFromDb.value[allList[index].id]!.isNeedDrawByCustom = true;
                                  }else{
                                    PointFromDbHandler().pointsFromDb.value[allList[index].id]!.isNeedDrawByCustom = false;
                                  }
                                  PointFromDbHandler().pointsFromDb.notifyListeners();
                                },
                              ),
                              Expanded(
                                  child: TextButton(
                                      onPressed: () async{
                                        if (Platform.isAndroid) {
                                          AndroidIntent intent = AndroidIntent(
                                            action: 'action_view',
                                            data: 'geo:${allList[index].x},${allList[index].y}',
                                            package: 'com.google.android.apps.maps',
                                          );
                                          await intent.launch();
                                        }
                                      },
                                      child: Text('${allList[index].address}, ${allList[index].name}',
                                          style: TextStyle(
                                              color: getColor(allList[index].id)
                                          ))
                                  )),
                              IconButton(onPressed: (){
                                _moveToCurrentLocation();
                              }, icon: const Icon(Icons.gps_fixed))
                            ]);
                          }
                      )
                  ),
                  IconButton(onPressed: (){logOut(context);}, icon: const Icon(Icons.logout_outlined))
                ]
            )
        ),
        appBar: AppBar(
          actions: [
            ElevatedButton(onPressed: (){
              reloadAll();
            },
                child: const Icon(Icons.refresh)),
            ElevatedButton(onPressed: () async{
              _refreshActiveShops();
              if(SocketHandler().socketState.value != SocketState.connected){
                customAlertMsg(context, 'Нет соединения с сервером! Подождите немного!');
                return;
              }
              switch(_activeShops.length){
                case 0: {
                  await customAlertMsg(context,'Рядом нет магазина!');
                }
                break;
                case 1: {
                  GlobalHandler.activeShop = _activeShops[0];
                  GlobalHandler.activeShopName = PointFromDbHandler().pointsFromDb.value[_activeShops[0]]!.name;
                  CameraHandler().imagePaths = [];
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
                mapObjects: [_getClusterizedCollection(placemarks: _mapObjects.values.toList())]  ,
                onMapCreated: (controller) {
                  _mapController = controller;
                  _mapController?.toggleUserLayer(visible: true);
                },
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                    child: const Icon(Icons.gps_fixed),
                    onPressed: () async {
                      await _moveToCurrentLocation();
                    }
                ),
              ),
              _isReconnect ? const Align(
                  alignment: Alignment.topCenter,
                  child: Text('____Обрыв сети_____',
                    style: TextStyle(color: Colors.red, fontSize: 25, fontWeight: FontWeight.bold,backgroundColor: Colors.black),
                  )
              ) : Container()
            ]
        )
    );
  }

  ClusterizedPlacemarkCollection _getClusterizedCollection({
    required List<PlacemarkMapObject> placemarks,
  }) {

    return ClusterizedPlacemarkCollection(
        mapId: const MapObjectId('clusterized-1'),
        placemarks: placemarks,
        radius: 30,
        minZoom: 15,
        onClusterAdded: (self, cluster) async {
          int count = cluster.size;
          return cluster.copyWith(
            appearance: cluster.appearance.copyWith(
              opacity: 1,
              text: PlacemarkText(text: count.toString(), style: PlacemarkTextStyle(color: Colors.blue[900], size: 16)),
              icon: PlacemarkIcon.single(
                PlacemarkIconStyle(
                    image: BitmapDescriptor.fromAssetImage(
                        'assets/cluster_point.png'),
                    rotationType: RotationType.rotate,
                    scale: 0.8),
              ),
            ),
          );
        },
        onClusterTap: (self, cluster) async {
          await _mapController?.moveCamera(
            animation: const MapAnimation(
                type: MapAnimationType.linear, duration: 0.3),
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: cluster.placemarks.first.point,
                zoom: 18,
              ),
            ),
          );
        });
  }

  /// Получение текущей геопозиции пользователя
  Future<void> _fetchCurrentLocation(bool isNeedMove) async
  {
    var location = await _mapController!.getUserCameraPosition();
    if(location == null){
      return;
    }
    GlobalHandler.currentUserPoint = location.target;
  }

  /// Метод для показа текущей позиции
  Future<void> _moveToCurrentLocation() async
  {
    CameraPosition? point = await _mapController?.getUserCameraPosition();
    if(point == null){
      return;
    }
    await _mapController?.moveCamera(
      animation: const MapAnimation(type: MapAnimationType.linear, duration: 1),
      CameraUpdate.newCameraPosition(
        point.copyWith(zoom: 18),
      ),
    );
  }

  Future<void> _shopInfo(BuildContext context,PlacemarkMapObject mapObject)
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                Text('Адрес: ${PointFromDbHandler().pointsFromDb.value[shopId]!.address}'),
                // Text('Описание: ${PointFromDbHandler().pointsFromDb.value[shopId]!.description}'),
                // Text('Начало работы: ${PointFromDbHandler().pointsFromDb.value[shopId]!.startWorkingTime}'),
                // Text('Конец работы:  ${PointFromDbHandler().pointsFromDb.value[shopId]!.endWorkingTime}'),
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
                  if(_lastAimId != -1){
                    _mapObjects[_lastAimId] = _mapObjects[_lastAimId]!.copyWith(
                        icon: PlacemarkIcon.single(PlacemarkIconStyle(
                            image: BitmapDescriptor.fromAssetImage(
                                'assets/black_point.png'),
                            rotationType: RotationType.noRotation,
                            scale: 2)));
                  }
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

  Future<void> _variantsShops(BuildContext context)
  {
    List<int> temp = List.unmodifiable(_activeShops);
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
                        itemCount: temp.length,
                        itemBuilder: (BuildContext context, int index){
                          return ElevatedButton(onPressed: (){
                            GlobalHandler.activeShop = temp[index];
                            GlobalHandler.activeShopName = PointFromDbHandler().pointsFromDb.value[temp[index]]!.name;
                            CameraHandler().imagePaths = [];
                            Navigator.of(context).pushNamed('/report');
                          }, child: Text( PointFromDbHandler().pointsFromDb.value[temp[index]]!.name));
                        }
                    )
                ),
                const SizedBox(height: 20),
                ElevatedButton(onPressed: (){
                  Navigator.of(context).pop();
                }, child: const Text('Отмена'))
              ]
          ),
        );
      },
    );
  }

  Color getColor(int id)
  {
    if(_shopIdAim.containsValue(id)){
      if(_shopIdAim[globalUserId!] == id){
        return Colors.red;
      }else{
        return Colors.yellow;
      }
    }
    return Colors.black;
  }
}

Future<void> logOut(BuildContext context) async
{
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title:  const Text('Выйти из аккаунта?'),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Ок'),
            onPressed: () {
              mainShared?.setString('login','');
              mainShared?.setString('pwd','');
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Нет'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
