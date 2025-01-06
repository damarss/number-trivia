import 'dart:convert';

import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:myapp/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../fixtures/fixture_reader.dart';

// Annotation which generates the cat.mocks.dart library and the MockCat class.
@GenerateNiceMocks([MockSpec<SharedPreferences>()])
import 'number_trivia_local_data_source_test.mocks.dart';

void main() {
  late NumberTriviaLocalDataSourceImpl dataSource;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = NumberTriviaLocalDataSourceImpl(
      sharedPreferences: mockSharedPreferences,
    );
  });

  group(
    'getLastNumberTrivia',
    () {
      final tNumberTriviaModel =
          NumberTriviaModel.fromJson(jsonDecode(fixture('trivia_cached.json')));

      test(
        'should return NumberTriviaModel from shared preferences when there is one in the cache',
        () async {
          // arrange
          when(mockSharedPreferences.getString(any))
              .thenReturn(fixture('trivia_cached.json'));
          // act
          var result = await dataSource.getLastNumberTrivia();
          //assert
          verify(mockSharedPreferences.getString(CACHED_NUMBER_TRIVIA));
          expect(result, tNumberTriviaModel);
        },
      );

      test(
        'should throw CacheException when there is no cached NumberTriviaModel',
        () async {
          // arrange
          when(mockSharedPreferences.getString(CACHED_NUMBER_TRIVIA))
              .thenReturn(null);
          // act
          var call = dataSource.getLastNumberTrivia;
          //assert
          expect(() => call(), throwsA(TypeMatcher<CacheException>()));
        },
      );
    },
  );

  group(
    'cacheNumberTrivia',
    () {
      final tNumberTriviaModel =
          NumberTriviaModel(number: 1, text: "Test Text");

      test(
        'should call SharedPreferences to cache the data',
        () async {
          // act
          dataSource.cacheNumberTrivia(tNumberTriviaModel);
          //assert
          var expectedJsonString = jsonEncode(tNumberTriviaModel);
          verify(
            mockSharedPreferences.setString(
              CACHED_NUMBER_TRIVIA,
              expectedJsonString,
            ),
          );
        },
      );
    },
  );
}
