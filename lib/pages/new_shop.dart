

import 'package:flutter/material.dart';
import 'package:shop_audit/component/internal_shop.dart';
import 'package:shop_audit/global/global_variants.dart';
import 'package:shop_audit/main.dart';

ShopType? _character = ShopType.none;

class NewShopPage extends StatelessWidget
{
  NewShopPage({Key? key}) : super(key: key);
  final TextEditingController _textController = TextEditingController();

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
                  const ShopTypeRadio(),
                  TextButton(onPressed: ()async{
                    if(_textController.text == '' || _character == ShopType.none){
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Нет названия магазина или не указан тип строения'),duration: Duration(seconds: 2),));
                    }else {
                      int id = await sqlFliteDB.addShop(_textController.text, _character!);
                      print(id);
                      if(id == 0){
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ошибка добавления магазина!'),duration: Duration(seconds: 2),));
                      }else{
                        Navigator.of(context).popAndPushNamed('/shopPage',arguments: CustomArgument(shopId: id));
                      }
                    }
                  },
                    style: TextButton.styleFrom(side: const BorderSide(color: Colors.black)),
                    child: const Text('Добавить магазин'),
                  )
                ]
            )
        )
    );
  }
}

class ShopTypeRadio extends StatefulWidget {
  const ShopTypeRadio({super.key});

  @override
  State<ShopTypeRadio> createState() => _ShopTypeRadioState();
}

class _ShopTypeRadioState extends State<ShopTypeRadio> {


  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: const Text('В жилом доме'),
          leading: Radio<ShopType>(
            value: ShopType.inHomeShop,
            groupValue: _character,
            onChanged: (ShopType? value) {
              setState(() {
                _character = value;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Отдельное строение'),
          leading: Radio<ShopType>(
            value: ShopType.oneBuilding,
            groupValue: _character,
            onChanged: (ShopType? value) {
              setState(() {
                _character = value;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Павильон в магазине'),
          leading: Radio<ShopType>(
            value: ShopType.pavilon,
            groupValue: _character,
            onChanged: (ShopType? value) {
              setState(() {
                _character = value;
              });
            },
          ),
        ),
      ],
    );
  }
}