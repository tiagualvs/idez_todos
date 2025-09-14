import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:idez_todos/src/ui/view_models/todos_view_model.dart';
import 'package:idez_todos/src/ui/views/new_task_view.dart';
import 'package:idez_todos/src/ui/views/taks_view.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  initialLocation: '/',
  navigatorKey: navKey,
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => TasksView(
        viewModel: context.read<TodosViewModel>(),
      ),
    ),
    GoRoute(
      path: '/new-task',
      name: 'new-task',
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          child: const NewTaskView(),
          transitionDuration: Duration(milliseconds: 300),
          reverseTransitionDuration: Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, _, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      },
    ),
  ],
);
