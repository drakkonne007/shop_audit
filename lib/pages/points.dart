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
  Set<int> _uselessPoints = {};

  @override
  void initState() {
    super.initState();
    _uselessPoints = PointFromDbHandler().uselessPoints;
    listAllPoints = PointFromDbHandler().pointsFromDb.value.values.toList();
    PointFromDbHandler().pointsFromDb.addListener(updateListAllPoint);
  }

  @override
  void dispose() {
    super.dispose();
    PointFromDbHandler().pointsFromDb.removeListener(updateListAllPoint);
  }

  void updateListAllPoint()
  {
    setState(() {
      listAllPoints = PointFromDbHandler().pointsFromDb.value.values.toList();
      _uselessPoints = PointFromDbHandler().uselessPoints;
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
                PointFromDbHandler().sortType = SortType.None;
                PointFromDbHandler().pointsFromDb.notifyListeners();
              }, child: Text('Все')
              ),
              ElevatedButton(onPressed: (){
                PointFromDbHandler().sortType = SortType.Distance;
                PointFromDbHandler().pointsFromDb.notifyListeners();
              }, child: Text('Ближе 5 километров')
              ),
              ElevatedButton(onPressed: (){
                PointFromDbHandler().sortType = SortType.IsNeedReport;
                PointFromDbHandler().pointsFromDb.notifyListeners();
              }, child: Text('Только нужные')
              ),
              ElevatedButton(onPressed: (){
                PointFromDbHandler().sortType = SortType.DateTimeCreated;
                PointFromDbHandler().pointsFromDb.notifyListeners();
              }, child: Text('За последний месяц')
              ),
              Expanded(
                  child:
                  ListView.builder(
                      itemCount: listAllPoints.length,
                      itemBuilder: (BuildContext context, int index) {
                        print('refreshList');
                        print(_uselessPoints);
                        return Row(children:
                        [
                          Checkbox(
                            value: _uselessPoints.contains(listAllPoints[index].id) ? false : true,
                            onChanged: (val){},
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