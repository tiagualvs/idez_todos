import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:idez_todos/src/domain/models/task_model.dart';
import 'package:idez_todos/src/ui/view_models/todos_view_model.dart';
import 'package:intl/intl.dart';

class TasksView extends StatefulWidget {
  const TasksView({super.key, required this.viewModel});

  final TodosViewModel viewModel;

  @override
  State<TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView> {
  TodosViewModel get viewModel => widget.viewModel;
  ThemeData get theme => Theme.of(context);
  TextTheme get textTheme => theme.textTheme;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => viewModel.findMany(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text('To do list'),
          ),
          body: ListTileTheme(
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
                  selected: viewModel.filters,
                  showSelectedIcon: false,
                  onSelectionChanged: viewModel.setFilters,
                ),
                if (viewModel.tasks.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text('No tasks found!'),
                    ),
                  ),
                if (viewModel.tasks.isNotEmpty)
                  Expanded(
                    child: ListView.separated(
                      separatorBuilder: (_, _) => const Divider(
                        indent: 24.0,
                        endIndent: 24.0,
                      ),
                      itemCount: viewModel.tasks.length,
                      itemBuilder: (context, index) {
                        final task = viewModel.tasks[index];

                        return TaskItem(
                          todo: task,
                          onChanged: (value) => viewModel.updateOne(
                            task.id,
                            done: value,
                            onError: (error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(error),
                                ),
                              );
                            },
                          ),
                          onRemove: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Delete task'),
                                content: Text('Are you sure you want to delete this task?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: Text('Delete'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm ?? false) {
                              return await widget.viewModel.deleteOne(
                                task.id,
                                onSuccess: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Todo deleted successfully!'),
                                    ),
                                  );
                                },
                                onError: (error) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(error),
                                    ),
                                  );
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
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final title = await context.pushNamed<String>('new-task');

              if (title == null) return;

              await widget.viewModel.insertOne(
                title,
                onSuccess: (length) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Todo added successfully!'),
                    ),
                  );
                },
                onError: (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(error),
                    ),
                  );
                },
              );
            },
            child: Icon(Icons.add_rounded),
          ),
        );
      },
    );
  }
}

class TaskItem extends StatelessWidget {
  const TaskItem({
    super.key,
    required this.todo,
    this.onChanged,
    this.onRemove,
  });

  final TaskModel todo;
  final void Function(bool? value)? onChanged;
  final void Function()? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      waitDuration: Duration(milliseconds: 500),
      message: 'Updated at ${DateFormat('dd/MM/yyyy HH:mm:ss').format(todo.updatedAt)}',
      child: CheckboxListTile(
        value: todo.done,
        controlAffinity: ListTileControlAffinity.leading,
        checkboxShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
        secondary: IconButton(
          icon: Icon(Icons.delete_rounded),
          onPressed: onRemove,
        ),
        title: Text(
          todo.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: switch (todo.done) {
              true => theme.colorScheme.primary.withAlpha(128),
              false => theme.colorScheme.primary,
            },
            decoration: switch (todo.done) {
              true => TextDecoration.lineThrough,
              false => TextDecoration.none,
            },
            decorationColor: theme.colorScheme.primary.withAlpha(128),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
