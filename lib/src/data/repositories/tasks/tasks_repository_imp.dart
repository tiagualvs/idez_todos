import 'package:idez_todos/src/core/result.dart';
import 'package:idez_todos/src/data/services/local_storage_service.dart';
import 'package:idez_todos/src/domain/models/task_model.dart';
import 'package:uuid/v7.dart';

import 'tasks_repository.dart';

class TasksRepositoryImp implements TasksRepository {
  final LocalStorageService storage;

  const TasksRepositoryImp(this.storage);

  @override
  AsyncResult<TaskModel> insertOne(String title) async {
    try {
      final current = storage.get<List<TaskModel>>('tasks') ?? [];
      final todo = TaskModel.create(id: UuidV7().generate(), title: title);
      await storage.set<List<TaskModel>>('tasks', [...current, todo]);
      return Result.success(todo);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  AsyncResult<List<TaskModel>> findMany([bool? done]) async {
    try {
      final todos = storage.get<List<TaskModel>>('tasks') ?? [];
      if (done != null) {
        todos.removeWhere((element) => element.done != done);
      }
      return Result.success(todos..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  AsyncResult<TaskModel> updateOne(String id, {String? title, bool? done}) async {
    try {
      if (title == null && done == null) {
        throw Exception('Title or done must be provided');
      }
      final todos = storage.get<List<TaskModel>>('tasks') ?? [];
      final index = todos.indexWhere((element) => element.id == id);
      if (index == -1) {
        throw Exception('Task not found');
      }
      final todo = todos[index];
      todos[index] = todo.copyWith(
        title: title ?? todo.title,
        done: done ?? todo.done,
        updatedAt: DateTime.now(),
      );
      await storage.set<List<TaskModel>>('tasks', todos);
      return Result.success(todo);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  AsyncResult<TaskModel> deleteOne(String id) async {
    try {
      final todos = storage.get<List<TaskModel>>('tasks') ?? [];
      final index = todos.indexWhere((element) => element.id == id);
      if (index == -1) {
        throw Exception('Task not found');
      }
      final todo = todos[index];
      todos.removeAt(index);
      await storage.set<List<TaskModel>>('tasks', todos);
      return Result.success(todo);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
