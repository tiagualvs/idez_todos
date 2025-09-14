import 'package:flutter/material.dart';
import 'package:idez_todos/src/core/command.dart';
import 'package:idez_todos/src/core/exceptions.dart';
import 'package:idez_todos/src/core/result.dart';
import 'package:idez_todos/src/data/repositories/tasks/tasks_repository.dart';
import 'package:idez_todos/src/domain/models/task_model.dart';

class TasksViewModel extends ChangeNotifier {
  final TasksRepository repository;

  Set<bool?> _filters = {null};

  Set<bool?> get filters => _filters;

  List<TaskModel> _tasks = [];

  List<TaskModel> get tasks => _tasks;

  late final Command1<void, Set<bool?>> setFilters;

  late final Command1<void, bool?> findMany;

  late final Command1<void, String> insertOne;

  late final Command2<void, String, UpdateOneTaskParams> updateOne;

  late final Command1<void, String> deleteOne;

  Listenable get listenable => Listenable.merge([
    this,
    setFilters,
    findMany,
    insertOne,
    updateOne,
    deleteOne,
  ]);

  TasksViewModel(this.repository) {
    setFilters = Command1(_setFilters);
    findMany = Command1(_findMany);
    insertOne = Command1(_insertOne);
    updateOne = Command2(_updateOne);
    deleteOne = Command1(_deleteOne);
  }

  AsyncResult<void> _setFilters(Set<bool?> filters) async {
    _filters = filters;
    if (_filters.contains(true)) {
      return await _findMany(true);
    } else if (_filters.contains(false)) {
      return await _findMany(false);
    } else {
      return await _findMany(null);
    }
  }

  AsyncResult<void> _findMany(bool? done) async {
    final result = await repository.findMany(done);
    return result.fold(
      (todos) {
        _tasks = todos;
        notifyListeners();
        return Result.value(null);
      },
      (exception) {
        return Result.exception(exception);
      },
    );
  }

  AsyncResult<void> _insertOne(String title) async {
    final result = await repository.insertOne(title);
    return result.fold(
      (todo) {
        _tasks.insert(0, todo);
        notifyListeners();
        return Result.value(null);
      },
      (exception) {
        return Result.exception(exception);
      },
    );
  }

  AsyncResult<void> _updateOne(String id, UpdateOneTaskParams params) async {
    final result = await repository.updateOne(id, params);
    return result.fold(
      (success) {
        final index = _tasks.indexWhere((todo) => todo.id == id);
        if (index == -1) {
          return Result.exception(ViewModelException('Task not found'));
        }
        _tasks[index] = success;
        return Result.value(null);
      },
      (exception) {
        return Result.exception(exception);
      },
    );
  }

  AsyncResult<void> _deleteOne(String id) async {
    final result = await repository.deleteOne(id);
    return result.fold(
      (value) {
        final index = _tasks.indexWhere((todo) => todo.id == id);
        if (index == -1) {
          return Result.exception(ViewModelException('Task not found'));
        }
        _tasks.removeAt(index);
        notifyListeners();
        return Result.value(null);
      },
      (exception) {
        return Result.exception(exception);
      },
    );
  }
}
