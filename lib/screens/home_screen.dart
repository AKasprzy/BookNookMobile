import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/stats_row.dart';
import '../widgets/book_list.dart';
import '../widgets/review_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final api = ApiService();

  bool loading = true;
  bool loggedIn = false;

  List latestBooks = [];
  List reviews = [];

  List stats = [
    {"label": "Total Books\n", "value": "...", "color": Colors.blue},
    {"label": "Users Registered", "value": "...", "color": Colors.green},
    {"label": "Reviews Published", "value": "...", "color": Colors.amber},
  ];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    final token = await api.getToken();
    setState(() {
      loggedIn = token != null;
    });
    await loadData();
  }

  Future<void> loadData() async {
    try {
      final booksRes = await api.get("books/latest");
      final countRes = await api.get("book-editions/count");
      final usersRes = await api.get("users/count");
      final reviewsRes = await api.get("reviews/count");
      final latestReviewsRes = await api.get("reviews/latest?limit=6");

      setState(() {
        latestBooks = booksRes['data'] ?? [];
        reviews = latestReviewsRes['data'] ?? [];

        stats[0]["value"] = countRes['total_editions'].toString();
        stats[1]["value"] = usersRes['total_users'].toString();
        stats[2]["value"] = reviewsRes['total_reviews'].toString();

        loading = false;
      });
    } catch (_) {
      setState(() => loading = false);
    }
  }

  void goTo(String route, {Object? args}) {
    Navigator.pushNamed(context, route, arguments: args);
  }

  Future<void> logout() async {
    await api.saveToken("");
    setState(() {
      loggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: loadData,
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 60, 16, 40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0F172A),
                    Color(0xFF1E293B),
                    Color(0xFF0F172A),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (loggedIn) ...[
                        TextButton(
                          onPressed: () => goTo('/shelves'),
                          child: const Text(
                            "My Library",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        TextButton(
                          onPressed: logout,
                          child: const Text(
                            "Logout",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ] else ...[
                        TextButton(
                          onPressed: () => goTo('/login'),
                          child: const Text(
                            "Login",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      ]
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Track Your Reading Journey",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Discover, review, and analyze your reading habits.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => goTo('/search'),
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: const Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Search books, authors...",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => goTo('/books/create'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        ),
                        child: const Text("Add Book"),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton(
                        onPressed: () => goTo('/search'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white30),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        ),
                        child: const Text("Browse Books"),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 12),
            StatsRow(stats: stats),
            const SizedBox(height: 20),
            BookList(
              books: latestBooks,
              onOpen: (b, e) => goTo('/book', args: {'bookId': b, 'editionId': e}),
            ),
            const SizedBox(height: 20),
            ReviewList(
              reviews: reviews,
              onUserTap: (id) => goTo('/user', args: id),
            )
          ],
        ),
      ),
    );
  }
}