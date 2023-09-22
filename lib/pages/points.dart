// import 'dart:async';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:shop_audit/global/shop_points_for_job.dart';
// import 'package:shop_audit/global/socket_handler.dart';
// import 'package:shop_audit/main.dart';
//
// class CustomCheck extends Checkbox
// {
//   CustomCheck({required super.value, required super.onChanged});
// }
//
// class PointsPage extends StatefulWidget
// {
//   @override
//   State<PointsPage> createState() => _PointsPageState();
// }
//
// class _PointsPageState extends State<PointsPage> {
//
//   List<PointFromDb> listAllPoints = [];
//   Map<int,int> _shopIdAim = {}; //shopId userId
//   late Timer _timerSelfLocation;
//
//   @override
//   void initState() {
//     listAllPoints = PointFromDbHandler().pointsFromDb.value.values.toList();
//     PointFromDbHandler().pointsFromDb.addListener(_updateListAllPoint);
//     _shopIdAim = PointFromDbHandler().userActivePoints.value;
//     PointFromDbHandler().userActivePoints.addListener(_changeUsersAim);
//     _timerSelfLocation = Timer.periodic(const Duration(seconds: 10),(timer){
//       SocketHandler().getAims(false);
//     });
//     super.initState();
//   }
//
//   void _changeUsersAim()
//   {
//     setState(() {
//       _shopIdAim = PointFromDbHandler().userActivePoints.value;
//     });
//   }
//
//
//   @override
//   void dispose() {
//     PointFromDbHandler().pointsFromDb.removeListener(_updateListAllPoint);
//     PointFromDbHandler().userActivePoints.removeListener(_changeUsersAim);
//     _timerSelfLocation.cancel();
//     super.dispose();
//   }
//
//   void _updateListAllPoint()
//   {
//     setState(() {
//       listAllPoints = PointFromDbHandler().pointsFromDb.value.values.toList();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(),
//         body: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children:[
//               ElevatedButton(onPressed: (){
//                 PointFromDbHandler().showAllPointByUser();
//                 PointFromDbHandler().pointsFromDb.notifyListeners();
//               }, child: Text('Сбросить отмеченные ыручную')
//               ),
//               ElevatedButton(onPressed: (){
//                 PointFromDbHandler().sortType = SortType.None;
//                 PointFromDbHandler().showAllPointByUser();
//                 PointFromDbHandler().pointsFromDb.notifyListeners();
//               }, child: Text('Все')
//               ),
//               ElevatedButton(onPressed: (){
//                 PointFromDbHandler().sortType = SortType.Distance;
//                 PointFromDbHandler().showAllPointByUser();
//                 PointFromDbHandler().pointsFromDb.notifyListeners();
//               }, child: Text('Ближе 5 километров')
//               ),
//               ElevatedButton(onPressed: (){
//                 PointFromDbHandler().sortType = SortType.DateTimeCreated;
//                 PointFromDbHandler().showAllPointByUser();
//                 PointFromDbHandler().pointsFromDb.notifyListeners();
//               }, child: Text('За последний месяц')
//               ),
//               Expanded(
//                   child:
//                   ListView.builder(
//                       itemCount: listAllPoints.length,
//                       itemBuilder: (BuildContext context, int index) {
//                         return Row(children:
//                         [
//                           Checkbox(
//                             value: PointFromDbHandler().isNeedShop(listAllPoints[index].id),
//                             onChanged: (val){
//                               if(val == true){
//                                 PointFromDbHandler().pointsFromDb.value[listAllPoints[index].id]!.isNeedDrawByCustom = true;
//                               }else{
//                                 PointFromDbHandler().pointsFromDb.value[listAllPoints[index].id]!.isNeedDrawByCustom = false;
//                               }
//                               PointFromDbHandler().pointsFromDb.notifyListeners();
//                             },
//                           ),
//                           Expanded(
//                           child: Text(listAllPoints[index].address + ', ' + listAllPoints[index].name,
//                               style: TextStyle(
//                                 color: getColor(listAllPoints[index].id)
//                               ))
//                           ),
//
//                         ]);
//                       }
//                   )
//               )
//             ]
//         )
//     );
//   }
//
//   Color getColor(int id)
//   {
//     if(_shopIdAim.containsValue(id)){
//       if(_shopIdAim.containsKey(mainShared?.getInt('userId')) && _shopIdAim[mainShared?.getInt('userId')] == id){
//         return Colors.red;
//       }else{
//         return Colors.yellow;
//       }
//     }
//     return Colors.black;
//   }
// }