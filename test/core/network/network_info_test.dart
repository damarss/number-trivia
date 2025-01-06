import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/core/network/network_info.dart';

// Annotation which generates the cat.mocks.dart library and the MockCat class.
@GenerateNiceMocks([MockSpec<NetworkInfo>()])
@GenerateNiceMocks([MockSpec<InternetConnection>()])
import 'network_info_test.mocks.dart';

void main() {
  late NetworkInfoImpl networkInfo;
  late MockInternetConnection mockInternetConnection;

  setUp(() {
    mockInternetConnection = MockInternetConnection();
    networkInfo = NetworkInfoImpl(mockInternetConnection);
  });

  group(
    'is connected',
    () {
      test(
        'should forward the call to DataConnectionChecker.hasConnection',
        () async {
          // arrange
          var tHasConnection = Future.value(true);

          when(mockInternetConnection.hasInternetAccess)
              .thenAnswer((_) => tHasConnection);
          // act
          var result = networkInfo.isConnected;
          //assert
          verify(mockInternetConnection.hasInternetAccess);
          expect(result, tHasConnection);
        },
      );
    },
  );
}
