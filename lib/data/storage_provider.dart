import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

const String _defaultDifficultiesJson =
    '[[-1,-1,-1,-1,-1,-1],[-1,-1,-1,-1,-1,-1],[-1,-1,-1,-1,-1,-1],[-1,-1,-1,-1,-1,-1]]';

class SPrefProvider {
  //читаем сложности из файла
  static Future<List<List<int>>> readDifficultiesFromSPref() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String listAsJson =
        prefs.getString('difficulties') ?? _defaultDifficultiesJson;
    return _Converter.convertJsonToList(listAsJson);
  }

  //записываем сложности в файл
  static Future<void> writeDifficultiesToSPref(
      List<List<int>> inputValue) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'difficulties', _Converter.convertListToJson(inputValue));
  }

  //читаем размеры шрифтов из файла
  static Future<void> readFontsFromSPref() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
  }

  //записываем размеры шрифтов в файл
  static Future<void> writeFontsToSPref() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
  }
}

class _Converter {
  static List<List<int>> convertJsonToList(String listAsJson) {
    List decodedList = jsonDecode(listAsJson);
    List<List<int>> difficultiesList = [];
    for (int i = 0; i < decodedList.length; i++) {
      List<int> localListOfInts = [];
      for (int y = 0; y < decodedList[i].length; y++) {
        localListOfInts.add(decodedList[i][y]);
      }
      difficultiesList.add(localListOfInts);
    }
    return difficultiesList;
  }

  static String convertListToJson(List<List<int>> inputValue) {
    String listAsJson = jsonEncode(inputValue);
    return listAsJson;
  }
}
