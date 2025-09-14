import 'package:idez_todos/src/core/result.dart';
import 'package:idez_todos/src/domain/models/task_model.dart';

abstract interface class TasksRepository {
  AsyncResult<TaskModel> insertOne(String title);
  AsyncResult<List<TaskModel>> findMany([bool? done]);
  AsyncResult<TaskModel> updateOne(String id, {String? title, bool? done});
  AsyncResult<TaskModel> deleteOne(String id);
}
