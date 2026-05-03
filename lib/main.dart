import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart' hide LoginScreen;
import 'screens/shelves_screen.dart';

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
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/shelves': (context) => const ShelvesScreen(),
        '/search': (context) => const PlaceholderScreen(title: 'Search'),
        '/books/create': (context) => const PlaceholderScreen(title: 'Add Book'),
        '/book': (context) => const PlaceholderScreen(title: 'Book Details'),

        '/user': (context) {
          final args = ModalRoute.of(context)!.settings.arguments;

          if (args is int) {
            return Scaffold(
              appBar: AppBar(title: const Text("User Profile")),
              body: Center(child: Text("User ID: $args")),
            );
          }

          return const Scaffold(
            body: Center(child: Text("Invalid user ID")),
          );
        },
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