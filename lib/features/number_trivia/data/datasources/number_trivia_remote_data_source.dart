import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:myapp/core/constant.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/number_trivia_model.dart';

abstract class NumberTriviaRemoteDataSource {
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number);
  Future<NumberTriviaModel> getRandomNumberTrivia();
}


class NumberTriviaRemoteDataSourceImpl implements NumberTriviaRemoteDataSource {
  final http.Client client;

  NumberTriviaRemoteDataSourceImpl({required this.client});

  @override
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number) =>
      _getTriviaFromUrl('$number');

  @override
  Future<NumberTriviaModel> getRandomNumberTrivia() =>
      _getTriviaFromUrl('random');

  Future<NumberTriviaModel> _getTriviaFromUrl(String endpoint) async {
    var url = Uri.parse('$BASE_URL/$endpoint/trivia');
    print('requesting: $url');

    try {
      final res = await client.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'x-rapidapi-host': HOST,
          'x-rapidapi-key': dotenv.env['API_KEY']!,
        }
      );
      print(res.body);

      if (res.statusCode == 200) {
        return NumberTriviaModel.fromJson(jsonDecode(res.body));
      } else {
        throw ServerException();
      }
    } catch (e) {
      print(e);
      throw ServerException();
    }
  }
}
