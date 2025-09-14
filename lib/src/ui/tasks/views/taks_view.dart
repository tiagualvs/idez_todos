import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:idez_todos/src/core/exception_extension.dart';
import 'package:idez_todos/src/core/snack_bars.dart';
import 'package:idez_todos/src/data/repositories/tasks/tasks_repository.dart';
import 'package:idez_todos/src/domain/models/task_model.dart';
import 'package:idez_todos/src/ui/tasks/view_models/tasks_view_model.dart';
import 'package:idez_todos/src/ui/tasks/widgets/new_task_dialog.dart';
import 'package:idez_todos/src/ui/tasks/widgets/task_item.dart';

class TasksView extends StatefulWidget {
  const TasksView({super.key, required this.viewModel});

  final TasksViewModel viewModel;

  @override
  State<TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView> with SnackBars {
  TasksViewModel get viewModel => widget.viewModel;
  List<TaskModel> get tasks => viewModel.tasks;
  Set<bool?> get filters => viewModel.filters;
  bool get running => viewModel.findMany.running || viewModel.setFilters.running;

  ThemeData get theme => Theme.of(context);
  TextTheme get textTheme => theme.textTheme;

  void viewModelListener() {
    setState(() {});

    if (viewModel.findMany.error) {
      return showErrorSnackBar(
        viewModel.findMany.result?.exception.message() ?? 'Fail to find tasks!',
      );
    }

    if (viewModel.setFilters.error) {
      return showErrorSnackBar(
        viewModel.setFilters.result?.exception.message() ?? 'Fail to set filters!',
      );
    }
  }

  @override
  void initState() {
    super.initState();
    viewModel.listenable.addListener(viewModelListener);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => viewModel.findMany.execute(null),
    );
  }

  @override
  void dispose() {
    viewModel.listenable.removeListener(viewModelListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To do list'),
        centerTitle: true,
      ),
      body: switch (running) {
        true => Center(
          child: CircularProgressIndicator(),
        ),
        false => ListTileTheme(
          horizontalTitleGap: 0,
          child: Column(
            spacing: 16.0,
            children: [
              const SizedBox.shrink(),
              SegmentedButton<bool?>(
                segments: [
                  ButtonSegment<bool?>(
                    value: null,
                    label: Text('All'),
                  ),
                  ButtonSegment<bool?>(
                    value: false,
                    label: Text('Pending'),
                  ),
                  ButtonSegment<bool?>(
                    value: true,
                    label: Text('Done'),
                  ),
                ],
                selected: filters,
                showSelectedIcon: false,
                onSelectionChanged: viewModel.setFilters.execute,
              ),
              if (tasks.isEmpty)
                Expanded(
                  child: Center(
                    child: Text('No tasks found!'),
                  ),
                ),
              if (tasks.isNotEmpty)
                Expanded(
                  child: ListView.separated(
                    separatorBuilder: (_, _) => const Divider(
                      indent: 24.0,
                      endIndent: 24.0,
                    ),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];

                      return TaskItem(
                        todo: task,
                        onChanged: (value) async {
                          await viewModel.updateOne.execute(
                            task.id,
                            UpdateOneTaskParams(done: value),
                          );

                          return viewModel.updateOne.result?.fold(
                            (_) {
                              return showSuccessSnackBar('Task updated!');
                            },
                            (exception) {
                              return showErrorSnackBar(exception.message());
                            },
                          );
                        },
                        onRemove: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Delete task'),
                              content: Text('Are you sure you want to delete this task?'),
                              actions: [
                                TextButton(
                                  onPressed: () => context.pop(false),
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => context.pop(true),
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (confirm ?? false) {
                            await viewModel.deleteOne.execute(task.id);

                            return viewModel.deleteOne.result?.fold(
                              (value) {
                                return showSuccessSnackBar('Task deleted!');
                              },
                              (exception) {
                                return showErrorSnackBar(exception.message());
                              },
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      },
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final title = await showGeneralDialog<String>(
            context: context,
            transitionDuration: Duration(milliseconds: 350),
            transitionBuilder: (context, anim1, _, child) {
              return FadeTransition(
                opacity: CurvedAnimation(parent: anim1, curve: Curves.easeInOut),
                child: SlideTransition(
                  position: anim1.drive(Tween(begin: Offset(0.5, 0.5), end: Offset.zero)),
                  child: ScaleTransition(
                    scale: CurvedAnimation(parent: anim1, curve: Curves.easeInOut),
                    child: child,
                  ),
                ),
              );
            },
            fullscreenDialog: true,
            pageBuilder: (context, _, _) {
              return NewTaskDialog();
            },
          );

          if (title == null) return;

          await viewModel.insertOne.execute(title);

          return viewModel.insertOne.result?.fold(
            (_) {
              return showSuccessSnackBar('New task added!');
            },
            (exception) {
              return showErrorSnackBar(exception.message());
            },
          );
        },
        child: Icon(Icons.add_rounded),
      ),
    );
  }
}
