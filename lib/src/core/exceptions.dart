abstract class AppException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const AppException(this.message, [this.stackTrace]);
}

class LocalStorageException extends AppException {
  const LocalStorageException(super.message, [super.stackTrace]);
}

class RepositoryException extends AppException {
  const RepositoryException(super.message, [super.stackTrace]);
}

class ViewModelException extends AppException {
  const ViewModelException(super.message, [super.stackTrace]);
}

class UnknownException extends AppException {
  const UnknownException(super.message, [super.stackTrace]);
}
