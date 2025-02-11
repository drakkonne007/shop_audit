// import 'dart:io';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:shop_audit/component/dynamic_alert_msg.dart';
// import 'package:shop_audit/global/global_variants.dart';
// import 'package:shop_audit/global/socket_handler.dart';
// import 'package:shop_audit/main.dart';
// import 'package:shop_audit/pages/camera_handler.dart';
//
// class ReportPage extends StatelessWidget
// {
//   final TextEditingController _textController = TextEditingController();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: Text('Отчёт: ${globalHandler.activeShopName}'),
//           actions: [
//             IconButton(
//               onPressed: (){
//                 List<String> paths = CameraHandler().imagePaths;
//                 int toSend = globalHandler.activeShop;
//                 socketHandler.sendReport(paths,_textController.text, toSend);
//                 globalHandler.activeShop = 0;
//                 globalHandler.activeShopName = '';
//                 Navigator.of(context).pushNamedAndRemoveUntil('/mapScreen', (route) => false);
//               },
//               icon: const Icon(Icons.send),
//             )
//           ],
//         ),
//         body: Column(
//             mainAxisSize: MainAxisSize.min,
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               const Text('Текстовое описание'),
//               Expanded(
//                 child: TextField(
//                   decoration: const InputDecoration(
//                     border: OutlineInputBorder(),
//                   ),
//                   controller: _textController,
//                   minLines: null,
//                   maxLines: null,
//                   expands: true,
//                 ),
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   IconButton(
//                       onPressed: () async{
//                         CameraHandler().loadCameras().then((value){Navigator.of(context).pushNamed('/photoPage');});
//                         // List<XFile> photo = await _picker.pickMultiImage(maxHeight: 800, maxWidth: 800, imageQuality: 100);
//                         // for(XFile photo in photo){
//                         //   _images.add(photo);
//                         // }
//                       },
//                       icon: const Icon(Icons.photo_camera)),
//                   ElevatedButton(
//                       onPressed: ()async{
//                         if(CameraHandler().imagePaths.isEmpty){
//                           customAlertMsg(context, 'Нет фотографий для отчёта');
//                           return;
//                         }
//                         List<String> curs = List.unmodifiable(CameraHandler().imagePaths);
//                         await _variantPhotos(context,curs);
//                       },
//                       child: const Text('Редактировать фотографии')),
//                 ],
//               ),
//
//             ]
//         )
//     );
//   }
//
//   Future<void> _variantPhotos(BuildContext context, List<String> curs) async
//   {
//     return showDialog<void>(
//       context: context,
//       builder: (BuildContext context) {
//         return Scaffold(
//           appBar: AppBar(),
//           body: Column(
//               children: [
//                 Expanded(
//                     child:ListView.separated(
//                         separatorBuilder: (BuildContext context, int index) => const Divider(),
//                         itemCount: CameraHandler().imagePaths.length,
//                         itemBuilder: (BuildContext context, int index){
//                           return Dismissible(
//                               key: Key(index.toString()),
//                               onDismissed: (direction) {
//                                 CameraHandler().imagePaths.removeWhere((element) => element == curs[index]);
//                                 if(CameraHandler().imagePaths.isEmpty){
//                                   Navigator.of(context).pop();
//                                 }
//                               },
//                               child: Row(
//                                   children: [
//                                     Image.file(
//                                       File(CameraHandler().imagePaths[index]),
//                                       height: 200,
//                                     ),
//                                     const Text('Смахните, что удалить')
//                                   ]
//                               )
//                           );
//                         }
//                     )
//                 )
//               ]
//           ),
//         );
//       },
//     );
//   }
// }
