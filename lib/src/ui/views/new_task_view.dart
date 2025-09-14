import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NewTaskView extends StatefulWidget {
  const NewTaskView({super.key});

  @override
  State<NewTaskView> createState() => _NewTaskViewState();
}

class _NewTaskViewState extends State<NewTaskView> {
  late final GlobalKey<FormState> formKey;
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    formKey = GlobalKey<FormState>();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Task'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                autofocus: true,
                controller: controller,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Task name is required';
                  }

                  return null;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  hintText: 'Task Name',
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (formKey.currentState?.validate() ?? false) {
            return context.pop<String>(controller.text);
          }
        },
        child: Icon(Icons.save_rounded),
      ),
    );
  }
}
