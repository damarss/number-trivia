import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/loading_widget.dart';
import '../widgets/message_display.dart';
import '../widgets/trivia_control.dart';
import '../widgets/trivia_display.dart';
import '../../../../theme.dart';
import '../bloc/number_trivia_bloc.dart';
import '../../../../injection_container.dart';

class NumberTriviaPage extends StatelessWidget {
  const NumberTriviaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor3,
      appBar: AppBar(
        title: Text('Number Trivia'),
        centerTitle: true,
        toolbarHeight: 90,
        backgroundColor: backgroundColor1,
        titleTextStyle: primaryTextStyle.copyWith(
          fontSize: 21,
          fontWeight: medium,
        ),
      ),
      body: buildBody(context),
    );
  }

  BlocProvider<NumberTriviaBloc> buildBody(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NumberTriviaBloc>(),
      child: ListView(
        scrollDirection: Axis.vertical,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  BlocBuilder<NumberTriviaBloc, NumberTriviaState>(
                    builder: (context, state) {
                      print('Current state: $state');
                      if (state is TriviaStateEmpty) {
                        return MessageDisplay(message: 'Start Searching');
                      } else if (state is TriviaStateLoading) {
                        return LoadingWidget();
                      } else if (state is TriviaStateSuccess) {
                        return TriviaDisplay(numberTrivia: state.numberTrivia);
                      } else if (state is TriviaStateError) {
                        return MessageDisplay(message: state.message);
                      }

                      return MessageDisplay(message: 'Start Searching');
                    },
                  ),
                  SizedBox(height: 20),
                  TriviaControl(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
