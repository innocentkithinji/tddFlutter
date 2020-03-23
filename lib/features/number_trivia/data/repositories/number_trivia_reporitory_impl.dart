import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:tdnumbers/core/error/exceptions.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/number_trivia.dart';
import '../../domain/repositories/number_trivia_repository.dart';
import '../datasources/number_trivia_local_data_source.dart';
import '../datasources/number_trivia_remote_data_source.dart';

typedef Future<NumberTrivia>  _getConcreteOrRandomChooser();

class NumberTriviaRepositoryImpl implements NumberTriviaRepository {
  final NetworkInfo networkInfo;
  final NumberTriviaRemoteDataSource remoteDataSource;
  final NumberTriviaLocalDataSource localDataSource;

  NumberTriviaRepositoryImpl(
      {@required this.networkInfo,
      @required this.remoteDataSource,
      @required this.localDataSource});

  Future<Either<Failure, NumberTrivia>> _fetchTrivia(
      _getConcreteOrRandomChooser getConcreteorRandom) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteTrivia = await getConcreteorRandom();
        localDataSource.cacheNumberTrivia(remoteTrivia);
        return Right(remoteTrivia);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        final localTrivia = await localDataSource.getLastNumberTrivia();
        return Right(localTrivia);
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, NumberTrivia>> getConcreteNumberTrivia(
      int number) async {
    return _fetchTrivia(() => remoteDataSource.getConcreteNumberTrivia(number));
  }

  @override
  Future<Either<Failure, NumberTrivia>> getRandomNumberTrivia() async {
    return _fetchTrivia(() => remoteDataSource.getRandomNumberTrivia());  
  }
}
