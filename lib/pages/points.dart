import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PointsPage extends StatelessWidget
{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              Checkbox(
                value: true,
                onChanged: (val) => true,
                semanticLabel: 'Checkbox',
              ),
              Checkbox(
                value: true,
                onChanged: (val) => true,
                semanticLabel: 'Checkbox',
              ),
              Checkbox(
                value: true,
                onChanged: (val) => true,
                semanticLabel: 'Checkbox',
              ),
              Checkbox(
                value: true,
                onChanged: (val) => true,
                semanticLabel: 'Checkbox',
              ),
              Expanded(
                  child:
                  ListView.builder(
                      itemCount: 50,
                      itemBuilder: (BuildContext context, int index) {
                        return Checkbox(
                          value: true,
                          onChanged: (val) => true,
                          semanticLabel: '$index',
                        );
                      }
                  )
              )
            ]
        )
    );
  }
}