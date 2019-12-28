import 'package:meta/meta.dart';

import '../domain/entities/number_trivia.dart';
import '../service/interfaces/i_networkInfo.dart';
import '../service/interfaces/number_trivia_repository.dart';
import 'number_trivia_local_data_source.dart';
import 'number_trivia_remote_data_source.dart';

typedef Future<NumberTrivia> _ConcreteOrRandomChooser();

class NumberTriviaRepositoryImpl implements NumberTriviaRepository {
  final NumberTriviaRemoteDataSource remoteDataSource;
  final NumberTriviaLocalDataSource localDataSource;
  final INetworkInfo networkInfo;

  NumberTriviaRepositoryImpl({
    @required this.remoteDataSource,
    @required this.localDataSource,
    @required this.networkInfo,
  });

  @override
  Future<NumberTrivia> getConcreteNumberTrivia(
    int number,
  ) async {
    return await _getTrivia(() {
      return remoteDataSource.getConcreteNumberTrivia(number);
    });
  }

  @override
  Future<NumberTrivia> getRandomNumberTrivia() async {
    return await _getTrivia(() {
      return remoteDataSource.getRandomNumberTrivia();
    });
  }

  Future<NumberTrivia> _getTrivia(
    _ConcreteOrRandomChooser getConcreteOrRandom,
  ) async {
    if (await networkInfo.isConnected) {
      final remoteTrivia = await getConcreteOrRandom();
      localDataSource.cacheNumberTrivia(remoteTrivia);
      return remoteTrivia;
    } else {
      final localTrivia = await localDataSource.getLastNumberTrivia();
      return localTrivia;
    }
  }
}
