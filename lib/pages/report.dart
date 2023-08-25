import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shop_audit/component/camera_handler.dart';
import 'package:shop_audit/component/dynamic_alert_msg.dart';

class ReportPage extends StatelessWidget
{
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
                child:ListView(
                    children:[
                      TextField(
                        minLines: 1,
                        maxLines: null,
                        expands: true,
                      ),
                    ]
                ),
              ),
              ElevatedButton(onPressed: ()async{
                if(CameraHandler().cameras != null) {
                  Navigator.of(context).pushNamed('/photoPage');
                }else{
                  await customAlertMsg(context,'Нет доступа к камере!');
                }
              },
                  child: const Text('Сделать фотографию'))
            ]
        )
    );
  }

}