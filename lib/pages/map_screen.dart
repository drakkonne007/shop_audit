import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shop_audit/component/dynamic_alert_msg.dart';
import 'package:shop_audit/component/internal_shop.dart';
import 'package:shop_audit/global/global_variants.dart';
import 'package:shop_audit/global/internalDatabase.dart';
import 'package:shop_audit/global/socket_handler.dart';
import 'package:shop_audit/main.dart';
import 'package:shop_audit/pages/doReport.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:http/http.dart';

const List<String> days = [
  'Понедельник',
  'Вторник',
  'Среда',
  'Четверг',
  'Пятница',
  'Суббота',
  'Воскресенье'
];

class MapScreen extends StatefulWidget
{
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
{
  YandexMapController? _mapController;
  late Timer _timerMeterShop;
  late Timer _timerRefreshTask;
  bool _isReconnect = false;
  int _mapIdCluster = 0;
  SortType sortType = SortType.none;
  // Point _myLocation = const Point(latitude: 0, longitude: 0);
  String selectedDay = days[DateTime.now().weekday-1];
  List<InternalShop> _allList = [];

  @override
  void initState()
  {
    socketHandler.socketState.addListener(checkReconnect);
    socketHandler.getConfigMeterShop();
    socketHandler.polygonFromServer();
    _timerMeterShop = Timer.periodic(const Duration(minutes: 30), (timer) {
      socketHandler.getConfigMeterShop();
    });
    _timerRefreshTask = Timer.periodic(const Duration(minutes: 1), (timer) {
      socketHandler.getTasks();
    });
    socketHandler.getCurrentBuild(_downloadFile);
    socketHandler.loadShops(false);
    socketHandler.getTasks();
    socketHandler.resendShopList = _printResendedReports;
    sqlFliteDB.shopList.addListener(nullSetState);
    super.initState();
  }

  Future _askRequiredPermission() async
  {
    await [
      Permission.requestInstallPackages,
    ].request();
  }

  void _downloadFile() async
  {
    var dir = await getExternalCacheDirectories();
    File file = File('${dir![0].path}/SmartConSol.apk');
    if(file.existsSync()){
      file.deleteSync();
    }
    file.createSync();
    String myUrl = 'http://shop-audit.icu/pages/apk_page/SmartConSol.apk';
    var res = await get(Uri.parse(myUrl));
    await file.writeAsBytes(res.bodyBytes);
    await customAlertMsg(context, 'Скачано обновление, установите пожалуйста');
    await _askRequiredPermission();
    await OpenFile.open('${dir[0].path}/SmartConSol.apk');
  }

  @override
  void dispose()
  {
    _timerMeterShop.cancel();
    // _timerSetMyLocation.cancel();
    _timerRefreshTask.cancel();
    socketHandler.socketState.removeListener(checkReconnect);
    socketHandler.resendShopList = null;
    sqlFliteDB.shopList.removeListener(nullSetState);
    super.dispose();
  }

  void nullSetState()
  {
    setState(() {});
  }

  void checkReconnect()
  {
    if (socketHandler.socketState.value == SocketState.disconnected &&
        !_isReconnect) {
      setState(() {
        _isReconnect = true;
      });
    }
    if (socketHandler.socketState.value == SocketState.connected &&
        _isReconnect) {
      setState(() {
        _isReconnect = false;
      });
    }
  }

  List<PlacemarkMapObject> _createPlaceMark()
  {
    List<PlacemarkMapObject> tempList = [];
    // var source = sqlFliteDB.getFilteredPoints();
    for(int i=0;i<_allList.length;i++) {
      final mapObject = PlacemarkMapObject(
          mapId: MapObjectId('${_allList[i].id}'),
          point: Point(latitude: _allList[i].xCoord, longitude: _allList[i].yCoord),
          onTap: (PlacemarkMapObject mapObject, Point point) {
            _shopInfo(_allList[i]);
          },
          opacity: 1,
          direction: 0,
          consumeTapEvents: true,
          isDraggable: false,
          icon: PlacemarkIcon.single(PlacemarkIconStyle(
              image: BitmapDescriptor.fromAssetImage('assets/black_point.png'),
              rotationType: RotationType.noRotation,
              scale: 2
          )),
          text: PlacemarkText(
              text: _allList[i].shopName,
              style: const PlacemarkTextStyle(
                  placement: TextStylePlacement.top,
                  color: Colors.amber,
                  outlineColor: Colors.black
              )
          )
      );
      tempList.add(mapObject);
    }

    final weeksTasks = List.of(sqlFliteDB.getDayList(selectedDay));

    for(final task in weeksTasks) {
      final mapObject = PlacemarkMapObject(
          mapId: MapObjectId('${task.id}  report_shop'),
          point: Point(latitude: task.xCoord, longitude: task.yCoord),
          onTap: (PlacemarkMapObject mapObject, Point point) {
            _shopInfo(task);
          },
          opacity: 1,
          direction: 0,
          consumeTapEvents: true,
          isDraggable: false,
          icon: PlacemarkIcon.single(PlacemarkIconStyle(
              image: BitmapDescriptor.fromAssetImage(task.hasReport ? 'assets/green_shop.png' : 'assets/red_shop.png'),
              rotationType: RotationType.noRotation,
              scale: 2
          )),
          text: PlacemarkText(
              text: task.shopName,
              style: const PlacemarkTextStyle(
                  placement: TextStylePlacement.top,
                  color: Colors.amber,
                  outlineColor: Colors.black
              )
          )
      );
      tempList.add(mapObject);
    }
    return tempList;
  }

  void _printResendedReports(List<String> shopIds)
  {
    String text = shopIds.isEmpty
        ? 'Нет неотправленных отчётов'
        : 'Отчеты отправлены по ID: $shopIds';
    customAlertMsg(context, text);
  }

  List<Widget> getAllSmall()
  {
    List<Widget> temp = [];
    for(int i=0;i<_allList.length;i++){
      InternalShop shop = _allList[i];
      temp.add(Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: shop.hasReport ? Colors.red : Colors.transparent),
            color: shop.hasReport ? Colors.white : shop.isSending ? Colors.amber[100] : Colors.red[100],
            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
          ),
          child:
          Row(
              children:[
                shop.isReport ? File(shop.reportPhoto).existsSync() ? Image.file(File(shop.reportPhoto), width: 50,height: 50, fit: BoxFit.cover,)
                    : const SizedBox(width: 50, height: 50,)
                    : getPhotoUniversal(shop.photoMap['externalPhoto'] ?? '', shop.photoMap['rootPath'] ?? '', const Size(50, 50)),
                Expanded(
                    flex: 20,
                    child: TextButton(
                        onPressed:()async{
                          if(!await _fetchCurrentLocation()){
                            return;
                          }
                          if(sqlFliteDB.getDistance(shop) > 50 * 50){
                            customAlertMsg(context, 'Слишком далеко от магазина!');
                            return;
                          }
                          if(shop.isReport){
                            Navigator.of(context)
                                .pushNamed(DoReport.doReport,
                                arguments: shop);
                          }else {
                            Navigator.of(context)
                                .pushNamed('/shopPage',arguments: shop);
                          }
                        },
                        child: Text(shop.shopName.trim() + "\n" + presentDateTime(DateTime.fromMillisecondsSinceEpoch(shop.millisecsSinceEpoch)),
                            style: const TextStyle(
                                color: Colors.black)
                        ))
                ),
                IconButton(onPressed: (){
                  if (Platform.isAndroid) {
                    AndroidIntent intent = AndroidIntent(
                      action: 'action_view',
                      data: 'geo:${shop
                          .xCoord},${shop.yCoord}',
                      package: 'com.google.android.apps.maps',
                    );
                    intent.launch();
                  }
                }, icon: const Icon(Icons.map)),
                IconButton(onPressed: () {
                  _moveToCurrentLocation(newPoint: CameraPosition(
                      target: Point(latitude: shop.xCoord,
                          longitude: shop.yCoord)));
                  Scaffold.of(context).closeDrawer();
                }, icon: const Icon(Icons.gps_fixed))
              ]
          )
      ));
    }
    return temp;
  }

  @override
  Widget build(BuildContext context)
  {
    _allList = sqlFliteDB.getFilteredPoints();
    return Scaffold(
        drawerEnableOpenDragGesture: false,
        drawer: Drawer(
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      child: ElevatedButton(
                        onPressed: () {
                          sqlFliteDB.resendShops();
                        },
                        child: const Text('Отправить всё повторно'),
                      ),
                    ),
                    Expanded(
                        child:
                        ListView(
                          padding: EdgeInsets.zero,
                            children: [
                            ExpansionTile(
                              title: const Text('Свои магазины'),
                              controlAffinity: ListTileControlAffinity.leading,
                              children: getAllSmall(),
                            ),
                            const Divider(color: Colors.deepOrange,),
                            const Text('Задания:', textAlign: TextAlign.center, style: TextStyle(fontSize: 20),),
                            ...sqlFliteDB.getDayList(selectedDay).map((shop) {
                              return Container(
                                margin: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  border: Border.all(width: 1, color: shop.hasReport ? Colors.red : Colors.transparent),
                                  color: shop.hasReport
                                      ? Colors.white
                                      : shop.isSending
                                      ? Colors.amber[100]
                                      : Colors.red[100],
                                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                ),
                                child: Row(
                                  children: [
                                    File(shop.reportPhoto).existsSync()
                                        ? Image.file(File(shop.reportPhoto), width: 50, height: 50, fit: BoxFit.cover)
                                        : const SizedBox(width: 50, height: 50),
                                    Expanded(
                                      flex: 20,
                                      child: TextButton(
                                        onPressed: () async {
                                          if (!await _fetchCurrentLocation()) return;
                                          if (sqlFliteDB.getDistance(shop) > 100) {
                                            print(sqlFliteDB.getDistance(shop));
                                            customAlertMsg(context, 'Слишком далеко от магазина!');
                                            return;
                                          }
                                          if (shop.isReport) {
                                            Navigator.of(context).pushNamed(DoReport.doReport, arguments: shop.id);
                                          } else {
                                            Navigator.of(context).pushNamed('/shopPage', arguments: shop);
                                          }
                                        },
                                        child: Text(
                                          '${shop.shopName.trim()}\n${presentDateTime(DateTime.fromMillisecondsSinceEpoch(shop.millisecsSinceEpoch))}',
                                          style: const TextStyle(color: Colors.black),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        if (Platform.isAndroid) {
                                          AndroidIntent intent = AndroidIntent(
                                            action: 'action_view',
                                            data: 'geo:${shop.xCoord},${shop.yCoord}',
                                            package: 'com.google.android.apps.maps',
                                          );
                                          intent.launch();
                                        }
                                      },
                                      icon: const Icon(Icons.map),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        _moveToCurrentLocation(newPoint: CameraPosition(
                                          target: Point(latitude: shop.xCoord, longitude: shop.yCoord),
                                        ));
                                        Scaffold.of(context).closeDrawer();
                                      },
                                      icon: const Icon(Icons.gps_fixed),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        )
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:[
                          IconButton(onPressed: () {
                            _logOut(context);
                          }, icon: const Icon(Icons.logout_outlined))
                          , const Text('Версия $versionApk')
                        ]
                    )
                  ]
              ),
            )
        ),
        appBar: AppBar(
          actions: [
            Expanded(
                child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children:[
                      const SizedBox(width: 30,),
                      ElevatedButton(
                          onPressed: () {
                            setState(() {
                              bool onRoute = mainShared?.getBool('onRoute') ?? false;
                              mainShared?.setBool('onRoute', !onRoute);
                            });
                          },
                          style: mainShared?.getBool('onRoute') ?? false ? ButtonStyle(
                              backgroundColor:  MaterialStateProperty.all(Colors.green)) : const ButtonStyle(),
                          child: mainShared?.getBool('onRoute') ?? false ? const Text('Стоп') : const Text('Старт')
                      ),
                      DropdownButton<String>(
                          hint: const Text('Выберите день'),
                          value: selectedDay,
                          items: days.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedDay = newValue ?? days[DateTime.now().weekday-1];
                            });}),
                      ElevatedButton(onPressed: () {
                        setState(() {
                          sqlFliteDB.nonReportShops();
                          socketHandler.checkLostReports();
                          socketHandler.polygonFromServer();
                        });
                      },
                          child: const Icon(Icons.refresh)),
                    ]
                )
            )
            // ElevatedButton(onPressed: () async {
            //   _refreshActiveShops();
            //   switch (_activeShops.length) {
            //     case 0:
            //       {
            //         // await customAlertMsg(context,'Рядом нет магазина!');
            //         globalHandler.activeShop = _activeShops[0];
            //         globalHandler.activeShopName =
            //             pointFromDbHandler.pointsFromDb
            //                 .value[_activeShops[0]]!.shopName;
            //         CameraHandler().imagePaths = [];
            //         Navigator.of(context).pushNamed('/report');
            //       }
            //       break;
            //     case 1:
            //       {
            //         globalHandler.activeShop = _activeShops[0];
            //         globalHandler.activeShopName =
            //             pointFromDbHandler.pointsFromDb
            //                 .value[_activeShops[0]]!.shopName;
            //         CameraHandler().imagePaths = [];
            //         Navigator.of(context).pushNamed('/report');
            //       }
            //       break;
            //     default:
            //       {
            //         _variantsShops(context);
            //       }
            //       break;
            //   }
            // },
            //     child: const Text('отправить отчёт'))
          ],
        ),
        body: Stack(
            fit: StackFit.passthrough,
            children: [
              YandexMap(
                mode2DEnabled: true,
                tiltGesturesEnabled: false,
                mapObjects: [
                  _getClusterizedCollection(),
                  PolygonMapObject(
                    mapId: MapObjectId(_getUUID().toString()),
                    polygon: Polygon(
                        outerRing: LinearRing(points: socketHandler.polygonPoints() ?? const []
                        ),
                        innerRings: const []
                    ),
                    strokeColor: const Color(0x20FF0000),
                    strokeWidth: 3.0,
                    fillColor: const Color(0x20FF0000),
                  )
                ],
                onMapCreated: (controller) {
                  _mapController = controller;
                  _mapController?.toggleUserLayer(visible: true);
                },
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: FloatingActionButton(
                    heroTag: "btn1",
                    child: const Icon(Icons.add_shopping_cart),
                    onPressed: () async {
                      bool onRoute = mainShared?.getBool('onRoute') ?? false;
                      if(!onRoute){
                        customAlertMsg(context, 'Сначала начните маршрут');
                        return;
                      }
                      if(await _fetchCurrentLocation()){
                        Navigator.of(context).pushNamed('/newShop');
                      }else{
                        customAlertMsg(context, 'Не могу определить место');
                      }
                      // bool serviceEnabled = await _fetchCurrentLocation();
                      // if(!serviceEnabled){
                      //   await geolocatorPlatform.openLocationSettings();
                      //   return;
                      // }

                    }
                ),
              ),
              Align(
                  alignment: Alignment.bottomRight,
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FloatingActionButton(
                            heroTag: "btn2",
                            child: const Icon(Icons.zoom_in),
                            onPressed: () async {
                              socketHandler.getTasks();
                              _mapController?.moveCamera(CameraUpdate.zoomIn());
                            }
                        ),
                        const SizedBox(height: 10,),
                        FloatingActionButton(
                            heroTag: "btn3",
                            child: const Icon(Icons.zoom_out),
                            onPressed: () async {
                              _mapController?.moveCamera(
                                  CameraUpdate.zoomOut());
                            }
                        ),
                        const SizedBox(height: 10,),
                        FloatingActionButton(
                            heroTag: "btn4",
                            child: const Icon(Icons.gps_fixed),
                            onPressed: () async {
                              await _moveToCurrentLocation();
                            }
                        ),
                        const SizedBox(height: 10,),
                      ]
                  )
              ),
              _isReconnect ? const Align(
                  alignment: Alignment.topCenter,
                  child: Text('____Обрыв сети_____',
                    style: TextStyle(color: Colors.red,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        backgroundColor: Colors.transparent),
                  )
              ) : Container()
            ]
        )
    );
  }

  int _getUUID()
  {
    return _mapIdCluster++;
  }

  ClusterizedPlacemarkCollection _getClusterizedCollection()
  {
    return ClusterizedPlacemarkCollection(
        mapId: MapObjectId(_getUUID().toString()),
        placemarks: _createPlaceMark(),
        radius: 30,
        minZoom: 15,
        onClusterAdded: (self, cluster) async {
          int count = cluster.size;
          return cluster.copyWith(
            appearance: cluster.appearance.copyWith(
              opacity: 1,
              text: PlacemarkText(text: count.toString(),
                  style: PlacemarkTextStyle(color: Colors.blue[900], size: 16)),
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
  Future<bool> _fetchCurrentLocation() async
  {
    var location = await _mapController?.getUserCameraPosition();
    if (location == null) {
      return false;
    }
    globalHandler.currentUserPoint = location.target;
    return true;
  }

  /// Метод для показа текущей позиции
  Future<void> _moveToCurrentLocation(
      {CameraPosition? newPoint, double? zoom}) async
  {
    CameraPosition? point = newPoint ??
        await _mapController?.getUserCameraPosition();
    if (point == null) {
      return;
    }
    await _mapController?.moveCamera(
      animation: const MapAnimation(type: MapAnimationType.linear, duration: 1),
      CameraUpdate.newCameraPosition(
        point.copyWith(zoom: zoom ?? 18),
      ),
    );
  }

  void _shopInfo(InternalShop shop)async
  {
    if(!await _fetchCurrentLocation()){
      if(context.mounted) {
        customAlertMsg(context, 'Не получилось определить место');
      }
      return;
    }
    if(sqlFliteDB.getDistance(shop) > 50 * 50){
      if(context.mounted) {
        customAlertMsg(context, 'Слишком далеко от магазина!');
        return;
      }
    }
    if(context.mounted) {
      Navigator.of(context).pushNamed('/shopPage', arguments: shop);
    }
  }

  Future<void> _logOut(BuildContext context) async
  {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Выйти из аккаунта?'),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme
                    .of(context)
                    .textTheme
                    .labelLarge,
              ),
              child: const Text('Ок'),
              onPressed: () {
                mainShared?.setString('login', '');
                mainShared?.setString('pwd', '');
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login', (route) => false);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme
                    .of(context)
                    .textTheme
                    .labelLarge,
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
}
