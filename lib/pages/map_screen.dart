import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shop_audit/component/dynamic_alert_msg.dart';
import 'package:shop_audit/component/internal_shop.dart';
import 'package:shop_audit/global/socket_handler.dart';
import 'package:shop_audit/main.dart';
import 'package:shop_audit/pages/camera_handler.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:shop_audit/global/shop_points_for_job.dart';
import 'package:http/http.dart';

class MapScreen extends StatefulWidget
{
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
{
  YandexMapController? _mapController;
  Map<int, PlacemarkMapObject> _mapObjects = {};
  late Timer _timerSelfLocation;
  late Timer _timerSetMyLocation;
  bool _isReconnect = false;
  int _mapIdCluster = 0;

  @override
  void initState()
  {
    pointFromDbHandler.pointsFromDb.addListener(_changeObjects);
    socketHandler.socketState.addListener(checkReconnect);
    _timerSelfLocation =
        Timer.periodic(const Duration(seconds: 1), (timer) async {
          _fetchCurrentLocation();
        });
    _timerSetMyLocation = Timer.periodic(const Duration(seconds: 50), (timer) {
      socketHandler.sendMyPosition(globalHandler.currentUserPoint.latitude,
          globalHandler.currentUserPoint.longitude);
    });
    socketHandler.getCurrentBuild(_downloadFile);
    socketHandler.loadShops(false);
    socketHandler.resendShopList = _printResendedReports;
    super.initState();
  }

  void reloadAll()
  {
    setState(() {
      _mapObjects = {};
    });
    socketHandler.loadShops(true);
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
    _timerSelfLocation.cancel();
    _timerSetMyLocation.cancel();
    pointFromDbHandler.pointsFromDb.removeListener(_changeObjects);
    socketHandler.socketState.removeListener(checkReconnect);
    socketHandler.resendShopList = null;
    super.dispose();
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

  void _refreshActiveShops()
  {
    _activeShops.clear();
    var currLoc = globalHandler.currentUserPoint;
    for (int i = 0; i < _sourcePoints.length; i++) {
      if (((_sourcePoints[i].xCoord - currLoc.latitude) * metersInOneAngle).abs() >
          30) {
        continue;
      }
      if (((_sourcePoints[i].yCoord - currLoc.longitude) * metersInOneAngle).abs() >
          30) {
        continue;
      }
      if ((pow(_sourcePoints[i].xCoord - currLoc.latitude, 2) +
          pow(_sourcePoints[i].yCoord - currLoc.longitude, 2)) * metersInOneAngle >
          pow(30, 2)) {
        continue;
      }
      _activeShops.add(_sourcePoints[i].id);
    }
  }


  Map<int, PlacemarkMapObject> returnListMapObjects()
  {
    Map<int, PlacemarkMapObject> newList = {};
    _sourcePoints.clear();
    _sourcePoints = pointFromDbHandler.getFilteredPoints();
    for (var key in _sourcePoints) {
      newList.putIfAbsent(key.id, () => _createPlaceMark(key));
    }
    return newList;
  }

  void _changeObjects()
  {
    Map<int, PlacemarkMapObject> newList = returnListMapObjects();
    setState(() {
      _mapObjects = newList;
    });
  }

  PlacemarkMapObject _createPlaceMark(InternalShop point)
  {
    final mapObject = PlacemarkMapObject(
        mapId: MapObjectId('${point.id}'),
        point: Point(latitude: point.xCoord, longitude: point.yCoord),
        onTap: (PlacemarkMapObject mapObject, Point point) async {
          await _shopInfo(context, mapObject);
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
            text: point.shopName,
            style: const PlacemarkTextStyle(
                placement: TextStylePlacement.top,
                color: Colors.amber,
                outlineColor: Colors.black
            )
        )
    );
    return mapObject;
  }

  void _printResendedReports(List<String> shopIds)
  {
    String text = shopIds.isEmpty
        ? 'Нет неотправленных отчётов'
        : 'Отчеты отправлены по ID: $shopIds';
    customAlertMsg(context, text);
  }

  @override
  Widget build(BuildContext context)
  {
    var allList = pointFromDbHandler.pointsFromDb.value.values.toList();
    return Scaffold(
        drawerEnableOpenDragGesture: false,
        drawer: Drawer(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 35,),
                  ElevatedButton(
                    onPressed: () {
                      sqlFliteDB.resendShops();
                    },
                    child: const Text('Отправить всё повторно'),
                  ),
                  Expanded(
                      child:
                      ListView.builder(
                          itemCount: allList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Row(
                                children:[
                                  Image.asset(allList[index].photoMap['externalPhoto']!, width: 50,height: 50, fit: BoxFit.contain,),
                                  Expanded(
                                      child: TextButton(
                                          onPressed:(){
                                            globalHandler.activeShopId = allList[index].id;
                                            Navigator.of(context).pushNamed('/shopPage');
                                          },
                                          child: Text(allList[index].shopName.trim(),
                                              style: const TextStyle(
                                                  color: Colors.black)
                                          ))
                                  ),
                                  IconButton(onPressed: (){
                                    if (Platform.isAndroid) {
                                      AndroidIntent intent = AndroidIntent(
                                        action: 'action_view',
                                        data: 'geo:${allList[index]
                                            .xCoord},${allList[index].yCoord}',
                                        package: 'com.google.android.apps.maps',
                                      );
                                      intent.launch();
                                    }
                                  }, icon: const Icon(Icons.map)),
                                  IconButton(onPressed: () {
                                    _moveToCurrentLocation(newPoint: CameraPosition(
                                        target: Point(latitude: allList[index].xCoord,
                                            longitude: allList[index].yCoord)));
                                    Scaffold.of(context).closeDrawer();
                                  }, icon: const Icon(Icons.gps_fixed))
                                ]);
                          }
                      )
                  ),
                  IconButton(onPressed: () {
                    _logOut(context);
                  }, icon: const Icon(Icons.logout_outlined))
                ]
            )
        ),
        appBar: AppBar(
          actions: [
            ValueListenableBuilder(valueListenable: sqlFliteDB.hasReports, builder: (context, value, child) {
              return Text('$value отчётов из ');
            }),
            ValueListenableBuilder(valueListenable: sqlFliteDB.allShops, builder: (context, value, child) {
              return Text('$value');
            }),
            ElevatedButton(onPressed: () {},
                child: const Icon(Icons.refresh)),
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
                  _getClusterizedCollection(
                      placemarks: _mapObjects.values.toList())
                ],
                onMapCreated: (controller) {
                  _mapController = controller;
                  _mapController?.toggleUserLayer(visible: true);
                },
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: FloatingActionButton(
                    child: const Icon(Icons.add_shopping_cart),
                    onPressed: () async {
                      Navigator.of(context).pushNamed('/newShop');
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
                            child: const Icon(Icons.zoom_in),
                            onPressed: () async {
                              _mapController?.moveCamera(CameraUpdate.zoomIn());
                            }
                        ),
                        const SizedBox(height: 10,),
                        FloatingActionButton(
                            child: const Icon(Icons.zoom_out),
                            onPressed: () async {
                              _mapController?.moveCamera(
                                  CameraUpdate.zoomOut());
                            }
                        ),
                        const SizedBox(height: 10,),
                        FloatingActionButton(
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

  ClusterizedPlacemarkCollection _getClusterizedCollection(
      {required List<PlacemarkMapObject> placemarks})
  {
    return ClusterizedPlacemarkCollection(
        mapId: MapObjectId(_getUUID().toString()),
        placemarks: placemarks,
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
  Future<void> _fetchCurrentLocation() async
  {
    var location = await _mapController?.getUserCameraPosition();
    if (location == null) {
      return;
    }
    globalHandler.currentUserPoint = location.target;
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

  Future<void> _shopInfo(BuildContext context, PlacemarkMapObject mapObject)
  {
    int shopId = int.parse(mapObject.mapId.value);
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(pointFromDbHandler.pointsFromDb.value[shopId]!.shopName),
          content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Адрес: ${pointFromDbHandler.pointsFromDb.value[shopId]!
                    .address}'),
                Text('ID: ${pointFromDbHandler.pointsFromDb.value[shopId]!
                    .id}'),
                // Text('Дата создания: ${presentDateTime(
                //     pointFromDbHandler.pointsFromDb.value[shopId]!
                //         .dateTimeCreated)}'),
              ]
          ),
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
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
