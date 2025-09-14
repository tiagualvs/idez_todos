import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:idez_todos/src/ui/tasks/view_models/tasks_view_model.dart';
import 'package:idez_todos/src/ui/tasks/views/taks_view.dart';
import 'package:provider/provider.dart';

abstract class MainRouter {
  static final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    navigatorKey: navKey,
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => TasksView(
          viewModel: context.read<TasksViewModel>(),
        ),
      ),
    ],
  );
}
