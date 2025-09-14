import 'package:flutter/material.dart';
import 'package:idez_todos/src/data/repositories/tasks/tasks_repository.dart';
import 'package:idez_todos/src/data/repositories/tasks/tasks_repository_imp.dart';
import 'package:idez_todos/src/data/services/local_storage_service.dart';
import 'package:idez_todos/src/main_view.dart';
import 'package:idez_todos/src/ui/view_models/todos_view_model.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = await LocalStorageService.create();

  runApp(
    MultiProvider(
      providers: [
        Provider<LocalStorageService>.value(value: storage),
        Provider<TasksRepository>(create: (ctx) => TasksRepositoryImp(ctx.read())),
        ChangeNotifierProvider(create: (ctx) => TodosViewModel(ctx.read())),
      ],
      child: MainView(),
    ),
  );
}
