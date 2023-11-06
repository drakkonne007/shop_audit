import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shop_audit/component/app_location.dart';
import 'package:shop_audit/component/dynamic_alert_msg.dart';
import 'package:shop_audit/component/location.dart';
import 'package:shop_audit/component/location_global.dart';
import 'package:shop_audit/global/global_variants.dart';
import 'package:shop_audit/global/socket_handler.dart';
import 'package:shop_audit/main.dart';
import 'package:shop_audit/pages/camera_handler.dart';
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
  final List<int> _activeShops = [];
  Map<int,int> _shopIdAim = {}; //shopId userId
  late Timer _timerSelfLocation;
  late Timer _timerSetMyLocation;
  late Timer _timerResendReport;
  int _lastAimId = -1;
  int selfId = 0;
  AppLatLong _myLocation = BishkekLocation();
  bool _isReconnect = false;

  @override
  void initState()
  {
    print('initState');
    _mapObjects = returnListMapObjects();
    _initPermission().ignore();
    PointFromDbHandler().pointsFromDb.addListener(_changeObjects);
    PointFromDbHandler().userActivePoints.addListener(_changeUsersAim);
    SocketHandler().socketState.addListener(checkReconnect);
    _shopIdAim = PointFromDbHandler().userActivePoints.value;
    _timerSelfLocation = Timer.periodic(const Duration(seconds: 1),(timer){
      // SocketHandler().getAims(false);
      _fetchCurrentLocation(false);
    });
    _timerSetMyLocation = Timer.periodic(const Duration(seconds: 30),(timer){
      var temp = LocationHandler().currentLocation;
      SocketHandler().sendMyPosition(temp.latitude, temp.longitude);
    });
    _timerResendReport = Timer.periodic(const Duration(minutes: 5),(timer){
      SocketHandler().checkLostReports();
    });
    // SocketHandler().getCurrentBuild(downloadFile);
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

  Future<void> downloadFile() async {

    HttpClient httpClient = HttpClient();
    File file;
    String myUrl = ' http://shop-audit.icu/pages/apk_page/SmartConSol.apk';
    try {
      var dir = await getApplicationDocumentsDirectory();
      String output = dir.path + '/SmartConSol.apk';
      var request = await httpClient.getUrl(Uri.parse(myUrl));
      var response = await request.close();
      if(response.statusCode == 200) {
        var bytes = await consolidateHttpClientResponseBytes(response);
        file = File(output);
        await file.writeAsBytes(bytes);
        return showDialog<void>(
          //PointFromDbHandler().activeShop = _activeShops[0];
          context: context,
          builder: (BuildContext context) {
            return Scaffold(
                appBar: AppBar(),
                body: ElevatedButton(
                  onPressed: () {
                    AndroidIntent intent = AndroidIntent(
                      action: 'action_view',
                      data: file.path,
                      type: 'application/vnd.android.package-archive',
                    );
                  },
                  child: Text('установить новую версию'),
                )
            );
          },
        );
      }else{
       print('Error code: '+response.statusCode.toString());
      }
    }
    catch(ex){
      print(ex);
    }

  }

  @override
  void dispose()
  {
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
    var currLoc = LocationHandler().currentLocation;
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
                  }, child: Text('Сбросить отмеченные вручную')
                  ),
                  ElevatedButton(onPressed: (){
                    PointFromDbHandler().sortType = SortType.None;
                    PointFromDbHandler().showAllPointByUser();
                    PointFromDbHandler().pointsFromDb.notifyListeners();
                  }, child: Text('Все')
                  ),
                  ElevatedButton(onPressed: (){
                    PointFromDbHandler().sortType = SortType.Distance;
                    PointFromDbHandler().showAllPointByUser();
                    PointFromDbHandler().pointsFromDb.notifyListeners();
                  }, child: Text('Ближе 5 километров')
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
                                _moveToCurrentLocation(AppLatLong(latitude: allList[index].x, longitude: allList[index].y));
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
                      // bool isLoad = await DatabaseClient().openDB();
                      // print(isLoad);
                      // if(isLoad){
                      //   DatabaseClient().getShopPoints();
                      // }
                      // return;
                      _fetchCurrentLocation(true);
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

  Future<void> _variantsShops(BuildContext context) async
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
                }, child: Text('Отмена'))
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
//
// Future<void> updateProgramDialog(BuildContext context)
// {
//   return showDialog<void>(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title:  Text('Вышла новая версия программы. Для дальнейшей работы необходимо обновить приложение'),
//         actions: <Widget>[
//           TextButton(
//             style: TextButton.styleFrom(
//               textStyle: Theme.of(context).textTheme.labelLarge,
//             ),
//             child: const Text('Обновить'),
//             onPressed: () async{
//               final dir =
//               await getApplicationDocumentsDirectory();
// //From path_provider package
//               var _localPath = dir.path + 'apk';
//               final savedDir = Directory(_localPath);
//               savedDir.create(recursive: true).then((value) async {
//                 String? _taskid = await FlutterDownloader.enqueue(
//                   url: 'https://shop-audit.icu/pages/apk_page/build.apk',
//                   fileName: 'smartConSol.apk',
//                   savedDir: _localPath,
//                   showNotification: true,
//                   openFileFromNotification: true,
//                 );
//                 print(_taskid);
//               });
//             },
//           ),
//         ],
//       );
//     },
//   );
// }