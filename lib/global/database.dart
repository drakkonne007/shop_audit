
import 'package:postgres/postgres.dart';
import 'package:shop_audit/global/shop_points_for_job.dart';


class DatabaseClient
{
  static final DatabaseClient _databaseClient = DatabaseClient._internal();
  factory DatabaseClient() {
    return _databaseClient;
  }
  DatabaseClient._internal();

  var connection = PostgreSQLConnection("10.11.100.189", 5432, "shop_audit_clear", username: "postgres", password: "1");

  Future<bool> openDB()async
  {
    await connection.open();
    if(connection.isClosed){
      return false;
    }
    return true;
  }

  void getShopPoints() async
  {
    print('start getShopPoints');
    if(PointFromDbHandler().isNeedLoad != true){
      return;
    }
    var result = await connection.query("SELECT * FROM shop_audit_clear.shop WHERE enabled=true ORDER BY date_time_created DESC");
    var columnNames = result.columnDescriptions;
    Map<String,int> map = {};
    for(int i=0;i<columnNames.length;i++){
      print(columnNames[i].columnName);
      map.putIfAbsent(columnNames[i].columnName, () => i);
    }
    for (final row in result) {
      PointFromDb point = PointFromDb();
      if(map.containsKey('x')){
        print(row[map['x']!]);
        point.x = row[map['x']!] as double;
      }
      if(map.containsKey('y')){
        print(row[map['y']!]);
        point.y = row[map['y']!] as double ;
      }
      if(map.containsKey('name')){
        print(row[map['name']!]);
        point.name = row[map['name']!] ?? '';
      }
      if(map.containsKey('description')){
        print(row[map['description']!]);
        point.description = row[map['description']!] ?? '';
      }
      if(map.containsKey('start_work_time')){
        print(row[map['start_work_time']!]);
        point.startWorkingTime = row[map['start_work_time']!] ?? DateTime(2000);
      }
      if(map.containsKey('finish_work_time')){
        print(row[map['finish_work_time']!]);
        point.endWorkingTime = row[map['finish_work_time']!] ?? DateTime(2000);
      }
      if(map.containsKey('date_time_created')){
        print(row[map['date_time_created']!]);
        point.dateTimeCreated = row[map['date_time_created']!] ?? DateTime.now();
      }
      if(map.containsKey('has_report')){
        print(row[map['has_report']!]);
        point.isWasReport = row[map['has_report']!] == 1;
      }
      if(map.containsKey('id')){
        print(row[map['id']!]);
        point.id = row[map['id']!] as int;
      }
      PointFromDbHandler().pointsFromDb.value.putIfAbsent(point.id, () => point);
    }
    PointFromDbHandler().isNeedLoad = false;
    PointFromDbHandler().pointsFromDb.notifyListeners();
  }

  Future<bool> checkAccess(String login, String password)async
  {
    var result = await connection.query("SELECT * FROM shop_audit_clear.user WHERE login='$login' AND password='$password' AND enabled=true");
    if(result.isEmpty){
      return false;
    }
    return true;
  }

}