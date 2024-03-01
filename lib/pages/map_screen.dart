import 'dart:async';
import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shop_audit/component/dynamic_alert_msg.dart';
import 'package:shop_audit/component/internal_shop.dart';
import 'package:shop_audit/global/global_variants.dart';
import 'package:shop_audit/global/internalDatabase.dart';
import 'package:shop_audit/global/socket_handler.dart';
import 'package:shop_audit/main.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
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
  SortType sortType = SortType.none;

  @override
  void initState()
  {
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
    var source = sqlFliteDB.getFilteredPoints(sortType);
    for(int i=0;i<source.length;i++) {
      final mapObject = PlacemarkMapObject(
          mapId: MapObjectId('${source[i].id}'),
          point: Point(latitude: source[i].xCoord, longitude: source[i].yCoord),
          onTap: (PlacemarkMapObject mapObject, Point point) {
            _shopInfo(context, mapObject);
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
              text: source[i].shopName,
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

  @override
  Widget build(BuildContext context)
  {
    var allList = sqlFliteDB.getFilteredPoints(sortType);
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
                            return Container(
                                margin: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  border: Border.all(width: 1, color: Colors.transparent),
                                  color: allList[index].hasReport ? Colors.white : allList[index].isSending ? Colors.amber[100] : Colors.red[100],
                                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),

                                ),
                                child:
                                Row(
                                    children:[
                                      allList[index].photoMap['externalPhoto']! == '' ? const SizedBox(height: 50,) :
                                      Image.file(File(allList[index].photoMap['externalPhoto']!), width: 50,height: 50, fit: BoxFit.cover,),
                                      Expanded(
                                          flex: 20,
                                          child: TextButton(
                                              onPressed:(){
                                                Navigator.of(context).pushNamed('/shopPage', arguments: CustomArgument(shopId: allList[index].id));
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
                                    ]
                                )
                            );
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
            Expanded(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children:[
                    Text('${sqlFliteDB.hasReportCount} отчётов из ${sqlFliteDB.shops.length}'),]),),
            ElevatedButton(onPressed: () {
              setState(() {
                sqlFliteDB.nonReportShops();
              });
            },
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
                  _getClusterizedCollection()
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
                            heroTag: "btn2",
                            child: const Icon(Icons.zoom_in),
                            onPressed: () async {
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

  void _shopInfo(BuildContext context, PlacemarkMapObject mapObject)
  {
    int shopId = int.parse(mapObject.mapId.value);
    Navigator.of(context).pushNamed('/shopPage', arguments: CustomArgument(shopId: shopId));
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
