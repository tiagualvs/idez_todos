import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:idez_todos/src/core/exceptions.dart';
import 'package:idez_todos/src/data/repositories/tasks/tasks_repository.dart';
import 'package:idez_todos/src/data/repositories/tasks/tasks_repository_imp.dart';
import 'package:idez_todos/src/domain/models/task_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late TasksRepository repository;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    repository = TasksRepositoryImp(mockPrefs);
    registerFallbackValue(UpdateOneTaskParams());
  });

  final task1 = TaskModel.create(id: '1', title: 'Task 1');
  final task1Json = json.encode(task1.toJson());

  group('TasksRepository', () {
    group('insertOne', () {
      test('should insert a task and return it', () async {
        when(() => mockPrefs.getStringList('tasks')).thenReturn([]);
        when(() => mockPrefs.setStringList(any(), any())).thenAnswer((_) async => true);

        final result = await repository.insertOne('New Task');

        expect(result.hasValue, isTrue);
        expect(result.value, isA<TaskModel>());
        expect(result.value.title, 'New Task');
        verify(() => mockPrefs.setStringList('tasks', any())).called(1);
      });

      test('should return exception when prefs fails', () async {
        when(() => mockPrefs.getStringList('tasks')).thenThrow(Exception('Prefs error'));

        final result = await repository.insertOne('New Task');

        expect(result.hasException, isTrue);
        expect(result.exception, isA<UnknownException>());
      });
    });

    group('findMany', () {
      test('should return a list of tasks', () async {
        when(() => mockPrefs.getStringList('tasks')).thenReturn([task1Json]);

        final result = await repository.findMany();

        expect(result.hasValue, isTrue);
        expect(result.value, isA<List<TaskModel>>());
        expect(result.value.length, 1);
        expect(result.value.first.id, '1');
      });

      test('should return a filtered list of tasks when done is true', () async {
        final task2 = TaskModel.create(id: '2', title: 'Task 2').copyWith(done: true);
        final task2Json = json.encode(task2.toJson());
        when(() => mockPrefs.getStringList('tasks')).thenReturn([task1Json, task2Json]);

        final result = await repository.findMany(true);

        expect(result.hasValue, isTrue);
        expect(result.value.length, 1);
        expect(result.value.first.id, '2');
      });

      test('should return an empty list when no tasks are stored', () async {
        when(() => mockPrefs.getStringList('tasks')).thenReturn([]);

        final result = await repository.findMany();

        expect(result.hasValue, isTrue);
        expect(result.value, isEmpty);
      });
    });

    group('updateOne', () {
      test('should update a task and return it', () async {
        when(() => mockPrefs.getStringList('tasks')).thenReturn([task1Json]);
        when(() => mockPrefs.setStringList(any(), any())).thenAnswer((_) async => true);
        const params = UpdateOneTaskParams(title: 'Updated Title', done: true);

        final result = await repository.updateOne('1', params);

        expect(result.hasValue, isTrue);
        expect(result.value, isA<TaskModel>());
        expect(result.value.title, 'Updated Title');
        expect(result.value.done, isTrue);
        verify(() => mockPrefs.setStringList(any(), any())).called(1);
      });

      test('should return RepositoryException when task is not found', () async {
        when(() => mockPrefs.getStringList('tasks')).thenReturn([]);
        const params = UpdateOneTaskParams(title: 'Updated Title');

        final result = await repository.updateOne('1', params);

        expect(result.hasException, isTrue);
        expect(result.exception, isA<RepositoryException>());
        expect((result.exception as RepositoryException).message, 'Task not found');
      });

      test('should return RepositoryException when params are empty', () async {
        const params = UpdateOneTaskParams();

        final result = await repository.updateOne('1', params);

        expect(result.hasException, isTrue);
        expect(result.exception, isA<RepositoryException>());
        expect((result.exception as RepositoryException).message, 'Title or done must be provided');
      });
    });

    group('deleteOne', () {
      test('should delete a task and return it', () async {
        when(() => mockPrefs.getStringList('tasks')).thenReturn([task1Json]);
        when(() => mockPrefs.setStringList(any(), any())).thenAnswer((_) async => true);

        final result = await repository.deleteOne('1');

        expect(result.hasValue, isTrue);
        expect(result.value, isA<TaskModel>());
        expect(result.value.id, '1');
        verify(() => mockPrefs.setStringList('tasks', [])).called(1);
      });

      test('should return RepositoryException when task is not found', () async {
        when(() => mockPrefs.getStringList('tasks')).thenReturn([]);

        final result = await repository.deleteOne('1');

        expect(result.hasException, isTrue);
        expect(result.exception, isA<RepositoryException>());
        expect((result.exception as RepositoryException).message, 'Task not found');
      });
    });
  });
}
