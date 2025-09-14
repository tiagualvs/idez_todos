import 'package:flutter/material.dart';

import 'result.dart';

typedef Command0Action<T> = AsyncResult<T> Function();
typedef Command1Action<T, A> = AsyncResult<T> Function(A a);
typedef Command2Action<T, A, B> = AsyncResult<T> Function(A a, B b);

abstract class Command<T> extends ChangeNotifier {
  bool _running = false;
  bool get running => _running;
  Result<T>? _result;
  Result<T>? get result => _result;
  bool get error => _result?.hasException ?? false;
  bool get completed => _result?.hasValue ?? false;
  Future<void> _execute(Command0Action<T> action) async {
    if (_running) return;

    _running = true;
    _result = null;
    notifyListeners();

    try {
      _result = await action();
    } finally {
      _running = false;
      notifyListeners();
    }
  }
}

class Command0<T> extends Command<T> {
  final Command0Action<T> _action;
  Command0(this._action);
  Future<void> execute() async => await _execute(_action);
}

class Command1<T, A> extends Command<T> {
  final Command1Action<T, A> _action;
  Command1(this._action);
  Future<void> execute(A a) async => await _execute(() => _action(a));
}

class Command2<T, A, B> extends Command<T> {
  final Command2Action<T, A, B> _action;
  Command2(this._action);
  Future<void> execute(A a, B b) async => await _execute(() => _action(a, b));
}
