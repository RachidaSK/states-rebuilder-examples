import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'infrastructure/network_info.dart';
import 'repository/number_trivia_local_data_source.dart';
import 'repository/number_trivia_remote_data_source.dart';
import 'repository/number_trivia_repository_impl.dart';
import 'service/input_converter.dart';
import 'service/interfaces/i_networkInfo.dart';
import 'service/interfaces/number_trivia_repository.dart';
import 'service/number_trivia_service.dart';
import 'ui/pages/number_trivia_page.dart';

SharedPreferences sharedPreferences;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sharedPreferences = await SharedPreferences.getInstance();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Number Trivia',
      theme: ThemeData(
        primaryColor: Colors.green.shade800,
        accentColor: Colors.green.shade600,
      ),
      home: Injector(
          inject: [
            //! services
            Inject(
              () => NumberTriviaService(
                numberTriviaRepository: Injector.get(),
                inputConverter: Injector.get(),
              ),
            ),

            Inject(() => InputConverter()),

            //! interfaces
            Inject<NumberTriviaRepository>(
              () => NumberTriviaRepositoryImpl(
                remoteDataSource: Injector.get(),
                localDataSource: Injector.get(),
                networkInfo: Injector.get(),
              ),
            ),

            Inject<NumberTriviaRemoteDataSource>(
              () => NumberTriviaRemoteDataSourceImpl(
                client: Injector.get(),
              ),
            ),

            Inject<NumberTriviaLocalDataSource>(
              () => NumberTriviaLocalDataSourceImpl(
                sharedPreferences: Injector.get(),
              ),
            ),
            Inject<INetworkInfo>(() => NetworkInfoImpl(Injector.get())),

            //! External
            Inject(() => http.Client()),
            Inject(() => sharedPreferences),
            Inject(() => DataConnectionChecker())
          ],
          builder: (context) {
            return NumberTriviaPage();
          }),
    );
  }
}
