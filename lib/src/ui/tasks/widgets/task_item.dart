import 'package:flutter/material.dart';
import 'package:idez_todos/src/domain/models/task_model.dart';

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
    return CheckboxListTile(
      value: todo.done,
      controlAffinity: ListTileControlAffinity.leading,
      checkboxShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      secondary: IconButton(
        color: theme.colorScheme.primary,
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
    );
  }
}
