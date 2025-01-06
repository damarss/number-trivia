import 'dart:convert';

import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/core/constant.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:myapp/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:http/http.dart' as http;

// Annotation which generates the cat.mocks.dart library and the MockCat class.
import '../../../../fixtures/fixture_reader.dart';
@GenerateNiceMocks([MockSpec<http.Client>()])
import 'number_trivia_remote_data_source_test.mocks.dart';

void main() {
  late NumberTriviaRemoteDataSourceImpl dataSource;
  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient();
    dataSource = NumberTriviaRemoteDataSourceImpl(client: mockClient);
  });

  void setUpMockClientSuccess200() {
    when(mockClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
  }

  void setUpMockClientFailure404() {
    when(mockClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response('Something went wrong', 404));
  }

  group(
    'getConcreteNumberTrivia',
    () {
      final tNumber = 1;
      final tNumberTriviaModel =
          NumberTriviaModel.fromJson(jsonDecode(fixture('trivia.json')));

      test(
        '''should perform a GET request from url with number being the
          endpoint and with application/json header''',
        () async {
          // arrange
          setUpMockClientSuccess200();
          // act
          dataSource.getConcreteNumberTrivia(tNumber);
          //assert
          var url = Uri.http(BASE_URL, '$tNumber');
          verify(mockClient.get(
            url,
            headers: {
              'Content-Type': 'application/json',
            },
          ));
        },
      );

      test(
        'should return NumberTriviaModel when the response code is 200',
        () async {
          // arrange
          setUpMockClientSuccess200();
          // act
          final result = await dataSource.getConcreteNumberTrivia(tNumber);
          //assert
          expect(result, equals(tNumberTriviaModel));
        },
      );

      test(
        'should return ServerException when the response code is 404',
        () async {
          // arrange
          setUpMockClientFailure404();
          // act
          final call = dataSource.getConcreteNumberTrivia;
          //assert
          expect(() => call(tNumber), throwsA(TypeMatcher<ServerException>()));
        },
      );
    },
  );

  group(
    'getRandomNumberTrivia',
    () {
      final tNumberTriviaModel =
          NumberTriviaModel.fromJson(jsonDecode(fixture('trivia.json')));

      test(
        '''should perform a GET request from url with number being the
          endpoint and with application/json header''',
        () async {
          // arrange
          setUpMockClientSuccess200();
          // act
          dataSource.getRandomNumberTrivia();
          //assert
          var url = Uri.http(BASE_URL, 'random');
          verify(mockClient.get(
            url,
            headers: {
              'Content-Type': 'application/json',
            },
          ));
        },
      );

      test(
        'should return NumberTriviaModel when the response code is 200',
        () async {
          // arrange
          setUpMockClientSuccess200();
          // act
          final result = await dataSource.getRandomNumberTrivia();
          //assert
          expect(result, equals(tNumberTriviaModel));
        },
      );

      test(
        'should return ServerException when the response code is 404',
        () async {
          // arrange
          setUpMockClientFailure404();
          // act
          final call = dataSource.getRandomNumberTrivia;
          //assert
          expect(() => call(), throwsA(TypeMatcher<ServerException>()));
        },
      );
    },
  );
}
