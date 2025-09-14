import 'package:idez_todos/src/core/exceptions.dart';

extension ExceptionExtension on Exception {
  String message() {
    if (this is AppException) {
      return (this as AppException).message;
    }
    return toString().replaceAll('Exception: ', '');
  }
}
