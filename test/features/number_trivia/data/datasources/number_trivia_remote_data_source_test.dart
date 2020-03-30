import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:matcher/matcher.dart';
import 'package:tdnumbers/core/error/exceptions.dart';
import 'package:tdnumbers/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:tdnumbers/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:tdnumbers/features/number_trivia/data/models/number_trivia_model.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  MockHttpClient mockHttpClient;
  NumberTriviaRemoteDataSourceImpl dataSource;

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = NumberTriviaRemoteDataSourceImpl(client: mockHttpClient);
  });

  group('Retrieve Concrete Number Trivia', () {
    final tNumber = 1;
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));
    test(
      'should call the api endpoint with a specific number',
      () async {
        //arrange
        when(mockHttpClient.get(any, headers: anyNamed('headers'))).thenAnswer(
            (_) async => http.Response(fixture('trivia.json'), 200));
        //act
        dataSource.getConcreteNumberTrivia(tNumber);
        //assert
        verify(mockHttpClient.get("http://numberapi.com/$tNumber", headers: {
          'Content-Type': 'application/json',
        }));
      },
    );

    test(
      'should return NumberTrivia when the response code is 200 (success)',
      () async {
        //arrange
        when(mockHttpClient.get(any, headers: anyNamed('headers'))).thenAnswer(
            (_) async => http.Response(fixture('trivia.json'), 200));
        //act
        final result = await dataSource.getConcreteNumberTrivia(tNumber);
        //assert
        expect(result, equals(tNumberTriviaModel));
      },
    );

    test(
      'should return a serverException when the response code is not 200 (failure)',
      () async {
        //arrange
          when(mockHttpClient.get(any, headers: anyNamed('headers'))).thenAnswer(
            (_) async => http.Response("Server error", 500)
          );
        //act
        final call  =  dataSource.getConcreteNumberTrivia;
        //assert
        expect(() => call(tNumber), throwsA(TypeMatcher<ServerException>()));
      },
    );
  });

  group('Retrieve Random Number Trivia', (){
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test( 
        'should call api for random number trivia ', 
        () async { 
          //arrange
        when(mockHttpClient.get(any, headers: anyNamed('headers'))).thenAnswer(
            (_) async => http.Response(fixture('trivia.json'), 200));
        //act
        dataSource.getRandomNumberTrivia();
        //assert
        verify(mockHttpClient.get("http://numberapi.com/random", headers: {
          'Content-Type': 'application/json',
        }));
        }, 
     );
  
    test(
      'should return NumberTrivia when the response code is 200 (success)',
      () async {
        //arrange
        when(mockHttpClient.get(any, headers: anyNamed('headers'))).thenAnswer(
            (_) async => http.Response(fixture('trivia.json'), 200));
        //act
        final result = await dataSource.getRandomNumberTrivia();
        //assert
        expect(result, equals(tNumberTriviaModel));
      },
    );

    test(
      'should return a serverException when the response code is not 200 (failure)',
      () async {
        //arrange
          when(mockHttpClient.get(any, headers: anyNamed('headers'))).thenAnswer(
            (_) async => http.Response("Server error", 500)
          );
        //act
        final call  =  dataSource.getRandomNumberTrivia;
        //assert
        expect(() => call(), throwsA(TypeMatcher<ServerException>()));
      },
    );
});
}
