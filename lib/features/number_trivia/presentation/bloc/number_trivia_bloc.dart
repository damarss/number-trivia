import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/core/usecases/usecase.dart';
import '../../../../core/util/input_converter.dart';
import '../../domain/usecase/get_concrete_number_trivia.dart';
import '../../domain/usecase/get_random_number_trivia.dart';
import '../../domain/entities/number_trivia.dart';

part 'number_trivia_event.dart';
part 'number_trivia_state.dart';

const String SERVER_FAILURE_MESSAGE = 'Server Failure';
const String CACHE_FAILURE_MESSAGE = 'Cache Failure';
const String INVALID_INPUT_FAILURE_MESSAGE =
    'Invalid Input - The number must be positive integer or zero';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;

  NumberTriviaBloc({
    required this.getConcreteNumberTrivia,
    required this.getRandomNumberTrivia,
    required this.inputConverter,
  }) : super(TriviaStateEmpty()) {
    on<GetTriviaForConcreteNumber>(_onConcreteTriviaFetched);

    on<GetTriviaForRandomNumber>(_onRandomTriviaFetched);
  }

  Future<void> _onConcreteTriviaFetched(
    GetTriviaForConcreteNumber event,
    Emitter<NumberTriviaState> emit,
  ) async {
    emit(TriviaStateLoading());

    final inputEither =
        inputConverter.stringToUnsignedInteger(event.numberString);

    await inputEither.fold(
      (failure) async {
        print('Emitting Error State: INVALID_INPUT_FAILURE_MESSAGE');
        emit(TriviaStateError(message: INVALID_INPUT_FAILURE_MESSAGE));
      },
      (integer) async {
        print('Getting concrete number');
          final resultEither =
              await getConcreteNumberTrivia(Params(number: integer));
          print('ResultEither: $resultEither');
          emit(_eitherLoadedOrErrorState(resultEither));
      },
    );
  }

  Future<void> _onRandomTriviaFetched(
    GetTriviaForRandomNumber event,
    Emitter<NumberTriviaState> emit,
  ) async {
    emit(TriviaStateLoading());
    final failureOrTrivia = await getRandomNumberTrivia(NoParams());
    emit(_eitherLoadedOrErrorState(failureOrTrivia));
  }

  NumberTriviaState _eitherLoadedOrErrorState(
      Either<Failure, NumberTrivia> resultEither) {
    print('data $resultEither');
    return resultEither.fold(
      (failure) => TriviaStateError(message: _mapFailureToMessage(failure)),
      (trivia) => TriviaStateSuccess(numberTrivia: trivia),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return SERVER_FAILURE_MESSAGE;
      case CacheFailure:
        return CACHE_FAILURE_MESSAGE;
      default:
        return 'Unexpected Error';
    }
  }
}
