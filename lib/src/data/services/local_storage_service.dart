import 'dart:convert';

import 'package:idez_todos/src/domain/models/task_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  final SharedPreferences prefs;

  const LocalStorageService(this.prefs);

  static Future<LocalStorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorageService(prefs);
  }

  Future<bool> set<T>(String key, T value) async {
    return switch (T) {
      const (String) => await prefs.setString(key, value as String),
      const (int) => await prefs.setInt(key, value as int),
      const (double) => await prefs.setDouble(key, value as double),
      const (bool) => await prefs.setBool(key, value as bool),
      const (List<String>) => await prefs.setStringList(key, value as List<String>),
      const (TaskModel) => await prefs.setString(key, json.encode((value as TaskModel).toJson())),
      const (List<TaskModel>) => await prefs.setStringList(
        key,
        (value as List<TaskModel>).map((e) => json.encode(e.toJson())).toList(),
      ),
      _ => throw Exception('Type $T not supported!'),
    };
  }

  T? get<T>(String key) {
    if (!exists(key)) return null;

    return switch (T) {
      const (String) => prefs.getString(key) as T,
      const (int) => prefs.getInt(key) as T,
      const (double) => prefs.getDouble(key) as T,
      const (bool) => prefs.getBool(key) as T,
      const (List<String>) => prefs.getStringList(key) as T,
      const (TaskModel) => TaskModel.fromJson(json.decode(prefs.getString(key) ?? '{}')) as T,
      const (List<TaskModel>) => prefs.getStringList(key)?.map((e) => TaskModel.fromJson(json.decode(e))).toList() as T,
      _ => throw Exception('Type $T not supported!'),
    };
  }

  Future<bool> delete(String key) async {
    return await prefs.remove(key);
  }

  Future<bool> clear() async {
    return await prefs.clear();
  }

  bool exists(String key) {
    return prefs.containsKey(key);
  }
}
