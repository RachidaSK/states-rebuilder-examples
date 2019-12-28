import 'dart:async';

import '../domain/entities/user.dart';
import 'exceptions/input_exception.dart';
import 'interfaces/i_api.dart';

class AuthenticationService {
  AuthenticationService({IApi api}) : _api = api;
  IApi _api;
  User _fetchedUser;
  User get user => _fetchedUser;

  Future<void> login(String userIdText) async {
    var userId = int.tryParse(userIdText);
    if (userId == null) {
      throw NotNumberException();
    }
    _fetchedUser = await _api.getUserProfile(userId);
  }
}
