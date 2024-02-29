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
    final args = ModalRoute.of(context)!.settings.arguments as CustomArgument;
    var currShop = sqlFliteDB.shops[args.shopId]!;
    return Scaffold(
      appBar: AppBar(
        title: Text(currShop.shopName),
        actions: [
          ElevatedButton(
            child: const Text('Отослать'),
            onPressed: (){
              sqlFliteDB.sendShopToServer([currShop]);
              Navigator.of(context).pop();
            },
          )
        ]
      ),
      body: Column(
          children: [
            TextButton(child: const Text('Анкета'), onPressed: (){
              Navigator.of(context).popAndPushNamed('/anketaPage',arguments: CustomArgument(shopId: args.shopId));
            }),
            Expanded(
                child: Table(
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
                              style: defaultNoneButtonStyle.copyWith(
                                  backgroundBuilder: ((context, state, child){
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        currShop.photoMap['externalPhoto']! == '' ? const SizedBox(width: 50,height: 50,) : Image.asset(currShop.photoMap['externalPhoto']!,width: 50,height: 50,),
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
                              style: defaultNoneButtonStyle.copyWith(
                                  backgroundBuilder: ((context, state, child){
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        currShop.photoMap['shopLabelPhoto']! == '' ? const SizedBox(width: 50,height: 50,) : Image.asset(currShop.photoMap['shopLabelPhoto']!,width: 50,height: 50,),
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
                              style: defaultNoneButtonStyle.copyWith(
                                  backgroundBuilder: ((context, state, child){
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        currShop.photoMap['alkoholPhoto']! == '' ? const SizedBox(width: 50,height: 50,) : Image.asset(currShop.photoMap['alkoholPhoto']!,width: 50,height: 50,),
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
                              style: defaultNoneButtonStyle.copyWith(
                                  backgroundBuilder: ((context, state, child){
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        currShop.photoMap['nonAlkoholPhoto']! == '' ? const SizedBox(width: 50,height: 50,) : Image.asset(currShop.photoMap['nonAlkoholPhoto']!,width: 50,height: 50,),
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
                              style: defaultNoneButtonStyle.copyWith(
                                  backgroundBuilder: ((context, state, child){
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        currShop.photoMap['kolbasaSyr']! == '' ? const SizedBox(width: 50,height: 50,) : Image.asset(currShop.photoMap['kolbasaSyr']!,width: 50,height: 50,),
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
                              style: defaultNoneButtonStyle.copyWith(
                                  backgroundBuilder: ((context, state, child){
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        currShop.photoMap['milk']! == '' ? const SizedBox(width: 50,height: 50,) : Image.asset(currShop.photoMap['milk']!,width: 50,height: 50,),
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
                              style: defaultNoneButtonStyle.copyWith(
                                  backgroundBuilder: ((context, state, child){
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        currShop.photoMap['snack']! == '' ? const SizedBox(width: 50,height: 50,) : Image.asset(currShop.photoMap['snack']!,width: 50,height: 50,),
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
                              style: defaultNoneButtonStyle.copyWith(
                                  backgroundBuilder: ((context, state, child){
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        currShop.photoMap['konditer']! == '' ? const SizedBox(width: 50,height: 50,) : Image.asset(currShop.photoMap['konditer']!,width: 50,height: 50,),
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
                              style: defaultNoneButtonStyle.copyWith(
                                  backgroundBuilder: ((context, state, child){
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        currShop.photoMap['konserv']! == '' ? const SizedBox(width: 50,height: 50,) : Image.asset(currShop.photoMap['konserv']!,width: 50,height: 50,),
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
                              style: defaultNoneButtonStyle.copyWith(
                                  backgroundBuilder: ((context, state, child){
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        currShop.photoMap['mylomoika']! == '' ? const SizedBox(width: 50,height: 50,) : Image.asset(currShop.photoMap['mylomoika']!,width: 50,height: 50,),
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
                              style: defaultNoneButtonStyle.copyWith(
                                  backgroundBuilder: ((context, state, child){
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        currShop.photoMap['vegetablesFruits']! == '' ? const SizedBox(width: 50,height: 50,) : Image.asset(currShop.photoMap['vegetablesFruits']!,width: 50,height: 50,),
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
                              style: defaultNoneButtonStyle.copyWith(
                                  backgroundBuilder: ((context, state, child){
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        currShop.photoMap['cigarettes']! == '' ? const SizedBox(width: 50,height: 50,) : Image.asset(currShop.photoMap['cigarettes']!,width: 50,height: 50,),
                                        const Text('Сигареты')
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
                              style: defaultNoneButtonStyle.copyWith(
                                  backgroundBuilder: ((context, state, child){
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        currShop.photoMap['kassovayaZona']! == '' ? const SizedBox(width: 50,height: 50,) : Image.asset(currShop.photoMap['kassovayaZona']!,width: 50,height: 50,),
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
                              style: defaultNoneButtonStyle.copyWith(
                                  backgroundBuilder: ((context, state, child){
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        currShop.photoMap['toys']! == '' ? const SizedBox(width: 50,height: 50,) : Image.asset(currShop.photoMap['toys']!,width: 50,height: 50,),
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
                                      child: const Text('Да'),
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
                              style: defaultNoneButtonStyle.copyWith(
                                  backgroundBuilder: ((context, state, child){
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        currShop.photoMap['butter']! == '' ? const SizedBox(width: 50,height: 50,) : Image.asset(currShop.photoMap['butter']!,width: 50,height: 50,),
                                        const Text('Хлеб')
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
            )
          ]
      ),
    );
  }
}