import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shop_audit/component/internal_shop.dart';
import 'package:shop_audit/global/global_variants.dart';
import 'package:shop_audit/main.dart';

class ShopPage extends StatelessWidget
{
  @override
  Widget build(BuildContext context)
  {
    final args = ModalRoute.of(context)?.settings.arguments as CustomArgument;
    var currShop = sqlFliteDB.shops[args.shopId]!;
    return Scaffold(
      appBar: AppBar(
        title: Text(currShop.shopName),
        actions: [
          ElevatedButton(
            child: const Text('Отослать'),
            onPressed: currShop.hasReport ? null : (){
              sqlFliteDB.sendShopToServer([currShop]);
              Navigator.of(context).pop();
            },
          )
        ]
      ),
      body: ListView(
          children: [
            ElevatedButton(child: const Text('Анкета'), onPressed: (){
              Navigator.of(context).popAndPushNamed('/anketaPage',arguments: CustomArgument(shopId: args.shopId));
            }),
            Table(
                  children: [
                    TableRow(
                        children: [
                          ElevatedButton(onPressed: ()async{
                            if(currShop.photoMap['externalPhoto'] != ''){
                              bool? isShow = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  content: const Text('Фото снаружи уже есть, хотите перезаписать?'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Нет'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Да'),
                                    ),
                                  ],
                                ),
                              );
                              if(isShow != null && isShow){
                                Navigator.of(context).popAndPushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.externalPhoto));
                              }
                            }else{
                              Navigator.of(context).popAndPushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.externalPhoto));
                            }
                          }, child: null,
                              style: const ButtonStyle().copyWith(shape: MaterialStateProperty.all<RoundedRectangleBorder>(const RoundedRectangleBorder()),
                                  foregroundBuilder: ((context, state, child){
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        currShop.photoMap['externalPhoto']! == '' ? const SizedBox(height: 100,) : Image.file(File(currShop.photoMap['externalPhoto']!),width: 50,height: 100,),
                                        const Text('Фото снаружи')
                                      ],
                                    );
                                  })
                              )
                          ),
                          ElevatedButton(onPressed: ()async{
                            if(currShop.photoMap['shopLabelPhoto'] != ''){
                              bool? isShow = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  content: const Text('Фото вывески уже есть, хотите перезаписать?'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Нет'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Да'),
                                    ),
                                  ],
                                ),
                              );
                              if(isShow != null && isShow){
                                Navigator.of(context).popAndPushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.shopLabelPhoto));
                              }
                            }else{
                              Navigator.of(context).popAndPushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.shopLabelPhoto));
                            }
                          }, child: null,
                              style: const ButtonStyle().copyWith(shape: MaterialStateProperty.all<RoundedRectangleBorder>(const RoundedRectangleBorder()),
                                  foregroundBuilder: ((context, state, child){
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        currShop.photoMap['shopLabelPhoto']! == '' ? const SizedBox(height: 100,) : Image.file(File(currShop.photoMap['shopLabelPhoto']!),width: 50,height: 100,),
                                        const Text('Вывеска')
                                      ],
                                    );
                                  })
                              )
                          ),
                        ]
                    ),
                    TableRow(
                        children: [
                          ElevatedButton(onPressed: ()async{
                            if(currShop.photoMap['alkoholPhoto'] != ''){
                              bool? isShow = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  content: const Text('Фото алкоголя уже есть, хотите перезаписать?'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Нет'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Да'),
                                    ),
                                  ],
                                ),
                              );
                              if(isShow != null && isShow){
                                Navigator.of(context).popAndPushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.alkoholPhoto));
                              }
                            }else{
                              Navigator.of(context).popAndPushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.alkoholPhoto));
                            }
                          }, child: null,
                              style: const ButtonStyle().copyWith(shape: MaterialStateProperty.all<RoundedRectangleBorder>(const RoundedRectangleBorder()),
                                  foregroundBuilder: ((context, state, child){
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        currShop.photoMap['alkoholPhoto']! == '' ? const SizedBox(height: 100,) : Image.file(File(currShop.photoMap['alkoholPhoto']!),width: 50,height: 100,),
                                        const Text('Алкоголь')
                                      ],
                                    );
                                  })
                              )
                          ),
                          ElevatedButton(onPressed: ()async{
                            if(currShop.photoMap['nonAlkoholPhoto'] != ''){
                              bool? isShow = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  content: const Text('Фото безалкогольной продукции уже есть, хотите перезаписать?'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Нет'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Да'),
                                    ),
                                  ],
                                ),
                              );
                              if(isShow != null && isShow){
                                Navigator.of(context).popAndPushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.nonAlkoholPhoto));
                              }
                            }else{
                              Navigator.of(context).popAndPushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.nonAlkoholPhoto));
                            }
                          }, child: null,
                              style: const ButtonStyle().copyWith(shape: MaterialStateProperty.all<RoundedRectangleBorder>(const RoundedRectangleBorder()),
                                  foregroundBuilder: ((context, state, child){
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        currShop.photoMap['nonAlkoholPhoto']! == '' ? const SizedBox(height: 100,) : Image.file(File(currShop.photoMap['nonAlkoholPhoto']!),width: 50,height: 100,),
                                        const Text('Без алкоголь')
                                      ],
                                    );
                                  })
                              )
                          ),
                        ]
                    ),

                    TableRow(
                        children: [
                          ElevatedButton(onPressed: ()async{
                            if(currShop.photoMap['kolbasaSyr'] != ''){
                              bool? isShow = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  content: const Text('Фото колбасы и сыра уже есть, хотите перезаписать?'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Нет'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Да'),
                                    ),
                                  ],
                                ),
                              );
                              if(isShow != null && isShow){
                                Navigator.of(context).popAndPushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.kolbasaSyr));
                              }
                            }else{
                              Navigator.of(context).popAndPushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.kolbasaSyr));
                            }
                          }, child: null,
                              style: const ButtonStyle().copyWith(shape: MaterialStateProperty.all<RoundedRectangleBorder>(const RoundedRectangleBorder()),
                                  foregroundBuilder: ((context, state, child){
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        currShop.photoMap['kolbasaSyr']! == '' ? const SizedBox(height: 100,) : Image.file(File(currShop.photoMap['kolbasaSyr']!),width: 50,height: 100,),
                                        const Text('Колбаса и сыр')
                                      ],
                                    );
                                  })
                              )
                          ),
                          ElevatedButton(onPressed: ()async{
                            if(currShop.photoMap['milk'] != ''){
                              bool? isShow = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  content: const Text('Фото молочной продукции уже есть, хотите перезаписать?'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Нет'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Да'),
                                    ),
                                  ],
                                ),
                              );
                              if(isShow != null && isShow){
                                Navigator.of(context).popAndPushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.milk));
                              }
                            }else{
                              Navigator.of(context).popAndPushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.milk));
                            }
                          }, child: null,
                              style: const ButtonStyle().copyWith(shape: MaterialStateProperty.all<RoundedRectangleBorder>(const RoundedRectangleBorder()),
                                  foregroundBuilder: ((context, state, child){
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        currShop.photoMap['milk']! == '' ? const SizedBox(height: 100,) : Image.file(File(currShop.photoMap['milk']!),width: 50,height: 100,),
                                        const Text('Молочка')
                                      ],
                                    );
                                  })
                              )
                          ),
                        ]
                    ),

                    TableRow(
                        children: [
                          ElevatedButton(onPressed: ()async{
                            if(currShop.photoMap['snack'] != ''){
                              bool? isShow = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  content: const Text('Фото снэков уже есть, хотите перезаписать?'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Нет'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Да'),
                                    ),
                                  ],
                                ),
                              );
                              if(isShow != null && isShow){
                                Navigator.of(context).popAndPushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.snack));
                              }
                            }else{
                              Navigator.of(context).popAndPushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.snack));
                            }
                          }, child: null,
                              style: const ButtonStyle().copyWith(shape: MaterialStateProperty.all<RoundedRectangleBorder>(const RoundedRectangleBorder()),
                                  foregroundBuilder: ((context, state, child){
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        currShop.photoMap['snack']! == '' ? const SizedBox(height: 100,) : Image.file(File(currShop.photoMap['snack']!),width: 50,height: 100,),
                                        const Text('Снэки')
                                      ],
                                    );
                                  })
                              )
                          ),
                          ElevatedButton(onPressed: ()async{
                            if(currShop.photoMap['konditer'] != ''){
                              bool? isShow = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  content: const Text('Фото кондитерской продукции уже есть, хотите перезаписать?'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Нет'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Да'),
                                    ),
                                  ],
                                ),
                              );
                              if(isShow != null && isShow){
                                Navigator.of(context).popAndPushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.konditer));
                              }
                            }else{
                              Navigator.of(context).popAndPushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.konditer));
                            }
                          }, child: null,
                              style: const ButtonStyle().copyWith(shape: MaterialStateProperty.all<RoundedRectangleBorder>(const RoundedRectangleBorder()),
                                  foregroundBuilder: ((context, state, child){
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        currShop.photoMap['konditer']! == '' ? const SizedBox(height: 100,) : Image.file(File(currShop.photoMap['konditer']!),width: 50,height: 100,),
                                        const Text('Кондитерская')
                                      ],
                                    );
                                  })
                              )
                          ),
                        ]
                    ),

                    TableRow(
                        children: [
                          ElevatedButton(onPressed: ()async{
                            if(currShop.photoMap['konserv'] != ''){
                              bool? isShow = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  content: const Text('Фото консерв уже есть, хотите перезаписать?'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Нет'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Да'),
                                    ),
                                  ],
                                ),
                              );
                              if(isShow != null && isShow){
                                Navigator.of(context).popAndPushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.konserv));
                              }
                            }else{
                              Navigator.of(context).popAndPushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.konserv));
                            }
                          }, child: null,
                              style: const ButtonStyle().copyWith(shape: MaterialStateProperty.all<RoundedRectangleBorder>(const RoundedRectangleBorder()),
                                  foregroundBuilder: ((context, state, child){
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        currShop.photoMap['konserv']! == '' ? const SizedBox(height: 100,) : Image.file(File(currShop.photoMap['konserv']!),width: 50,height: 100,),
                                        const Text('Консервы')
                                      ],
                                    );
                                  })
                              )
                          ),
                          ElevatedButton(onPressed: ()async{
                            if(currShop.photoMap['mylomoika'] != ''){
                              bool? isShow = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  content: const Text('Фото мыломойки уже есть, хотите перезаписать?'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Нет'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Да'),
                                    ),
                                  ],
                                ),
                              );
                              if(isShow != null && isShow){
                                Navigator.of(context).popAndPushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.mylomoika));
                              }
                            }else{
                              Navigator.of(context).popAndPushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.mylomoika));
                            }
                          }, child: null,
                              style: const ButtonStyle().copyWith(shape: MaterialStateProperty.all<RoundedRectangleBorder>(const RoundedRectangleBorder()),
                                  foregroundBuilder: ((context, state, child){
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        currShop.photoMap['mylomoika']! == '' ? const SizedBox(height: 100,) : Image.file(File(currShop.photoMap['mylomoika']!),width: 50,height: 100,),
                                        const Text('Мыломойка')
                                      ],
                                    );
                                  })
                              )
                          ),
                        ]
                    ),

                    TableRow(
                        children: [
                          ElevatedButton(onPressed: ()async{
                            if(currShop.photoMap['vegetablesFruits'] != ''){
                              bool? isShow = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  content: const Text('Фото фруктов и овощей уже есть, хотите перезаписать?'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Нет'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Да'),
                                    ),
                                  ],
                                ),
                              );
                              if(isShow != null && isShow){
                                Navigator.of(context).popAndPushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.vegetablesFruits));
                              }
                            }else{
                              Navigator.of(context).popAndPushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.vegetablesFruits));
                            }
                          }, child: null,
                              style: const ButtonStyle().copyWith(shape: MaterialStateProperty.all<RoundedRectangleBorder>(const RoundedRectangleBorder()),
                                  foregroundBuilder: ((context, state, child){
                                    return  Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        currShop.photoMap['vegetablesFruits']! == '' ? const SizedBox(height: 100,) : Image.file(File(currShop.photoMap['vegetablesFruits']!),width: 50,height: 100,),
                                        const Text('Фрукты/Овощи')
                                      ],
                                    );
                                  })
                              )
                          ),
                          ElevatedButton(onPressed: ()async{
                            if(currShop.photoMap['cigarettes'] != ''){
                              bool? isShow = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  content: const Text('Фото сигарет уже есть, хотите перезаписать?'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Нет'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Да'),
                                    ),
                                  ],
                                ),
                              );
                              if(isShow != null && isShow){
                                Navigator.of(context).popAndPushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.cigarettes));
                              }
                            }else{
                              Navigator.of(context).popAndPushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.cigarettes));
                            }
                          }, child: null,
                              style: const ButtonStyle().copyWith(shape: MaterialStateProperty.all<RoundedRectangleBorder>(const RoundedRectangleBorder()),
                                  foregroundBuilder: ((context, state, child){
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        currShop.photoMap['cigarettes']! == '' ? const SizedBox(height: 100,) : Image.file(File(currShop.photoMap['cigarettes']!),width: 50,height: 100,),
                                        const Text('Сигареты'),
                                      ],
                                    );
                                  })
                              )
                          ),
                        ]
                    ),

                    TableRow(
                        children: [
                          ElevatedButton(onPressed: ()async{
                            if(currShop.photoMap['kassovayaZona'] != ''){
                              bool? isShow = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  content: const Text('Фото кассовой зоны уже есть, хотите перезаписать?'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Нет'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Да'),
                                    ),
                                  ],
                                ),
                              );
                              if(isShow != null && isShow){
                                Navigator.of(context).popAndPushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.kassovayaZona));
                              }
                            }else{
                              Navigator.of(context).popAndPushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.kassovayaZona));
                            }
                          }, child: null,
                              style: const ButtonStyle().copyWith(shape: MaterialStateProperty.all<RoundedRectangleBorder>(const RoundedRectangleBorder()),
                                  foregroundBuilder: ((context, state, child){
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        currShop.photoMap['kassovayaZona']! == '' ? const SizedBox(height: 100,) : Image.file(File(currShop.photoMap['kassovayaZona']!),width: 50,height: 100,),
                                        const Text('Касса')
                                      ],
                                    );
                                  })
                              )
                          ),
                          ElevatedButton(onPressed: ()async{
                            if(currShop.photoMap['toys'] != ''){
                              bool? isShow = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  content: const Text('Фото игрушек уже есть, хотите перезаписать?'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Нет'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Да'),
                                    ),
                                  ],
                                ),
                              );
                              if(isShow != null && isShow){
                                Navigator.of(context).popAndPushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.toys));
                              }
                            }else{
                              Navigator.of(context).popAndPushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.toys));
                            }
                          }, child: null,
                              style: const ButtonStyle().copyWith(shape: MaterialStateProperty.all<RoundedRectangleBorder>(const RoundedRectangleBorder()),
                                  foregroundBuilder: ((context, state, child){
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        currShop.photoMap['toys']! == '' ? const SizedBox(height: 100,) : Image.file(File(currShop.photoMap['toys']!),width: 50,height: 100,),
                                        const Text('Игрушки')
                                      ],
                                    );
                                  })
                              )
                          ),
                        ]
                    ),

                    TableRow(
                        children: [
                          ElevatedButton(onPressed: ()async{
                            if(currShop.photoMap['butter'] != ''){
                              bool? isShow = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  content: const Text('Фото хлебной продукции уже есть, хотите перезаписать?'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Нет'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Да', style: TextStyle(backgroundColor: Colors.red, color: Colors.blue),),
                                    ),
                                  ],
                                ),
                              );
                              if(isShow != null && isShow){
                                Navigator.of(context).popAndPushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.butter));
                              }
                            }else{
                              Navigator.of(context).popAndPushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.butter));
                            }
                          }, child: null,
                              style: const ButtonStyle().copyWith(shape: MaterialStateProperty.all<RoundedRectangleBorder>(const RoundedRectangleBorder()),
                                  foregroundBuilder: ((context, state, child){
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        currShop.photoMap['butter']! == '' ? const SizedBox(height: 100,) : Image.file(File(currShop.photoMap['butter']!),width: 50,height: 100,),
                                        const Text('Хлеб'),
                                      ],
                                    );
                                  })
                              )
                          ),
                          Container(),
                        ]
                    )
                  ],
                )
          ]
      ),
    );
  }
}