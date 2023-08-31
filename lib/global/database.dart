
import 'package:postgres/postgres.dart';
import 'package:shop_audit/global/shop_points_for_job.dart';


class DatabaseClient
{
  static final DatabaseClient _databaseClient = DatabaseClient._internal();
  factory DatabaseClient() {
    return _databaseClient;
  }
  DatabaseClient._internal();

  var connection = PostgreSQLConnection("192.168.56.1", 5432, "shop_audit_clear", username: "postgres", password: "1");
  int auditorId = 0;

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
    var result = await connection.query("SELECT * FROM shop_audit_clear.shop WHERE enabled ANS has_report = false ORDER BY date_time_created DESC");
    var columnNames = result.columnDescriptions;
    Map<String,int> map = {};
    for(int i=0;i<columnNames.length;i++){
      map.putIfAbsent(columnNames[i].columnName, () => i);
    }
    for (final row in result) {
      PointFromDb point = PointFromDb();
      if(map.containsKey('x')){
        point.x = row[map['x']!] as double;
      }
      if(map.containsKey('y')){
        point.y = row[map['y']!] as double ;
      }
      if(map.containsKey('name')){
        point.name = row[map['name']!] ?? '';
      }
      if(map.containsKey('description')){
        point.description = row[map['description']!] ?? '';
      }
      if(map.containsKey('start_work_time')){
        point.startWorkingTime = row[map['start_work_time']!].toString() ?? '';
      }
      if(map.containsKey('finish_work_time')){
        point.endWorkingTime = row[map['finish_work_time']!].toString() ?? '';
      }
      if(map.containsKey('date_time_created')){
        point.dateTimeCreated = row[map['date_time_created']!] ?? DateTime.now();
      }
      if(map.containsKey('has_report')){
        point.isWasReport = row[map['has_report']!] == 1;
      }
      if(map.containsKey('id')){
        point.id = row[map['id']!] as int;
      }
      PointFromDbHandler().pointsFromDb.value.putIfAbsent(point.id, () => point);
    }
    PointFromDbHandler().pointsFromDb.notifyListeners();
  }

  Future<bool> checkAccess(String login, String password)async
  {
    var result = await connection.query("SELECT id FROM shop_audit_clear.user WHERE login='$login' AND password='$password' AND enabled=true LIMIT 1");
    if(result.isEmpty){
      return false;
    }
    auditorId = result.first[0];
    return true;
  }
}