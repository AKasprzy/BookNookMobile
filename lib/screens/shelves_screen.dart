import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ShelvesScreen extends StatefulWidget {
  const ShelvesScreen({super.key});

  @override
  State<ShelvesScreen> createState() => _ShelvesScreenState();
}

class _ShelvesScreenState extends State<ShelvesScreen> {
  final api = ApiService();

  List books = [];
  bool loading = false;
  int page = 1;
  int lastPage = 1;

  String sortBy = "recent";
  bool favouritesOnly = false;

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    if (loading || page > lastPage) return;

    setState(() => loading = true);

    try {
      final res = await api.get("my-shelves?page=$page");

      lastPage = res['meta']['last_page'];
      final data = res['data'];

      books.addAll(data);
      page++;
    } catch (_) {}

    setState(() => loading = false);
  }

  List get filtered {
    List result = [...books];

    if (favouritesOnly) {
      result = result.where((b) => b['favourite'] == true).toList();
    }

    if (sortBy == "title") {
      result.sort((a, b) => a['edition']['book']['title']
          .compareTo(b['edition']['book']['title']));
    } else if (sortBy == "author") {
      result.sort((a, b) => a['edition']['book']['author']
          .compareTo(b['edition']['book']['author']));
    } else {
      result.sort((a, b) => DateTime.parse(b['updated_at'])
          .compareTo(DateTime.parse(a['updated_at'])));
    }

    return result;
  }

  Map counts() {
    return {
      "all": books.length,
      "read": books.where((b) => b['status'] == 'read').length,
      "reading": books.where((b) => b['status'] == 'reading').length,
      "tbr": books.where((b) => b['status'] == 'tbr').length,
      "dnf": books.where((b) => b['status'] == 'dnf').length,
    };
  }

  void openBook(int bookId, int editionId) {
    Navigator.pushNamed(
      context,
      '/book',
      arguments: {'bookId': bookId, 'editionId': editionId},
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = counts();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: NotificationListener<ScrollNotification>(
        onNotification: (scroll) {
          if (scroll.metrics.pixels >
              scroll.metrics.maxScrollExtent - 200) {
            fetchBooks();
          }
          return false;
        },
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 60, 16, 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0F172A),
                    Color(0xFF1E293B),
                    Color(0xFF0F172A),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "My Library",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      stat(c["all"], "All", const Color(0xFFE2E8F0)),
                      stat(c["read"], "Read", Colors.green),
                      stat(c["reading"], "Reading", Colors.blue),
                      stat(c["tbr"], "TBR", Colors.amber),
                      stat(c["dnf"], "DNF", Colors.grey),
                    ],
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () =>
                        setState(() => favouritesOnly = !favouritesOnly),
                    icon: const Icon(Icons.favorite),
                    label: const Text("Favourites"),
                  ),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: sortBy,
                    items: const [
                      DropdownMenuItem(value: "recent", child: Text("Recent")),
                      DropdownMenuItem(value: "title", child: Text("Title")),
                      DropdownMenuItem(value: "author", child: Text("Author")),
                    ],
                    onChanged: (v) => setState(() => sortBy = v!),
                  )
                ],
              ),
            ),
            ...filtered.map((b) {
              final book = b['edition']['book'];

              return GestureDetector(
                onTap: () => openBook(book['id'], b['edition']['id']),
                child: Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 6)
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(book['title'],
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(book['author'],
                          style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 6),
                      Text(b['edition']['format'],
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              );
            }),
            if (loading)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              )
          ],
        ),
      ),
    );
  }

  Widget stat(int value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text(
            value.toString(),
            style: TextStyle(
                color: color, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(label, style: TextStyle(color: color.withValues(alpha: 0.8))),
        ],
      ),
    );
  }
}