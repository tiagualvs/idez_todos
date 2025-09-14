typedef AsyncResult<T> = Future<Result<T>>;

sealed class Result<T> {
  const Result();
  const factory Result.success(T success) = _Success<T>;
  const factory Result.error(Exception error) = _Error<T>;
  bool get isSuccess => this is _Success<T>;
  T get success => switch (this) {
    _Success<T>(:final _success) => _success,
    _Error<T>() => throw Exception('No success found in this result!'),
  };
  bool get isError => this is _Error<T>;
  Exception get error => switch (this) {
    _Success<T>() => throw Exception('No error found in this result!'),
    _Error<T>(:final _error) => _error,
  };
  S fold<S>(S Function(T success) onSuccess, S Function(Exception error) onError) {
    return switch (this) {
      _Success<T>(:final _success) => onSuccess(_success),
      _Error<T>(:final _error) => onError(_error),
    };
  }
}

class _Success<T> extends Result<T> {
  final T _success;
  const _Success(this._success);
}

final class _Error<T> extends Result<T> {
  final Exception _error;
  const _Error(this._error);
}
