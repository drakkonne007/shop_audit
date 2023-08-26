import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shop_audit/global/shop_points_for_job.dart';

class CustomCheck extends Checkbox
{
  CustomCheck({required super.value, required super.onChanged});
}

class PointsPage extends StatefulWidget
{
  @override
  State<PointsPage> createState() => _PointsPageState();
}

class _PointsPageState extends State<PointsPage> {

  var listAllPoints = [];

  @override
  void initState() {
    listAllPoints = PointFromDbHandler().pointsFromDb.value.values.toList();
    PointFromDbHandler().pointsFromDb.addListener(updateListAllPoint);
    super.initState();
  }

  @override
  void dispose() {
    PointFromDbHandler().pointsFromDb.removeListener(updateListAllPoint);
    super.dispose();
  }

  void updateListAllPoint()
  {
    setState(() {
      listAllPoints = PointFromDbHandler().pointsFromDb.value.values.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              ElevatedButton(onPressed: (){
                PointFromDbHandler().showAllPointByUser();
                PointFromDbHandler().pointsFromDb.notifyListeners();
              }, child: Text('Сбросить отмеченные ыручную')
              ),
              ElevatedButton(onPressed: (){
                PointFromDbHandler().sortType = SortType.None;
                PointFromDbHandler().showAllPointByUser();
                PointFromDbHandler().pointsFromDb.notifyListeners();
              }, child: Text('Все')
              ),
              ElevatedButton(onPressed: (){
                PointFromDbHandler().sortType = SortType.Distance;
                PointFromDbHandler().showAllPointByUser();
                PointFromDbHandler().pointsFromDb.notifyListeners();
              }, child: Text('Ближе 5 километров')
              ),
              ElevatedButton(onPressed: (){
                PointFromDbHandler().sortType = SortType.IsNeedReport;
                PointFromDbHandler().showAllPointByUser();
                PointFromDbHandler().pointsFromDb.notifyListeners();
              }, child: Text('Только нужные')
              ),
              ElevatedButton(onPressed: (){
                PointFromDbHandler().sortType = SortType.DateTimeCreated;
                PointFromDbHandler().showAllPointByUser();
                PointFromDbHandler().pointsFromDb.notifyListeners();
              }, child: Text('За последний месяц')
              ),
              Expanded(
                  child:
                  ListView.builder(
                      itemCount: listAllPoints.length,
                      itemBuilder: (BuildContext context, int index) {
                        print('refreshList');
                        return Row(children:
                        [
                          Checkbox(
                            value: PointFromDbHandler().isNeedShop(listAllPoints[index].id),
                            onChanged: (val){
                              if(val == true){
                                PointFromDbHandler().pointsFromDb.value[listAllPoints[index].id]!.isNeedDrawByCustom = true;
                              }else{
                                PointFromDbHandler().pointsFromDb.value[listAllPoints[index].id]!.isNeedDrawByCustom = false;
                              }
                              PointFromDbHandler().pointsFromDb.notifyListeners();
                            },
                          ),
                          Text(listAllPoints[index].name)
                        ]);
                      }
                  )
              )
            ]
        )
    );
  }
}