import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shop_audit/component/internal_shop.dart';
import 'package:shop_audit/global/global_variants.dart';
import 'package:shop_audit/main.dart';
import 'package:shop_audit/pages/shopPage.dart';

class DoReport extends StatefulWidget
{

  static const String doReport = '/doReport';

  const DoReport({super.key});

  @override
  State<DoReport> createState() => _DoReportState();
}

class _DoReportState extends State<DoReport>
{
  @override
  Widget build(BuildContext context)
  {
    final InternalShop currShop = ModalRoute.of(context)!.settings.arguments as InternalShop;
    return Scaffold(
      appBar: AppBar(
        title: Text('Отчёт: ${currShop.shopName}'),
      ),
      body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: ()async{
                  if(currShop.reportPhoto != ''){
                    bool? isShow = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        content: const Text('Фото отчёта уже есть, хотите перезаписать?'),
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
                      currShop.reportPhoto = '';
                      Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: currShop.id, photoType: PhotoType.reportPhoto, isFromReport: true));
                    }
                  }else{
                    Navigator.of(context).pushNamed('/photoPage',arguments: CustomArgument(shopId: currShop.id, photoType: PhotoType.externalPhoto, isFromReport: true));
                  }
                }, child: null,
                    style: const ButtonStyle().copyWith(shape: MaterialStateProperty.all<RoundedRectangleBorder>(const RoundedRectangleBorder()),
                        foregroundBuilder: ((context, state, child){
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              currShop.reportPhoto == '' ? const SizedBox(height: 100,) : Image.file(File(currShop.reportPhoto),width: 50,height: 100, filterQuality: FilterQuality.none),
                              const Text('Отчётное фото'),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children:[
                                    Container(width: 100,),
                                    IconButton(
                                      icon: const Icon(Icons.close_rounded, color: Colors.red,)
                                      , onPressed: currShop.reportPhoto == '' ? null : ()async{
                                      bool? isShow = await deletePhoto(context);
                                      setState(() {});
                                      if(isShow != null && isShow){
                                        sqlFliteDB.setReportPhoto(currShop.id, '');
                                      }
                                    },)
                                  ]
                              ),

                            ],
                          );
                        })
                    )
                ),
                ElevatedButton(
                    onPressed:(){Navigator.of(context).pushNamed('/shopPage', arguments: currShop);}
                    ,child: const Text('Изменить полную информацию о магазине'))
              ],
            ),

          )
      ),
    );
  }
}