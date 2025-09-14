import 'package:idez_todos/src/core/result.dart';
import 'package:idez_todos/src/domain/models/task_model.dart';

abstract interface class TasksRepository {
  AsyncResult<TaskModel> insertOne(String title);
  AsyncResult<List<TaskModel>> findMany([bool? done]);
  AsyncResult<TaskModel> updateOne(String id, UpdateOneTaskParams params);
  AsyncResult<TaskModel> deleteOne(String id);
}

class UpdateOneTaskParams {
  final String? title;
  final bool? done;

  const UpdateOneTaskParams({this.title, this.done});

  bool get isEmpty => title == null && done == null;

  bool get isNotEmpty => !isEmpty;
}
