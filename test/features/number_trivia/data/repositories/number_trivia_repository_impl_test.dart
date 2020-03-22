import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tdnumbers/core/error/exceptions.dart';
import 'package:tdnumbers/core/error/failures.dart';
import 'package:tdnumbers/core/platform/network_info.dart';
import 'package:tdnumbers/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:tdnumbers/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:tdnumbers/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:tdnumbers/features/number_trivia/data/repositories/number_trivia_reporitory_impl.dart';
import 'package:tdnumbers/features/number_trivia/domain/entities/number_trivia.dart';

class MockRemoteDataSource extends Mock
    implements NumberTriviaRemoteDataSource {}

class MockLocalDataSource extends Mock implements NumberTriviaLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  NumberTriviaRepositoryImpl repository;
  MockRemoteDataSource mockRemoteDataSource;
  MockLocalDataSource mockLocalDataSource;
  MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockNetworkInfo = MockNetworkInfo();
    mockLocalDataSource = MockLocalDataSource();
    mockRemoteDataSource = MockRemoteDataSource();
    repository = NumberTriviaRepositoryImpl(
        remoteDataSource: mockRemoteDataSource,
        localDataSource: mockLocalDataSource,
        networkInfo: mockNetworkInfo);
  });

  group("getConcreteNumberTrivia", () {
    final tNumber = 1;
    final tNumberTriviaModel =
        NumberTriviaModel(number: tNumber, text: "Test Trivia");
    final NumberTrivia tNumberTrivia = tNumberTriviaModel;
    test(
      'should check if the device is online',
      () async {
        //arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        //act
        repository.getConcreteNumberTrivia(tNumber);
        //assert
        verify(mockNetworkInfo.isConnected);
      },
    );

    group('Device is Online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test(
        'should return remote data when the call to remote data is successfull',
        () async {
          //arrange
          when(mockRemoteDataSource.getConcreteNumberTrivia(any))
              .thenAnswer((_) async => tNumberTriviaModel);
          //act
          final result = await repository.getConcreteNumberTrivia(tNumber);
          //assert
          verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
          expect(result, equals(Right(tNumberTrivia)));
        },
      );

      test(
        'should cache data locally when the call to remote data is successfull',
        () async {
          //arrange
          when(mockRemoteDataSource.getConcreteNumberTrivia(any))
              .thenAnswer((_) async => tNumberTriviaModel);
          //act
          await repository.getConcreteNumberTrivia(tNumber);
          //assert
          verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
          verify(mockLocalDataSource.cacheNumberTrivia(tNumberTrivia));
        },
      );

      test(
        'should return ServerFailure when the call to remote data is unsuccessfull',
        () async {
          //arrange
          when(mockRemoteDataSource.getConcreteNumberTrivia(any))
              .thenThrow(ServerException());
          //act
          final result = await repository.getConcreteNumberTrivia(tNumber);
          //assert
          verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
          verifyZeroInteractions(mockLocalDataSource);
          expect(result, equals(Left(ServerFailure())));
        },
      );
    });

    group('Device is Offline', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      test( 
          'should return last locally cached data is present', 
          () async { 
           //arrange 
           when(mockLocalDataSource.getLastNumberTrivia())
           .thenAnswer((_) async => tNumberTriviaModel);
           //act
           final result = await repository.getConcreteNumberTrivia(tNumber);
           //assert 
           verifyZeroInteractions(mockRemoteDataSource);
           verify(mockLocalDataSource.getLastNumberTrivia());
           expect(result, equals(Right(tNumberTrivia)));
        
       
          }, 
       );

       test( 
          'should return CacheFailure when cached data is not present', 
          () async { 
           //arrange 
           when(mockLocalDataSource.getLastNumberTrivia())
           .thenThrow(CacheException());
           //act
           final result = await repository.getConcreteNumberTrivia(tNumber);
           //assert 
           verifyZeroInteractions(mockRemoteDataSource);
           verify(mockLocalDataSource.getLastNumberTrivia());
           expect(result, equals(Left(CacheFailure())));
          }, 
       );

    });
  });
}