import '../../service/exceptions/connection_exceptions.dart';
import '../../service/exceptions/input_exception.dart';

class ErrorHandler {
  static const String _SERVER_FAILURE_MESSAGE = 'Server Failure';
  static const String _CACHE_FAILURE_MESSAGE = 'Cache Failure';
  static const String _INVALID_INPUT_FAILURE_MESSAGE =
      'Invalid Input - The number must be a positive integer or zero.';

  static String errorMessage(dynamic error) {
    switch (error.runtimeType) {
      case ServerException:
        return _SERVER_FAILURE_MESSAGE;
      case CacheException:
        return _CACHE_FAILURE_MESSAGE;
      case InvalidInputException:
        return _INVALID_INPUT_FAILURE_MESSAGE;
      default:
        return 'Unexpected error';
    }
  }
}
