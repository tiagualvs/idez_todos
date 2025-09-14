import 'package:flutter/material.dart';
import 'package:idez_todos/src/data/repositories/tasks/tasks_repository.dart';
import 'package:idez_todos/src/data/repositories/tasks/tasks_repository_imp.dart';
import 'package:idez_todos/src/main_view.dart';
import 'package:idez_todos/src/ui/tasks/view_models/tasks_view_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        Provider<SharedPreferences>.value(value: prefs),
        Provider<TasksRepository>(create: (ctx) => TasksRepositoryImp(ctx.read())),
        ChangeNotifierProvider(create: (ctx) => TasksViewModel(ctx.read())),
      ],
      child: MainView(),
    ),
  );
}
