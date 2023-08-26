import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shop_audit/component/dynamic_alert_msg.dart';

class ReportPage extends StatefulWidget
{
  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final TextEditingController _textController = TextEditingController();

  List<XFile> _images = [];

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
              onPressed: (){},
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
                        if(_images.length == 0){
                          customAlertMsg(context, 'Нет фотографий для отчёта');
                          return;
                        }
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
                        itemCount: _images.length,
                        itemBuilder: (BuildContext context, int index){
                          return Row(
                              children: [
                                Image.file(
                                  File(_images[index].path),
                                  height: 50,
                                ),
                                IconButton(
                                  onPressed: (){
                                    setState(() {
                                      _images.removeAt(index);
                                      if(_images.length == 0){
                                        Navigator.of(context).pop();
                                      }
                                    });
                                  },
                                  icon: Icon(Icons.delete_forever),)
                              ]
                          );
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