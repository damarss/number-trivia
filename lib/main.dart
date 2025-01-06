import 'package:flutter/material.dart';
import 'package:myapp/features/number_trivia/presentation/pages/number_trivia_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Import dependency injector
import 'injection_container.dart' as di;

void main() async {
  await di.init();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Number Trivia',
      theme: ThemeData(fontFamily: 'Muli'),
      home: const NumberTriviaPage(),
      debugShowCheckedModeBanner: true,
    );
  }
}
