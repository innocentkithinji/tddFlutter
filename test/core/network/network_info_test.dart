import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:tdnumbers/core/network/network_info.dart';

import '../../features/number_trivia/data/repositories/number_trivia_repository_impl_test.dart';

class MockDataconnectionChecker extends Mock implements DataConnectionChecker {}

void main() {
  NetworkInfoImpl networkInfoImpl;
  MockDataconnectionChecker mockDataconnectionChecker;

  setUp(() {
    mockDataconnectionChecker = MockDataconnectionChecker();
    networkInfoImpl = NetworkInfoImpl(mockDataconnectionChecker);
  });

  group("isConnected", () {
    test(
      'should forward the call to DataConnectionChecker.hasConnection',
      () async {
        //arrange
        final tHasConnectionFuture = Future.value(true);

        when(mockDataconnectionChecker.hasConnection)
        .thenAnswer((_) => tHasConnectionFuture);
        //act
        final result = networkInfoImpl.isConnected;
        //assert
        verify(mockDataconnectionChecker.hasConnection);
        expect(result, tHasConnectionFuture );
      },
    );
  });
}
