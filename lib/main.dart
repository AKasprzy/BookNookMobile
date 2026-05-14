import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/user_profile_screen.dart';
import 'screens/shelves_screen.dart';
import 'screens/search_screen.dart';
import 'screens/create_book_screen.dart';
import 'screens/book_screen.dart';
import 'screens/editions_screen.dart';
import 'screens/create_review_screen.dart';

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),

        '/login': (context) => const LoginScreen(),

        '/register': (context) => const RegisterScreen(),

        '/shelves': (context) => const ShelvesScreen(),

        '/books/create': (context) => const CreateBookScreen(),

        '/stats': (context) => const StatsScreen(),

        '/search': (context) => const SearchScreen(),

        '/book': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments;

          if (args is Map &&
              args['editionId'] != null) {
            return BookScreen(
              editionId: args['editionId'],
            );
          }

          return const Scaffold(
            body: Center(
              child: Text("Invalid book data"),
            ),
          );
        },

        '/editions': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments;

          if (args is int) {
            return EditionsScreen(
              bookId: args,
            );
          }

          return const Scaffold(
            body: Center(
              child: Text("Invalid book ID"),
            ),
          );
        },

        '/user': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments;

          if (args is int) {
            return UserProfileScreen(
              userId: args,
            );
          }

          return const Scaffold(
            body: Center(
              child: Text("Invalid user ID"),
            ),
          );
        },

        '/reviews/create': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments;

          if (args is int) {
            return CreateReviewScreen(
              editionId: args,
            );
          }

          return const Scaffold(
            body: Center(
              child: Text("Invalid edition ID"),
            ),
          );
        },
      },
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text(
          args != null
              ? "$title\n$args"
              : title,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}