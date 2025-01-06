import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/core/network/network_info.dart';
import 'package:myapp/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:myapp/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mockito/annotations.dart';
import 'package:myapp/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:myapp/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:myapp/features/number_trivia/domain/entities/number_trivia.dart';

// Annotation which generates the cat.mocks.dart library and the MockCat class.
@GenerateNiceMocks([MockSpec<NumberTriviaRemoteDataSource>()])
@GenerateNiceMocks([MockSpec<NumberTriviaLocalDataSource>()])
@GenerateNiceMocks([MockSpec<NetworkInfo>()])
import 'number_trivia_repository_impl_test.mocks.dart';

void main() {
  late MockNumberTriviaRemoteDataSource mockNumberTriviaRemoteDataSource;
  late MockNumberTriviaLocalDataSource mockNumberTriviaLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;
  late NumberTriviaRepositoryImpl repository;

  setUp(() {
    mockNumberTriviaRemoteDataSource = MockNumberTriviaRemoteDataSource();
    mockNumberTriviaLocalDataSource = MockNumberTriviaLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = NumberTriviaRepositoryImpl(
      remoteDataSource: mockNumberTriviaRemoteDataSource,
      localDataSource: mockNumberTriviaLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  void runTestsOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      body();
    });
  }

  void runTestsOffline(Function body) {
    group('device is offline', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      body();
    });
  }

  group('getConcreteNumberTrivia', () {
    final tNumber = 1;
    final tNumberTriviaModel =
        NumberTriviaModel(text: "test trivia", number: tNumber);
    final NumberTrivia tNumberTrivia = tNumberTriviaModel;

    test(
      'should test if the device is online',
      () async {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);

        repository.getConcreteNumberTrivia(tNumber);

        verify(mockNetworkInfo.isConnected);
      },
    );

    runTestsOnline(() {
      test(
        'should return remote data when the call to remote data is successful',
        () async {
          when(mockNumberTriviaRemoteDataSource.getConcreteNumberTrivia(any))
              .thenAnswer((_) async => tNumberTriviaModel);

          var result = await repository.getConcreteNumberTrivia(tNumber);

          verify(mockNumberTriviaRemoteDataSource
              .getConcreteNumberTrivia(tNumber));
          expect(result, equals(Right(tNumberTrivia)));
        },
      );

      test(
        'should cache the data locally when the call to remote data is successful',
        () async {
          when(mockNumberTriviaRemoteDataSource.getConcreteNumberTrivia(any))
              .thenAnswer((_) async => tNumberTriviaModel);

          await repository.getConcreteNumberTrivia(tNumber);

          verify(mockNumberTriviaRemoteDataSource
              .getConcreteNumberTrivia(tNumber));
          verify(mockNumberTriviaLocalDataSource
              .cacheNumberTrivia(tNumberTriviaModel));
        },
      );

      test(
        'should return server failure when the call to remote data is unsuccessful',
        () async {
          when(mockNumberTriviaRemoteDataSource.getConcreteNumberTrivia(any))
              .thenThrow(ServerException());

          var result = await repository.getConcreteNumberTrivia(tNumber);

          verify(mockNumberTriviaRemoteDataSource
              .getConcreteNumberTrivia(tNumber));
          verifyZeroInteractions(mockNumberTriviaLocalDataSource);
          expect(result, equals(Left(ServerFailure())));
        },
      );
    });

    runTestsOffline(() {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      test(
        'should return the last locally cached data when the cached data is present',
        () async {
          // arrange
          when(mockNumberTriviaLocalDataSource.getLastNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModel);
          // act
          var result = await repository.getConcreteNumberTrivia(tNumber);
          //assert
          verifyZeroInteractions(mockNumberTriviaRemoteDataSource);
          verify(mockNumberTriviaLocalDataSource.getLastNumberTrivia());
          expect(result, equals(Right(tNumberTrivia)));
        },
      );

      test(
        'should return CacheFailure when the cached data is not present',
        () async {
          // arrange
          when(mockNumberTriviaLocalDataSource.getLastNumberTrivia())
              .thenThrow(CacheException());
          // act
          var result = await repository.getConcreteNumberTrivia(tNumber);
          //assert
          verifyZeroInteractions(mockNumberTriviaRemoteDataSource);
          verify(mockNumberTriviaLocalDataSource.getLastNumberTrivia());
          expect(result, equals(Left(CacheFailure())));
        },
      );
    });
  });

  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel(text: "test trivia", number: 123);
    final NumberTrivia tNumberTrivia = tNumberTriviaModel;

    test(
      'should test if the device is online',
      () async {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);

        repository.getRandomNumberTrivia();

        verify(mockNetworkInfo.isConnected);
      },
    );

    runTestsOnline(() {
      test(
        'should return remote data when the call to remote data is successful',
        () async {
          when(mockNumberTriviaRemoteDataSource.getRandomNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModel);

          var result = await repository.getRandomNumberTrivia();

          verify(mockNumberTriviaRemoteDataSource
              .getRandomNumberTrivia());
          expect(result, equals(Right(tNumberTrivia)));
        },
      );

      test(
        'should cache the data locally when the call to remote data is successful',
        () async {
          when(mockNumberTriviaRemoteDataSource.getRandomNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModel);

          await repository.getRandomNumberTrivia();

          verify(mockNumberTriviaRemoteDataSource
              .getRandomNumberTrivia());
          verify(mockNumberTriviaLocalDataSource
              .cacheNumberTrivia(tNumberTriviaModel));
        },
      );

      test(
        'should return server failure when the call to remote data is unsuccessful',
        () async {
          when(mockNumberTriviaRemoteDataSource.getRandomNumberTrivia())
              .thenThrow(ServerException());

          var result = await repository.getRandomNumberTrivia();

          verify(mockNumberTriviaRemoteDataSource
              .getRandomNumberTrivia());
          verifyZeroInteractions(mockNumberTriviaLocalDataSource);
          expect(result, equals(Left(ServerFailure())));
        },
      );
    });

    runTestsOffline(() {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      test(
        'should return the last locally cached data when the cached data is present',
        () async {
          // arrange
          when(mockNumberTriviaLocalDataSource.getLastNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModel);
          // act
          var result = await repository.getRandomNumberTrivia();
          //assert
          verifyZeroInteractions(mockNumberTriviaRemoteDataSource);
          verify(mockNumberTriviaLocalDataSource.getLastNumberTrivia());
          expect(result, equals(Right(tNumberTrivia)));
        },
      );

      test(
        'should return CacheFailure when the cached data is not present',
        () async {
          // arrange
          when(mockNumberTriviaLocalDataSource.getLastNumberTrivia())
              .thenThrow(CacheException());
          // act
          var result = await repository.getRandomNumberTrivia();
          //assert
          verifyZeroInteractions(mockNumberTriviaRemoteDataSource);
          verify(mockNumberTriviaLocalDataSource.getLastNumberTrivia());
          expect(result, equals(Left(CacheFailure())));
        },
      );
    });
  });
}
