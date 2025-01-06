import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/core/util/input_converter.dart';

void main() {
  late InputConverter inputConverter;

  setUp(() {
    inputConverter = InputConverter();
  });

  group(
    'stringToUnsignedInt',
    () {
      test(
        'should return an integer when the string represents an unsigned integer',
        () async {
          // arrange
          var str = "123";
          // act
          var result = inputConverter.stringToUnsignedInteger(str);
          //assert
          expect(result, Right(123));
        },
      );

      test(
        'should return InvalidInputFailure when the string is a negative number',
        () async {
          // arrange
          var str = '-123';
          // act
          var result = inputConverter.stringToUnsignedInteger(str);
          //assert
          expect(result, Left(InvalidInputFailure()));
        },
      );
    },
  );
}
