import 'dart:convert';

import 'package:idez_todos/src/core/exception_extension.dart';
import 'package:idez_todos/src/core/exceptions.dart';
import 'package:idez_todos/src/core/result.dart';
import 'package:idez_todos/src/domain/models/task_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/v7.dart';

import 'tasks_repository.dart';

class TasksRepositoryImp implements TasksRepository {
  final SharedPreferences _prefs;

  const TasksRepositoryImp(this._prefs);

  List<TaskModel> _getTasksFromStorage() {
    final tasksJson = _prefs.getStringList('tasks') ?? [];
    return tasksJson.map((e) => TaskModel.fromJson(json.decode(e))).toList();
  }

  Future<void> _saveTasksToStorage(List<TaskModel> tasks) async {
    final tasksJson = tasks.map((e) => json.encode(e.toJson())).toList();
    await _prefs.setStringList('tasks', tasksJson);
  }

  @override
  AsyncResult<TaskModel> insertOne(String title) async {
    try {
      final tasks = _getTasksFromStorage();
      final todo = TaskModel.create(id: UuidV7().generate(), title: title);
      tasks.add(todo);
      await _saveTasksToStorage(tasks);
      return Result.value(todo);
    } on Exception catch (e) {
      return Result.exception(UnknownException(e.message()));
    }
  }

  @override
  AsyncResult<List<TaskModel>> findMany([bool? done]) async {
    try {
      var tasks = _getTasksFromStorage();
      if (done != null) {
        tasks = tasks.where((element) => element.done == done).toList();
      }
      return Result.value(tasks..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
    } on Exception catch (e) {
      return Result.exception(UnknownException(e.message()));
    }
  }

  @override
  AsyncResult<TaskModel> updateOne(String id, UpdateOneTaskParams params) async {
    try {
      if (params.isEmpty) {
        throw RepositoryException('Title or done must be provided');
      }
      final tasks = _getTasksFromStorage();
      final index = tasks.indexWhere((element) => element.id == id);
      if (index == -1) {
        throw RepositoryException('Task not found');
      }
      final task = tasks[index];
      tasks[index] = task.copyWith(
        title: params.title ?? task.title,
        done: params.done ?? task.done,
        updatedAt: DateTime.now(),
      );
      await _saveTasksToStorage(tasks);
      return Result.value(tasks[index]);
    } on AppException catch (e) {
      return Result.exception(e);
    } on Exception catch (e) {
      return Result.exception(UnknownException(e.message()));
    }
  }

  @override
  AsyncResult<TaskModel> deleteOne(String id) async {
    try {
      final tasks = _getTasksFromStorage();
      final index = tasks.indexWhere((element) => element.id == id);
      if (index == -1) {
        throw RepositoryException('Task not found');
      }
      final task = tasks.removeAt(index);
      await _saveTasksToStorage(tasks);
      return Result.value(task);
    } on AppException catch (e) {
      return Result.exception(e);
    } on Exception catch (e) {
      return Result.exception(UnknownException(e.message()));
    }
  }
}
