import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Book Nook',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/login': (context) => const PlaceholderScreen(title: 'Login'),
        '/search': (context) => const PlaceholderScreen(title: 'Search'),
        '/books/create': (context) => const PlaceholderScreen(title: 'Add Book'),
        '/book': (context) => const PlaceholderScreen(title: 'Book Details'),
        '/user': (context) => const PlaceholderScreen(title: 'User Profile'),
      },
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          args != null ? "$title\n$args" : title,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}