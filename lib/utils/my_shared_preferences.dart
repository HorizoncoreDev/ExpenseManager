import 'package:shared_preferences/shared_preferences.dart';

class MySharedPreferences {
  MySharedPreferences._privateConstructor();

  static final MySharedPreferences instance =
      MySharedPreferences._privateConstructor();

  addBoolToSF(var key, var value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }

  addStringToSF(var key, var value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  addIntToSF(var key, var value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(key, value);
  }

  addDoubleToSF(var key, var value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble(key, value);
  }

  Future<String?> getStringValuesSF(var key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? stringValue = prefs.getString(key);
    return stringValue;
  }

  Future<bool?> getBoolValuesSF(var key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? boolValue = prefs.getBool(key);
    return boolValue ?? false;
  }

  Future<int?> getIntValuesSF(var key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? intValue = prefs.getInt(key);
    return intValue;
  }

  Future<double?> getDoubleValuesSF(var key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double? doubleValue = prefs.getDouble(key);
    return doubleValue;
  }

  removeValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("stringValue");
    prefs.remove("boolValue");
    prefs.remove("intValue");
    prefs.remove("doubleValue");
  }
}
