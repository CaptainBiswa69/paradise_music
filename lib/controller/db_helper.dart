import 'package:hive/hive.dart';

class DbHelper {
  late Box box;

  DbHelper() {
    openBox();
  }

  openBox() {
    box = Hive.box("Music");
  }

  Future addData(String data, var value) async {
    box.put(data, value);
  }

  Future getData(String data) async {
    box.get(data);
  }
}
