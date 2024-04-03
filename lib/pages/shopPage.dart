import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shop_audit/component/internal_shop.dart';
import 'package:shop_audit/global/global_variants.dart';
import 'package:shop_audit/main.dart';

Future<bool?> deletePhoto(BuildContext context)
async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      content: const Text('Удалить фото?'),
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
}

class ShopPage extends StatefulWidget
{
  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
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
              onPressed: currShop.hasReport ? null : () async{
                if(currShop.photoMap['externalPhoto'] == '' || currShop.photoMap['shopLabelPhoto'] == ''
                    || currShop.cassCount == 0 || currShop.prodavecManagerCount == 0 || currShop.address == ''){
                  await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) =>
                        AlertDialog(
                          content: const Text('Фотографии вывески, фотография снаружи и обязательные поля анкеты не заполнены!'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Ок'),
                            ),
                          ],
                        ),
                  );
                  return;
                }
                sqlFliteDB.sendShopToServer([currShop]);
                Navigator.of(context).pop();
              },
            ),
            IconButton(icon: const Icon(Icons.delete_forever_sharp), onPressed: ()async{
              bool? isDelete = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) =>
                    AlertDialog(
                      content: const Text('Удалить магазин?'),
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
              if (isDelete != null && isDelete) {
                sqlFliteDB.deleteShop(currShop.id);
                Navigator.of(context).pop();
              }
            })
          ]
      ),
      body: ListView(
          children: [
            ElevatedButton(child: const Text('Анкета'), onPressed: (){
              Navigator.of(context).pushNamed('/anketaPage',arguments: CustomArgument(shopId: args.shopId));
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
                            sqlFliteDB.setPhoto(args.shopId, PhotoType.externalPhoto, '');
                            Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.externalPhoto));
                          }
                        }else{
                          Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.externalPhoto));
                        }
                      }, child: null,
                          style: const ButtonStyle().copyWith(shape: MaterialStateProperty.all<RoundedRectangleBorder>(const RoundedRectangleBorder()),
                              foregroundBuilder: ((context, state, child){
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    currShop.photoMap['externalPhoto']! == '' ? const SizedBox(height: 100,) : Image.file(File(currShop.photoMap['externalPhoto']!),width: 50,height: 100, filterQuality: FilterQuality.none),
                                    const Text('Фото снаружи*'),
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children:[
                                          Container(width: 100,),
                                          IconButton(
                                            icon: const Icon(Icons.close_rounded, color: Colors.red,)
                                            , onPressed: currShop.photoMap['externalPhoto']! == '' ? null : ()async{
                                            bool? isShow = await deletePhoto(context);
                                            setState(() {});
                                            if(isShow != null && isShow){
                                              sqlFliteDB.setPhoto(args.shopId, PhotoType.externalPhoto, '');
                                            }
                                          },)
                                        ]
                                    ),

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
                            sqlFliteDB.setPhoto(args.shopId, PhotoType.shopLabelPhoto, '');
                            Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.shopLabelPhoto));
                          }
                        }else{
                          Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.shopLabelPhoto));
                        }
                      }, child: null,
                          style: const ButtonStyle().copyWith(shape: MaterialStateProperty.all<RoundedRectangleBorder>(const RoundedRectangleBorder()),
                              foregroundBuilder: ((context, state, child){
                                return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      currShop.photoMap['shopLabelPhoto']! == '' ? const SizedBox(height: 100,) : Image.file(File(currShop.photoMap['shopLabelPhoto']!),width: 50,height: 100, filterQuality: FilterQuality.none),

                                      const Text('Вывеска*'),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children:[
                                          Container(width: 100,),
                                          IconButton(icon: const Icon(Icons.close_rounded, color: Colors.red,)
                                              , onPressed: currShop.photoMap['shopLabelPhoto']! == '' ? null : ()async{
                                                bool? isShow = await deletePhoto(context);
                                                if(isShow != null && isShow){
                                                  sqlFliteDB.setPhoto(args.shopId, PhotoType.shopLabelPhoto, '');
                                                }
                                              }),
                                        ],
                                      )
                                    ]);
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
                            sqlFliteDB.setPhoto(args.shopId, PhotoType.alkoholPhoto, '');
                            Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.alkoholPhoto));
                          }
                        }else{
                          Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.alkoholPhoto));
                        }
                      }, child: null,
                          style: const ButtonStyle().copyWith(shape: MaterialStateProperty.all<RoundedRectangleBorder>(const RoundedRectangleBorder()),
                              foregroundBuilder: ((context, state, child){
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    currShop.photoMap['alkoholPhoto']! == '' ? const SizedBox(height: 100,) : Image.file(File(currShop.photoMap['alkoholPhoto']!),width: 50,height: 100, filterQuality: FilterQuality.none),
                                    const Text('Алкоголь'),
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children:[
                                          IconButton(
                                            icon: const Icon(Icons.check_rounded, color: Colors.green,)
                                            , onPressed: (){
                                            sqlFliteDB.setPhoto(args.shopId, PhotoType.alkoholPhoto, 'yes');
                                            setState((){});
                                          },),
                                          IconButton(icon: const Icon(Icons.close_rounded, color: Colors.red,)
                                              , onPressed: currShop.photoMap['alkoholPhoto']! == '' ? null : ()async{
                                                bool? isShow = await deletePhoto(context);
                                                if(isShow != null && isShow){
                                                  sqlFliteDB.setPhoto(args.shopId, PhotoType.alkoholPhoto, '');
                                                }
                                              }),
                                        ]),
                                  ],
                                );
                              })
                          )
                      ),
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
                                  child: const Text('Да'),
                                ),
                              ],
                            ),
                          );
                          if(isShow != null && isShow){
                            sqlFliteDB.setPhoto(args.shopId, PhotoType.butter, '');
                            Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.butter));
                          }
                        }else{
                          Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.butter));
                        }
                      }, child: null,
                          style: const ButtonStyle().copyWith(shape: MaterialStateProperty.all<RoundedRectangleBorder>(const RoundedRectangleBorder()),
                              foregroundBuilder: ((context, state, child){
                                return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      currShop.photoMap['butter']! == '' ? const SizedBox(height: 100,) : Image.file(File(currShop.photoMap['butter']!),width: 50,height: 100, filterQuality: FilterQuality.none),
                                      const Text('Хлеб'),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children:[
                                          IconButton(
                                            icon: const Icon(Icons.check_rounded, color: Colors.green,)
                                            , onPressed: (){
                                            sqlFliteDB.setPhoto(args.shopId, PhotoType.butter, 'yes');
                                            setState((){});
                                          },),
                                          IconButton(icon: const Icon(Icons.close_rounded, color: Colors.red,)
                                              , onPressed: currShop.photoMap['butter']! == '' ? null : ()async{
                                                bool? isShow = await deletePhoto(context);
                                                if(isShow != null && isShow){
                                                  sqlFliteDB.setPhoto(args.shopId, PhotoType.butter, '');
                                                }
                                              })
                                        ],
                                      )
                                    ]
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
                            sqlFliteDB.setPhoto(args.shopId, PhotoType.kolbasaSyr, '');
                            Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.kolbasaSyr));
                          }
                        }else{
                          Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.kolbasaSyr));
                        }
                      }, child: null,
                          style: const ButtonStyle().copyWith(shape: MaterialStateProperty.all<RoundedRectangleBorder>(const RoundedRectangleBorder()),
                              foregroundBuilder: ((context, state, child){
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    currShop.photoMap['kolbasaSyr']! == '' ? const SizedBox(height: 100,) : Image.file(File(currShop.photoMap['kolbasaSyr']!),width: 50,height: 100, filterQuality: FilterQuality.none),

                                    const Text('Колбаса и сыр'),
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children:[
                                          IconButton(
                                            icon: const Icon(Icons.check_rounded, color: Colors.green,)
                                            , onPressed: (){
                                            sqlFliteDB.setPhoto(args.shopId, PhotoType.kolbasaSyr, 'yes');
                                            setState((){});
                                          },),
                                          IconButton(icon: const Icon(Icons.close_rounded, color: Colors.red,)
                                              , onPressed: currShop.photoMap['kolbasaSyr']! == '' ? null : ()async{
                                                bool? isShow = await deletePhoto(context);
                                                if(isShow != null && isShow){
                                                  sqlFliteDB.setPhoto(args.shopId, PhotoType.kolbasaSyr, '');
                                                }
                                              })
                                        ]
                                    )
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
                            sqlFliteDB.setPhoto(args.shopId, PhotoType.milk, '');
                            Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.milk));
                          }
                        }else{
                          Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.milk));
                        }
                      }, child: null,
                          style: const ButtonStyle().copyWith(shape: MaterialStateProperty.all<RoundedRectangleBorder>(const RoundedRectangleBorder()),
                              foregroundBuilder: ((context, state, child){
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    currShop.photoMap['milk']! == '' ? const SizedBox(height: 100,) : Image.file(File(currShop.photoMap['milk']!),width: 50,height: 100, filterQuality: FilterQuality.none),

                                    const Text('Молочка'),
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children:[
                                          IconButton(
                                            icon: const Icon(Icons.check_rounded, color: Colors.green,)
                                            , onPressed: (){
                                            sqlFliteDB.setPhoto(args.shopId, PhotoType.milk, 'yes');
                                            setState((){});
                                          },),
                                          IconButton(icon: const Icon(Icons.close_rounded, color: Colors.red,)
                                              , onPressed:currShop.photoMap['milk']! == '' ? null : ()async{
                                                bool? isShow = await deletePhoto(context);
                                                if(isShow != null && isShow){
                                                  sqlFliteDB.setPhoto(args.shopId, PhotoType.milk, '');
                                                }
                                              })
                                        ]
                                    )
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
                            sqlFliteDB.setPhoto(args.shopId, PhotoType.snack, '');
                            Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.snack));
                          }
                        }else{
                          Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.snack));
                        }
                      }, child: null,
                          style: const ButtonStyle().copyWith(shape: MaterialStateProperty.all<RoundedRectangleBorder>(const RoundedRectangleBorder()),
                              foregroundBuilder: ((context, state, child){
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    currShop.photoMap['snack']! == '' ? const SizedBox(height: 100,) : Image.file(File(currShop.photoMap['snack']!),width: 50,height: 100, filterQuality: FilterQuality.none),
                                    const Text('Снэки'),
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children:[
                                          IconButton(
                                            icon: const Icon(Icons.check_rounded, color: Colors.green,)
                                            , onPressed: (){
                                            sqlFliteDB.setPhoto(args.shopId, PhotoType.snack, 'yes');
                                            setState((){});
                                          },),
                                          IconButton(
                                              icon: const Icon(Icons.close_rounded, color: Colors.red,)
                                              ,onPressed:currShop.photoMap['snack']! == '' ? null : ()async{
                                            bool? isShow = await deletePhoto(context);
                                            if(isShow != null && isShow){
                                              sqlFliteDB.setPhoto(args.shopId, PhotoType.snack, '');
                                            }
                                          })
                                        ]
                                    )
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
                            sqlFliteDB.setPhoto(args.shopId, PhotoType.mylomoika, '');
                            Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.mylomoika));
                          }
                        }else{
                          Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.mylomoika));
                        }
                      }, child: null,
                          style: const ButtonStyle().copyWith(shape: MaterialStateProperty.all<RoundedRectangleBorder>(const RoundedRectangleBorder()),
                              foregroundBuilder: ((context, state, child){
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    currShop.photoMap['mylomoika']! == '' ? const SizedBox(height: 100,) : Image.file(File(currShop.photoMap['mylomoika']!),width: 50,height: 100, filterQuality: FilterQuality.none),

                                    const Text('Мыломойка'),
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children:[
                                          IconButton(
                                            icon: const Icon(Icons.check_rounded, color: Colors.green,)
                                            , onPressed: (){
                                            sqlFliteDB.setPhoto(args.shopId, PhotoType.mylomoika, 'yes');
                                            setState((){});
                                          },),
                                          IconButton(icon: const Icon(Icons.close_rounded, color: Colors.red,),
                                              onPressed: currShop.photoMap['mylomoika']! == '' ? null :  ()async{
                                                bool? isShow = await deletePhoto(context);
                                                if(isShow != null && isShow){
                                                  sqlFliteDB.setPhoto(args.shopId, PhotoType.mylomoika, '');
                                                }
                                              })
                                        ]
                                    )
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
                            sqlFliteDB.setPhoto(args.shopId, PhotoType.vegetablesFruits, '');
                            Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.vegetablesFruits));
                          }
                        }else{
                          Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.vegetablesFruits));
                        }
                      }, child: null,
                          style: const ButtonStyle().copyWith(shape: MaterialStateProperty.all<RoundedRectangleBorder>(const RoundedRectangleBorder()),
                              foregroundBuilder: ((context, state, child){
                                return  Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    currShop.photoMap['vegetablesFruits']! == '' ? const SizedBox(height: 100,) : Image.file(File(currShop.photoMap['vegetablesFruits']!),width: 50,height: 100, filterQuality: FilterQuality.none),

                                    const Text('Фрукты/Овощи'),
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children:[
                                          IconButton(
                                            icon: const Icon(Icons.check_rounded, color: Colors.green,)
                                            , onPressed: (){
                                            sqlFliteDB.setPhoto(args.shopId, PhotoType.vegetablesFruits, 'yes');
                                            setState((){});
                                          },),
                                          IconButton(icon: const Icon(Icons.close_rounded, color: Colors.red,)
                                              , onPressed:currShop.photoMap['vegetablesFruits']! == '' ? null : ()async{
                                                bool? isShow = await deletePhoto(context);
                                                if(isShow != null && isShow){
                                                  sqlFliteDB.setPhoto(args.shopId, PhotoType.vegetablesFruits, '');
                                                }
                                              })
                                        ]
                                    )
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
                            sqlFliteDB.setPhoto(args.shopId, PhotoType.cigarettes, '');
                            Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.cigarettes));
                          }
                        }else{
                          Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.cigarettes));
                        }
                      }, child: null,
                          style: const ButtonStyle().copyWith(shape: MaterialStateProperty.all<RoundedRectangleBorder>(const RoundedRectangleBorder()),
                              foregroundBuilder: ((context, state, child){
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    currShop.photoMap['cigarettes']! == '' ? const SizedBox(height: 100,) : Image.file(File(currShop.photoMap['cigarettes']!),width: 50,height: 100, filterQuality: FilterQuality.none),
                                    const Text('Сигареты'),
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children:[
                                          IconButton(
                                            icon: const Icon(Icons.check_rounded, color: Colors.green,)
                                            , onPressed: (){
                                            sqlFliteDB.setPhoto(args.shopId, PhotoType.cigarettes, 'yes');
                                            setState((){});
                                          },),
                                          IconButton(icon: const Icon(Icons.close_rounded, color: Colors.red,)
                                              , onPressed:currShop.photoMap['cigarettes']! == '' ? null : ()async{
                                                bool? isShow = await deletePhoto(context);
                                                if(isShow != null && isShow){
                                                  sqlFliteDB.setPhoto(args.shopId, PhotoType.cigarettes, '');
                                                }
                                              })
                                        ]
                                    )
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
                            sqlFliteDB.setPhoto(args.shopId, PhotoType.kassovayaZona, '');
                            Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.kassovayaZona));
                          }
                        }else{
                          Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.kassovayaZona));
                        }
                      }, child: null,
                          style: const ButtonStyle().copyWith(shape: MaterialStateProperty.all<RoundedRectangleBorder>(const RoundedRectangleBorder()),
                              foregroundBuilder: ((context, state, child){
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    currShop.photoMap['kassovayaZona']! == '' ? const SizedBox(height: 100,) : Image.file(File(currShop.photoMap['kassovayaZona']!),width: 50,height: 100, filterQuality: FilterQuality.none),

                                    const Text('Касса'),
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children:[
                                          IconButton(
                                            icon: const Icon(Icons.check_rounded, color: Colors.green,)
                                            , onPressed: (){
                                            sqlFliteDB.setPhoto(args.shopId, PhotoType.kassovayaZona, 'yes');
                                            setState((){});
                                          },),
                                          IconButton(icon: const Icon(Icons.close_rounded, color: Colors.red,)
                                              , onPressed:currShop.photoMap['kassovayaZona']! == '' ? null : ()async{
                                                bool? isShow = await deletePhoto(context);
                                                if(isShow != null && isShow){
                                                  sqlFliteDB.setPhoto(args.shopId, PhotoType.kassovayaZona, '');
                                                }
                                              })
                                        ]
                                    )
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
                            sqlFliteDB.setPhoto(args.shopId, PhotoType.toys, '');
                            Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.toys));
                          }
                        }else{
                          Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.toys));
                        }
                      }, child: null,
                          style: const ButtonStyle().copyWith(shape: MaterialStateProperty.all<RoundedRectangleBorder>(const RoundedRectangleBorder()),
                              foregroundBuilder: ((context, state, child){
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    currShop.photoMap['toys']! == '' ? const SizedBox(height: 100,) : Image.file(File(currShop.photoMap['toys']!),width: 50,height: 100, filterQuality: FilterQuality.none),
                                    const Text('Игрушки'),
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children:[
                                          IconButton(
                                            icon: const Icon(Icons.check_rounded, color: Colors.green,)
                                            , onPressed: (){
                                            sqlFliteDB.setPhoto(args.shopId, PhotoType.toys, 'yes');
                                            setState((){});
                                          },),
                                          IconButton(icon: const Icon(Icons.close_rounded, color: Colors.red,)
                                              , onPressed:currShop.photoMap['toys']! == '' ? null : ()async{
                                                bool? isShow = await deletePhoto(context);
                                                if(isShow != null && isShow){
                                                  sqlFliteDB.setPhoto(args.shopId, PhotoType.toys, '');
                                                }
                                              })
                                        ])
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
                        if(currShop.photoMap['water'] != ''){
                          bool? isShow = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              content: const Text('Фото воды уже есть, хотите перезаписать?'),
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
                            sqlFliteDB.setPhoto(args.shopId, PhotoType.water, '');
                            Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.water));
                          }
                        }else{
                          Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.water));
                        }
                      }, child: null,
                          style: const ButtonStyle().copyWith(shape: MaterialStateProperty.all<RoundedRectangleBorder>(const RoundedRectangleBorder()),
                              foregroundBuilder: ((context, state, child){
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    currShop.photoMap['water']! == '' ? const SizedBox(height: 100,) : Image.file(File(currShop.photoMap['water']!),width: 50,height: 100, filterQuality: FilterQuality.none),

                                    const Text('Вода'),
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children:[
                                          IconButton(
                                            icon: const Icon(Icons.check_rounded, color: Colors.green,)
                                            , onPressed: (){
                                            sqlFliteDB.setPhoto(args.shopId, PhotoType.water, 'yes');
                                            setState((){});
                                          },),
                                          IconButton(icon: const Icon(Icons.close_rounded, color: Colors.red,),
                                              onPressed:currShop.photoMap['water']! == '' ? null : ()async{
                                                bool? isShow = await deletePhoto(context);
                                                if(isShow != null && isShow){
                                                  sqlFliteDB.setPhoto(args.shopId, PhotoType.water, '');
                                                }
                                              })
                                        ]
                                    )
                                  ],
                                );
                              })
                          )
                      ),
                      ElevatedButton(onPressed: ()async{
                        if(currShop.photoMap['juice'] != ''){
                          bool? isShow = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              content: const Text('Фото соков уже есть, хотите перезаписать?'),
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
                            sqlFliteDB.setPhoto(args.shopId, PhotoType.juice, '');
                            Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.juice));
                          }
                        }else{
                          Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.juice));
                        }
                      }, child: null,
                          style: const ButtonStyle().copyWith(shape: MaterialStateProperty.all<RoundedRectangleBorder>(const RoundedRectangleBorder()),
                              foregroundBuilder: ((context, state, child){
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    currShop.photoMap['juice']! == '' ? const SizedBox(height: 100,) : Image.file(File(currShop.photoMap['juice']!),width: 50,height: 100, filterQuality: FilterQuality.none),

                                    const Text('Соки'),
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children:[
                                          IconButton(
                                            icon: const Icon(Icons.check_rounded, color: Colors.green,)
                                            , onPressed: (){
                                            sqlFliteDB.setPhoto(args.shopId, PhotoType.juice, 'yes');
                                            setState((){});
                                          },),
                                          IconButton(icon: const Icon(Icons.close_rounded, color: Colors.red,),
                                              onPressed:currShop.photoMap['juice']! == '' ? null : ()async{
                                                bool? isShow = await deletePhoto(context);
                                                if(isShow != null && isShow){
                                                  sqlFliteDB.setPhoto(args.shopId, PhotoType.juice, '');
                                                }
                                              })
                                        ]
                                    )
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
                        if(currShop.photoMap['gazirovka'] != ''){
                          bool? isShow = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              content: const Text('Фото газировки уже есть, хотите перезаписать?'),
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
                            sqlFliteDB.setPhoto(args.shopId, PhotoType.gazirovka, '');
                            Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.gazirovka));
                          }
                        }else{
                          Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.gazirovka));
                        }
                      }, child: null,
                          style: const ButtonStyle().copyWith(shape: MaterialStateProperty.all<RoundedRectangleBorder>(const RoundedRectangleBorder()),
                              foregroundBuilder: ((context, state, child){
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    currShop.photoMap['gazirovka']! == '' ? const SizedBox(height: 100,) : Image.file(File(currShop.photoMap['gazirovka']!),width: 50,height: 100, filterQuality: FilterQuality.none),

                                    const Text('Газировка'),
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children:[
                                          IconButton(
                                            icon: const Icon(Icons.check_rounded, color: Colors.green,)
                                            , onPressed: (){
                                            sqlFliteDB.setPhoto(args.shopId, PhotoType.gazirovka, 'yes');
                                            setState((){});
                                          },),
                                          IconButton(icon: const Icon(Icons.close_rounded, color: Colors.red,),
                                              onPressed:currShop.photoMap['gazirovka']! == '' ? null : ()async{
                                                bool? isShow = await deletePhoto(context);
                                                if(isShow != null && isShow){
                                                  sqlFliteDB.setPhoto(args.shopId, PhotoType.gazirovka, '');
                                                }
                                              })
                                        ]
                                    )
                                  ],
                                );
                              })
                          )
                      ),
                      ElevatedButton(onPressed: ()async{
                        if(currShop.photoMap['candyVes'] != ''){
                          bool? isShow = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              content: const Text('Фото весовых конфет уже есть, хотите перезаписать?'),
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
                            sqlFliteDB.setPhoto(args.shopId, PhotoType.candyVes, '');
                            Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.candyVes));
                          }
                        }else{
                          Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.candyVes));
                        }
                      }, child: null,
                          style: const ButtonStyle().copyWith(shape: MaterialStateProperty.all<RoundedRectangleBorder>(const RoundedRectangleBorder()),
                              foregroundBuilder: ((context, state, child){
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    currShop.photoMap['candyVes']! == '' ? const SizedBox(height: 100,) : Image.file(File(currShop.photoMap['candyVes']!),width: 50,height: 100, filterQuality: FilterQuality.none),
                                    const Text('Весовые конфеты'),
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children:[
                                          IconButton(
                                            icon: const Icon(Icons.check_rounded, color: Colors.green,)
                                            , onPressed: (){
                                            sqlFliteDB.setPhoto(args.shopId, PhotoType.candyVes, 'yes');
                                            setState((){});
                                          },),
                                          IconButton(icon: const Icon(Icons.close_rounded, color: Colors.red,),
                                              onPressed:currShop.photoMap['candyVes']! == '' ? null : ()async{
                                                bool? isShow = await deletePhoto(context);
                                                if(isShow != null && isShow){
                                                  sqlFliteDB.setPhoto(args.shopId, PhotoType.candyVes, '');
                                                }
                                              })
                                        ])
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
                        if(currShop.photoMap['chocolate'] != ''){
                          bool? isShow = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              content: const Text('Фото шоколадок уже есть, хотите перезаписать?'),
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
                            sqlFliteDB.setPhoto(args.shopId, PhotoType.chocolate, '');
                            Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.chocolate));
                          }
                        }else{
                          Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.chocolate));
                        }
                      }, child: null,
                          style: const ButtonStyle().copyWith(shape: MaterialStateProperty.all<RoundedRectangleBorder>(const RoundedRectangleBorder()),
                              foregroundBuilder: ((context, state, child){
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    currShop.photoMap['chocolate']! == '' ? const SizedBox(height: 100,) : Image.file(File(currShop.photoMap['chocolate']!),width: 50,height: 100, filterQuality: FilterQuality.none),

                                    const Text('Шоколадки'),
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children:[
                                          IconButton(
                                            icon: const Icon(Icons.check_rounded, color: Colors.green,)
                                            , onPressed: (){
                                            sqlFliteDB.setPhoto(args.shopId, PhotoType.chocolate, 'yes');
                                            setState((){});
                                          },),
                                          IconButton(icon: const Icon(Icons.close_rounded, color: Colors.red,),
                                              onPressed:currShop.photoMap['chocolate']! == '' ? null : ()async{
                                                bool? isShow = await deletePhoto(context);
                                                if(isShow != null && isShow){
                                                  sqlFliteDB.setPhoto(args.shopId, PhotoType.chocolate, '');
                                                }
                                              })
                                        ]
                                    )
                                  ],
                                );
                              })
                          )
                      ),
                      ElevatedButton(onPressed: ()async{
                        if(currShop.photoMap['korobkaCandy'] != ''){
                          bool? isShow = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              content: const Text('Фото коробочных конфет уже есть, хотите перезаписать?'),
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
                            sqlFliteDB.setPhoto(args.shopId, PhotoType.korobkaCandy, '');
                            Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.korobkaCandy));
                          }
                        }else{
                          Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.korobkaCandy));
                        }
                      }, child: null,
                          style: const ButtonStyle().copyWith(shape: MaterialStateProperty.all<RoundedRectangleBorder>(const RoundedRectangleBorder()),
                              foregroundBuilder: ((context, state, child){
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    currShop.photoMap['korobkaCandy']! == '' ? const SizedBox(height: 100,) : Image.file(File(currShop.photoMap['korobkaCandy']!),width: 50,height: 100, filterQuality: FilterQuality.none),

                                    const Text('Коробочные конфеты'),
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children:[
                                          IconButton(
                                            icon: const Icon(Icons.check_rounded, color: Colors.green,)
                                            , onPressed: (){
                                            sqlFliteDB.setPhoto(args.shopId, PhotoType.korobkaCandy, 'yes');
                                            setState((){});
                                          },),
                                          IconButton(icon: const Icon(Icons.close_rounded, color: Colors.red,),
                                              onPressed:currShop.photoMap['korobkaCandy']! == '' ? null : ()async{
                                                bool? isShow = await deletePhoto(context);
                                                if(isShow != null && isShow){
                                                  sqlFliteDB.setPhoto(args.shopId, PhotoType.korobkaCandy, '');
                                                }
                                              })
                                        ])
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
                        if(currShop.photoMap['pirogi'] != ''){
                          bool? isShow = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              content: const Text('Фото вафель уже есть, хотите перезаписать?'),
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
                            sqlFliteDB.setPhoto(args.shopId, PhotoType.pirogi, '');
                            Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.pirogi));
                          }
                        }else{
                          Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.pirogi));
                        }
                      }, child: null,
                          style: const ButtonStyle().copyWith(shape: MaterialStateProperty.all<RoundedRectangleBorder>(const RoundedRectangleBorder()),
                              foregroundBuilder: ((context, state, child){
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    currShop.photoMap['pirogi']! == '' ? const SizedBox(height: 100,) : Image.file(File(currShop.photoMap['pirogi']!),width: 50,height: 100, filterQuality: FilterQuality.none),

                                    const Text('Вафли, булочки, кексы'),
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children:[
                                          IconButton(
                                            icon: const Icon(Icons.check_rounded, color: Colors.green,)
                                            , onPressed: (){
                                            sqlFliteDB.setPhoto(args.shopId, PhotoType.pirogi, 'yes');
                                            setState((){});
                                          },),
                                          IconButton(icon: const Icon(Icons.close_rounded, color: Colors.red,)
                                              , onPressed:currShop.photoMap['pirogi']! == '' ? null : ()async{
                                                bool? isShow = await deletePhoto(context);
                                                if(isShow != null && isShow){
                                                  sqlFliteDB.setPhoto(args.shopId, PhotoType.pirogi, '');
                                                }
                                              })
                                        ])
                                  ],
                                );
                              })
                          )
                      ),
                      ElevatedButton(onPressed: ()async{
                        if(currShop.photoMap['tea'] != ''){
                          bool? isShow = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              content: const Text('Фото чая уже есть, хотите перезаписать?'),
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
                            sqlFliteDB.setPhoto(args.shopId, PhotoType.tea, '');
                            Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.tea));
                          }
                        }else{
                          Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.tea));
                        }
                      }, child: null,
                          style: const ButtonStyle().copyWith(shape: MaterialStateProperty.all<RoundedRectangleBorder>(const RoundedRectangleBorder()),
                              foregroundBuilder: ((context, state, child){
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    currShop.photoMap['tea']! == '' ? const SizedBox(height: 100,) : Image.file(File(currShop.photoMap['tea']!),width: 50,height: 100, filterQuality: FilterQuality.none),

                                    const Text('Чай'),
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children:[
                                          IconButton(
                                            icon: const Icon(Icons.check_rounded, color: Colors.green,)
                                            , onPressed: (){
                                            sqlFliteDB.setPhoto(args.shopId, PhotoType.tea, 'yes');
                                            setState((){});
                                          },),
                                          IconButton(icon: const Icon(Icons.close_rounded, color: Colors.red,),
                                              onPressed:currShop.photoMap['tea']! == '' ? null : ()async{
                                                bool? isShow = await deletePhoto(context);
                                                if(isShow != null && isShow){
                                                  sqlFliteDB.setPhoto(args.shopId, PhotoType.tea, '');
                                                }
                                              })
                                        ])
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
                        if(currShop.photoMap['coffee'] != ''){
                          bool? isShow = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              content: const Text('Фото кофе уже есть, хотите перезаписать?'),
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
                            sqlFliteDB.setPhoto(args.shopId, PhotoType.coffee, '');
                            Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.coffee));
                          }
                        }else{
                          Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.coffee));
                        }
                      }, child: null,
                          style: const ButtonStyle().copyWith(shape: MaterialStateProperty.all<RoundedRectangleBorder>(const RoundedRectangleBorder()),
                              foregroundBuilder: ((context, state, child){
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    currShop.photoMap['coffee']! == '' ? const SizedBox(height: 100,) : Image.file(File(currShop.photoMap['coffee']!),width: 50,height: 100, filterQuality: FilterQuality.none),
                                    const Text('Кофе'),
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children:[
                                          IconButton(
                                            icon: const Icon(Icons.check_rounded, color: Colors.green,)
                                            , onPressed: (){
                                            sqlFliteDB.setPhoto(args.shopId, PhotoType.coffee, 'yes');
                                            setState((){});
                                          },),
                                          IconButton(icon: const Icon(Icons.close_rounded, color: Colors.red,),
                                              onPressed:currShop.photoMap['coffee']! == '' ? null : ()async{
                                                bool? isShow = await deletePhoto(context);
                                                if(isShow != null && isShow){
                                                  sqlFliteDB.setPhoto(args.shopId, PhotoType.coffee, '');
                                                }
                                              })
                                        ])
                                  ],
                                );
                              })
                          )
                      ),
                      ElevatedButton(onPressed: ()async{
                        if(currShop.photoMap['macarons'] != ''){
                          bool? isShow = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              content: const Text('Фото макарон уже есть, хотите перезаписать?'),
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
                            sqlFliteDB.setPhoto(args.shopId, PhotoType.macarons, '');
                            Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.macarons));
                          }
                        }else{
                          Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.macarons));
                        }
                      }, child: null,
                          style: const ButtonStyle().copyWith(shape: MaterialStateProperty.all<RoundedRectangleBorder>(const RoundedRectangleBorder()),
                              foregroundBuilder: ((context, state, child){
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    currShop.photoMap['macarons']! == '' ? const SizedBox(height: 100,) : Image.file(File(currShop.photoMap['macarons']!),width: 50,height: 100, filterQuality: FilterQuality.none),

                                    const Text('Макароны'),
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children:[
                                          IconButton(
                                            icon: const Icon(Icons.check_rounded, color: Colors.green,)
                                            , onPressed: (){
                                            sqlFliteDB.setPhoto(args.shopId, PhotoType.macarons, 'yes');
                                            setState((){});
                                          },),
                                          IconButton(icon: const Icon(Icons.close_rounded, color: Colors.red,),
                                              onPressed:currShop.photoMap['macarons']! == '' ? null : ()async{
                                                bool? isShow = await deletePhoto(context);
                                                if(isShow != null && isShow){
                                                  sqlFliteDB.setPhoto(args.shopId, PhotoType.macarons, '');
                                                }
                                              })
                                        ])
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
                        if(currShop.photoMap['meatKonserv'] != ''){
                          bool? isShow = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              content: const Text('Фото мясных консерв уже есть, хотите перезаписать?'),
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
                            sqlFliteDB.setPhoto(args.shopId, PhotoType.meatKonserv, '');
                            Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.meatKonserv));
                          }
                        }else{
                          Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.meatKonserv));
                        }
                      }, child: null,
                          style: const ButtonStyle().copyWith(shape: MaterialStateProperty.all<RoundedRectangleBorder>(const RoundedRectangleBorder()),
                              foregroundBuilder: ((context, state, child){
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    currShop.photoMap['meatKonserv']! == '' ? const SizedBox(height: 100,) : Image.file(File(currShop.photoMap['meatKonserv']!),width: 50,height: 100, filterQuality: FilterQuality.none),
                                    const Text('Мясные консервы'),
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children:[
                                          IconButton(
                                            icon: const Icon(Icons.check_rounded, color: Colors.green,)
                                            , onPressed: (){
                                            sqlFliteDB.setPhoto(args.shopId, PhotoType.meatKonserv, 'yes');
                                            setState((){});
                                          },),
                                          IconButton(icon: const Icon(Icons.close_rounded, color: Colors.red,),
                                              onPressed:currShop.photoMap['meatKonserv']! == '' ? null : ()async{
                                                bool? isShow = await deletePhoto(context);
                                                if(isShow != null && isShow){
                                                  sqlFliteDB.setPhoto(args.shopId, PhotoType.meatKonserv, '');
                                                }
                                              })
                                        ])
                                  ],
                                );
                              })
                          )
                      ),
                      ElevatedButton(onPressed: ()async{
                        if(currShop.photoMap['fishKonserv'] != ''){
                          bool? isShow = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              content: const Text('Фото рыбных консерв уже есть, хотите перезаписать?'),
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
                            sqlFliteDB.setPhoto(args.shopId, PhotoType.fishKonserv, '');
                            Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.fishKonserv));
                          }
                        }else{
                          Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.fishKonserv));
                        }
                      }, child: null,
                          style: const ButtonStyle().copyWith(shape: MaterialStateProperty.all<RoundedRectangleBorder>(const RoundedRectangleBorder()),
                              foregroundBuilder: ((context, state, child){
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    currShop.photoMap['fishKonserv']! == '' ? const SizedBox(height: 100,) : Image.file(File(currShop.photoMap['fishKonserv']!),width: 50,height: 100, filterQuality: FilterQuality.none),
                                    const Text('Рыбные консервы'),
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children:[
                                          IconButton(
                                            icon: const Icon(Icons.check_rounded, color: Colors.green,)
                                            , onPressed: (){
                                            sqlFliteDB.setPhoto(args.shopId, PhotoType.fishKonserv, 'yes');
                                            setState((){});
                                          },),
                                          IconButton(icon: const Icon(Icons.close_rounded, color: Colors.red,),
                                              onPressed:currShop.photoMap['fishKonserv']! == '' ? null : ()async{
                                                bool? isShow = await deletePhoto(context);
                                                if(isShow != null && isShow){
                                                  sqlFliteDB.setPhoto(args.shopId, PhotoType.fishKonserv, '');
                                                }
                                              })
                                        ])
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
                        if(currShop.photoMap['fruitKonserv'] != ''){
                          bool? isShow = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              content: const Text('Фото фруктовых и овощных консерв уже есть, хотите перезаписать?'),
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
                            sqlFliteDB.setPhoto(args.shopId, PhotoType.fruitKonserv, '');
                            Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.fruitKonserv));
                          }
                        }else{
                          Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.fruitKonserv));
                        }
                      }, child: null,
                          style: const ButtonStyle().copyWith(shape: MaterialStateProperty.all<RoundedRectangleBorder>(const RoundedRectangleBorder()),
                              foregroundBuilder: ((context, state, child){
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    currShop.photoMap['fruitKonserv']! == '' ? const SizedBox(height: 100,) : Image.file(File(currShop.photoMap['fruitKonserv']!),width: 50,height: 100, filterQuality: FilterQuality.none),

                                    const Text('Фруктовые/овощные консервы'),
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children:[
                                          IconButton(
                                            icon: const Icon(Icons.check_rounded, color: Colors.green,)
                                            , onPressed: (){
                                            sqlFliteDB.setPhoto(args.shopId, PhotoType.fruitKonserv, 'yes');
                                            setState((){});
                                          },),
                                          IconButton(icon: const Icon(Icons.close_rounded, color: Colors.red,),
                                              onPressed:currShop.photoMap['fruitKonserv']! == '' ? null : ()async{
                                                bool? isShow = await deletePhoto(context);
                                                if(isShow != null && isShow){
                                                  sqlFliteDB.setPhoto(args.shopId, PhotoType.fruitKonserv, '');
                                                }
                                              })
                                        ])
                                  ],
                                );
                              })
                          )
                      ),
                      ElevatedButton(onPressed: ()async{
                        if(currShop.photoMap['milkKonserv'] != ''){
                          bool? isShow = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              content: const Text('Фото молочных консерв уже есть, хотите перезаписать?'),
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
                            sqlFliteDB.setPhoto(args.shopId, PhotoType.milkKonserv, '');
                            Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.milkKonserv));
                          }
                        }else{
                          Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: args.shopId, photoType: PhotoType.milkKonserv));
                        }
                      }, child: null,
                          style: const ButtonStyle().copyWith(shape: MaterialStateProperty.all<RoundedRectangleBorder>(const RoundedRectangleBorder()),
                              foregroundBuilder: ((context, state, child){
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    currShop.photoMap['milkKonserv']! == '' ? const SizedBox(height: 100,) : Image.file(File(currShop.photoMap['milkKonserv']!),width: 50,height: 100, filterQuality: FilterQuality.none),
                                    const Text('Сгущёнка'),
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children:[
                                          IconButton(
                                            icon: const Icon(Icons.check_rounded, color: Colors.green,)
                                            , onPressed: (){
                                            sqlFliteDB.setPhoto(args.shopId, PhotoType.milkKonserv, 'yes');
                                            setState((){});
                                          },),
                                          IconButton(icon: const Icon(Icons.close_rounded, color: Colors.red,),
                                              onPressed:currShop.photoMap['milkKonserv']! == '' ? null : ()async{
                                                bool? isShow = await deletePhoto(context);
                                                if(isShow != null && isShow){
                                                  sqlFliteDB.setPhoto(args.shopId, PhotoType.milkKonserv, '');
                                                }
                                              })
                                        ])
                                  ],
                                );
                              })
                          )
                      ),
                    ]
                ),
              ],
            )
          ]
      ),
    );
  }
}