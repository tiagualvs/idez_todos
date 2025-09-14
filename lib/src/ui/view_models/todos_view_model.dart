import 'package:flutter/material.dart';
import 'package:idez_todos/src/data/repositories/tasks/tasks_repository.dart';
import 'package:idez_todos/src/domain/models/task_model.dart';

class TodosViewModel extends ChangeNotifier {
  final TasksRepository repository;

  Set<bool?> _filters = {null};

  Set<bool?> get filters => _filters;

  List<TaskModel> _tasks = [];

  List<TaskModel> get tasks => _tasks;

  TodosViewModel(this.repository);

  Future<void> setFilters(
    Set<bool?> filters, {
    void Function(int length)? onSuccess,
    void Function(String error)? onError,
  }) async {
    _filters = filters;
    if (_filters.contains(true)) {
      return await findMany(done: true, onSuccess: onSuccess, onError: onError);
    } else if (_filters.contains(false)) {
      return await findMany(done: false, onSuccess: onSuccess, onError: onError);
    } else {
      return await findMany(onSuccess: onSuccess, onError: onError);
    }
  }

  Future<void> findMany({
    bool? done,
    void Function(int length)? onSuccess,
    void Function(String error)? onError,
  }) async {
    final result = await repository.findMany(done);
    return result.fold(
      (todos) {
        _tasks = todos;
        notifyListeners();
        return onSuccess?.call(_tasks.length);
      },
      (error) {
        return onError?.call(error.toString());
      },
    );
  }

  Future<void> insertOne(
    String title, {
    void Function(int length)? onSuccess,
    void Function(String error)? onError,
  }) async {
    final result = await repository.insertOne(title);
    return result.fold(
      (todo) {
        _tasks.insert(0, todo);
        notifyListeners();
        return onSuccess?.call(_tasks.length);
      },
      (error) {
        return onError?.call(error.toString());
      },
    );
  }

  Future<void> deleteOne(
    String id, {
    void Function()? onSuccess,
    void Function(String error)? onError,
  }) async {
    final result = await repository.deleteOne(id);
    return result.fold(
      (success) {
        _tasks.removeWhere((todo) => todo.id == id);
        notifyListeners();
        return onSuccess?.call();
      },
      (error) {
        return onError?.call(error.toString());
      },
    );
  }

  Future<void> updateOne(
    String id, {
    String? title,
    bool? done,
    void Function()? onSuccess,
    void Function(String error)? onError,
  }) async {
    final result = await repository.updateOne(id, title: title, done: done);
    return result.fold(
      (success) {
        final index = _tasks.indexWhere((element) => element.id == id);
        final todo = _tasks[index];
        _tasks[index] = todo.copyWith(title: title ?? todo.title, done: done ?? todo.done);
        notifyListeners();
        return onSuccess?.call();
      },
      (error) {
        return onError?.call(error.toString());
      },
    );
  }
}
