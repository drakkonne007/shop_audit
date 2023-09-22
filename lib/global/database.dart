//
// import 'package:postgres/postgres.dart';
// import 'package:shop_audit/global/shop_points_for_job.dart';
// import 'package:yandex_mapkit/yandex_mapkit.dart';
//
//
// class DatabaseClient
// {
//   static final DatabaseClient _databaseClient = DatabaseClient._internal();
//   factory DatabaseClient() {
//     return _databaseClient;
//   }
//   DatabaseClient._internal();
//
//   var connection = PostgreSQLConnection("195.38.167.138", 5432, "shop_audit_clear", username: "shop_audit", password: "123", allowClearTextPassword: true);
//   int auditorId = 0;
//
//   Future<bool> openDB()async
//   {
//     await connection.open();
//     if(connection.isClosed){
//       return false;
//     }
//     return true;
//   }
//
//   void getShopPoints() async
//   {
//     var result = await connection.query("SELECT id,address_for_yandex,x,y FROM shop_audit_clear.shop WHERE (x = 0 OR y = 0) AND enabled = true ORDER BY id");
//     var columnNames = result.columnDescriptions;
//     Map<int,PointFromDb> _source = {};
//     Map<String,int> map = {};
//     for(int i=0;i<columnNames.length;i++){
//       map.putIfAbsent(columnNames[i].columnName, () => i);
//     }
//     for (final row in result) {
//       PointFromDb point = PointFromDb();
//       if(map.containsKey('address_for_yandex')){
//         point.address = row[map['address_for_yandex']!] ?? '';
//       }
//       if(map.containsKey('id')){
//         point.id = row[map['id']!] as int;
//       }
//       _source.putIfAbsent(point.id, () => point);
//     }
//     for(var key in _source.keys){
//       final resultWithSession = YandexSearch.searchByText(
//         searchText: _source[key]!.address,
//         geometry: Geometry.fromBoundingBox(
//             const BoundingBox(
//               southWest: Point(latitude: 39.091001, longitude: 68.974012),
//               northEast: Point(latitude: 43.353434, longitude: 80.355386),
//             )
//         ),
//         searchOptions: const SearchOptions(
//           searchType: SearchType.geo,
//           geometry: true,
//         ),
//       );
//       var ress = await resultWithSession.result;
//       try {
//         if (ress.items != null && ress.items!.first.toponymMetadata != null &&
//             ress.items!.first.toponymMetadata != null) {
//           connection.execute(
//               "UPDATE shop_audit_clear.shop SET x = ${ress.items!.first
//                   .toponymMetadata!.balloonPoint.latitude}, y = ${ress.items!
//                   .first.toponymMetadata!.balloonPoint
//                   .longitude} WHERE id = $key");
//         }
//       }catch(e){
//         connection.execute("UPDATE shop_audit_clear.shop SET x = -1, y = -1 WHERE id = $key");
//       }
//       // print(ress.items?.first.toponymMetadata?.balloonPoint);
//       // double latitude = ress.items!.first.toponymMetadata!.balloonPoint.latitude;
//       // double longitude = ress.items!.first.toponymMetadata!.balloonPoint.longitude;
//       // print(PointFromDbHandler().pointsFromDb.value[key]!.address);
//       // print(latitude);
//       // print(longitude);
//       // if(latitude != 0 && longitude != 0){
//       //   await connection.execute('UPDATE shop_audit_clear.shop SET x = $latitude, y = $longitude WHERE id = $key');
//       // }
//     }
//   }
//
//   Future<bool> checkAccess(String login, String password)async
//   {
//     var result = await connection.query("SELECT id FROM shop_audit_clear.user WHERE login='$login' AND password='$password' AND enabled=true LIMIT 1");
//     if(result.isEmpty){
//       return false;
//     }
//     auditorId = result.first[0];
//     return true;
//   }
// }