import 'package:data_connection_checker/data_connection_checker.dart';

import '../service/interfaces/i_networkInfo.dart';

class NetworkInfoImpl implements INetworkInfo {
  final DataConnectionChecker connectionChecker;

  NetworkInfoImpl(this.connectionChecker);

  @override
  Future<bool> get isConnected => connectionChecker.hasConnection;
}
