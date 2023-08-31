import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shop_audit/component/dynamic_alert_msg.dart';
import 'package:shop_audit/global/shop_points_for_job.dart';
import 'package:shop_audit/global/socket_handler.dart';

class ReportPage extends StatefulWidget
{
  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final TextEditingController _textController = TextEditingController();

  List<XFile> _images = [];
  List<XFile> _backupImages = [];

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    _images = [];
    super.initState();
  }

  @override
  void dispose()
  {
    _textController.dispose();
    _images = [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Отчёт'),
          actions: [
            IconButton(
              onPressed: (){
                List<String> paths = [];
                for(XFile image in _images){
                  paths.add(image.path);
                }
                SocketHandler().sendReport(paths,_textController.text, PointFromDbHandler().activeShop);
                Navigator.pop(context);
              },
              icon: Icon(Icons.send),
            )
          ],
        ),
        body: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Текстовое описание'),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  controller: _textController,
                  minLines: null,
                  maxLines: null,
                  expands: true,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      onPressed: ()async{
                        final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
                        if(photo != null){
                          _images.add(photo);
                        }
                      },
                      icon: const Icon(Icons.photo_camera)),
                  IconButton(
                      onPressed: ()async{
                        final List<XFile> images = await _picker.pickMultiImage();
                        for(XFile image in images){
                          _images.add(image);
                        }
                      }
                      , icon: const Icon(Icons.photo)),
                  ElevatedButton(
                      onPressed: ()async{
                        if(_images.isEmpty){
                          customAlertMsg(context, 'Нет фотографий для отчёта');
                          return;
                        }
                        _backupImages = List.unmodifiable(_images);
                        await _variantPhotos(context);
                      },
                      child: const Text('Редактировать фотографии')),
                ],
              ),

            ]
        )
    );
  }

  Future<void> _variantPhotos(BuildContext context) async
  {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(),
          body: Column(
              children: [
                Expanded(
                    child:ListView.separated(
                        separatorBuilder: (BuildContext context, int index) => const Divider(),
                        itemCount: _images.length,
                        itemBuilder: (BuildContext context, int index){
                          return Dismissible(
                              key: Key(_images[index].path),
                              onDismissed: (direction) {
                                _images.removeWhere((element) => element.path == _backupImages[index].path);
                                if(_images.isEmpty){
                                  Navigator.of(context).pop();
                                }
                              },
                              child: Row(
                                  children: [
                                    Image.file(
                                      File(_images[index].path),
                                      height: 150,
                                    ),
                                    Text('Смахните, что удалить')
                                  ]
                              )
                          );
                        }
                    )
                )
              ]
          ),
        );
      },
    );
  }
}
