

import 'package:flutter/material.dart';
import 'package:shop_audit/component/dynamic_alert_msg.dart';
import 'package:shop_audit/global/socket_handler.dart';

class NewShopPage extends StatelessWidget
{
  NewShopPage({Key? key}) : super(key: key);
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _textDesc = TextEditingController();
//
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Новый магазин'),
        ),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children:[
                  const Text('Введите имя магазина:'),
                  TextField(
                    decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.never, //Hides label on focus or if filled
                      labelText: "Обязательно",
                      filled: true, // Needed for adding a fill color
                      fillColor: Colors.orange[100],
                      isDense: true,  // Reduces height a bit
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,              // No border
                        borderRadius: BorderRadius.circular(12),  // Apply corner radius
                      ),
                    ),
                    controller: _textController,
                  ),
                  const SizedBox(height: 15,),
                  const Text('Описание магазина:'),
                  TextField(
                    maxLines: 3,
                    controller: _textDesc,
                    decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.never, //Hides label on focus or if filled
                      labelText: "Не обязательно",
                      filled: true, // Needed for adding a fill color
                      fillColor: Colors.orange[100],
                      isDense: true,  // Reduces height a bit
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,              // No border
                        borderRadius: BorderRadius.circular(12),  // Apply corner radius
                      ),
                    ),
                  ),
                  TextButton(onPressed: (){
                    if(SocketHandler().socketState.value != SocketState.connected){
                      customAlertMsg(context, 'Нет соединения с сервером! Подождите немного!');
                      return;
                    }
                    if(_textController.text == ''){
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Введите название магазина!'),duration: Duration(seconds: 3),));
                    }else {
                      SocketHandler().addShop(_textController.text, _textDesc.text);
                      Navigator.of(context).pop();
                    }
                  },
                    style: TextButton.styleFrom(side: const BorderSide(color: Colors.black)),
                    child: const Text('Добавить'),
                  )
                ]
            )
        )
    );
  }
}