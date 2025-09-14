typedef AsyncResult<T> = Future<Result<T>>;

sealed class Result<T> {
  const Result();
  const factory Result.value(T value) = _Value<T>;
  const factory Result.exception(Exception exception) = _Exception<T>;
  bool get hasValue => this is _Value<T>;
  T get value => switch (this) {
    _Value<T> v => v._value,
    _Exception<T> _ => throw Exception('No value found in this result!'),
  };
  bool get hasException => this is _Exception<T>;
  Exception get exception => switch (this) {
    _Value<T> _ => throw Exception('No exception found in this result!'),
    _Exception<T> e => e._exception,
  };
  S fold<S>(S Function(T value) onValue, S Function(Exception exception) onException) {
    return switch (this) {
      _Value<T> v => onValue(v._value),
      _Exception<T> e => onException(e._exception),
    };
  }
}

class _Value<T> extends Result<T> {
  final T _value;
  const _Value(this._value);
}

final class _Exception<T> extends Result<T> {
  final Exception _exception;
  const _Exception(this._exception);
}
