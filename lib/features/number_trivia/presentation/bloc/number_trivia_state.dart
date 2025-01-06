part of 'number_trivia_bloc.dart';

sealed class NumberTriviaState extends Equatable {
  const NumberTriviaState();
  
  @override
  List<Object> get props => [];
}

final class TriviaStateEmpty extends NumberTriviaState {}

final class TriviaStateLoading extends NumberTriviaState {}

final class TriviaStateSuccess extends NumberTriviaState {
  final NumberTrivia numberTrivia;

  TriviaStateSuccess({required this.numberTrivia});

  @override
  List<Object> get props => [numberTrivia];
}

final class TriviaStateError extends NumberTriviaState {
  final String message;

  TriviaStateError({required this.message});

  @override
  List<Object> get props => [message];
}
