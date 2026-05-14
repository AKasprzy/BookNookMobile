import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final api = ApiService();

  String query = "";
  List localResults = [];
  List externalResults = [];
  List latestBooks = [];

  bool loading = false;
  Timer? debounce;

  String? selectedFormat;

  @override
  void initState() {
    super.initState();
    fetchLatest();
  }

  Future<void> fetchLatest() async {
    try {
      final res = await api.get("books/latest");
      setState(() {
        latestBooks = res['data'] ?? [];
      });
    } catch (_) {}
  }

  Future<void> searchLocal() async {
    if (query.trim().length < 2) {
      setState(() => localResults = []);
      return;
    }

    try {
      final res = await api.get("books?q=$query");
      setState(() {
        localResults = res['data'] ?? [];
      });
    } catch (_) {
      setState(() => localResults = []);
    }
  }

  Future<void> searchExternal() async {
    if (query.trim().length < 2) {
      setState(() => externalResults = []);
      return;
    }

    setState(() => loading = true);

    try {
      final res = await api.get("search?q=$query");

      final List data = res;

      final Map<String, dynamic> localMap = {
        for (var b in localResults)
          "${b['title']}${b['author']}": b
      };

      List exact = [];
      List others = [];

      for (var book in data) {
        final key = "${book['title']}${book['author']}";
        if (localMap.containsKey(key)) {
          exact.add(localMap[key]);
        } else {
          others.add(book);
        }
      }

      setState(() {
        externalResults = [...exact, ...others];
      });
    } catch (_) {
      setState(() => externalResults = []);
    }

    setState(() => loading = false);
  }

  void onSearchChanged(String value) {
    query = value;

    if (debounce?.isActive ?? false) debounce!.cancel();

    debounce = Timer(const Duration(milliseconds: 300), () {
      searchLocal();
    });

    setState(() {});
  }

  List get displayBooks {
    if (externalResults.isNotEmpty) return externalResults;
    if (query.trim().length >= 2) return localResults;
    return latestBooks;
  }

  List<String> get formats {
    final set = <String>{};

    for (var b in displayBooks) {
      final editions = b['editions'] ?? [];
      for (var e in editions) {
        if (e['format'] != null) {
          set.add(e['format']);
        }
      }
    }

    return set.toList();
  }

  List get filteredBooks {
    return displayBooks.where((b) {
      if (selectedFormat == null) return true;

      final editions = b['editions'] ?? [];
      return editions.any((e) => e['format'] == selectedFormat);
    }).toList();
  }

  void toggleFormat(String format) {
    setState(() {
      selectedFormat = selectedFormat == format ? null : format;
    });
  }

  void openBook(int bookId, int editionId) {
    Navigator.pushNamed(
      context,
      '/book',
      arguments: {
        'bookId': bookId,
        'editionId': editionId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: ListView(
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
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Back",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  "Search Books",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: onSearchChanged,
                        onSubmitted: (_) => searchExternal(),
                        decoration: InputDecoration(
                          hintText: "Search books or authors...",
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: searchExternal,
                      child: const Text("Search"),
                    )
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 10,
              children: formats
                  .map((f) => FilterChip(
                label: Text(f),
                selected: selectedFormat == f,
                onSelected: (_) => toggleFormat(f),
              ))
                  .toList(),
            ),
          ),
          if (!loading)
            ...filteredBooks.map((b) {
              final editions = b['editions'] ?? [];
              final first = editions.isNotEmpty ? editions[0] : null;

              return GestureDetector(
                onTap: first != null
                    ? () => openBook(b['id'], first['id'])
                    : null,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6)
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 70,
                        height: 100,
                        color: Colors.grey[300],
                        child: first?['cover_url'] != null
                            ? Image.network(
                          first['cover_url'],
                          fit: BoxFit.cover,
                        )
                            : const Icon(Icons.book),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              b['title'],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              b['author'],
                              style: const TextStyle(
                                  color: Colors.grey),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              children: editions
                                  .map<Widget>((e) => Text(
                                e['format'],
                                style: const TextStyle(
                                    fontSize: 12),
                              ))
                                  .toList(),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              first?['description'] ??
                                  "No description available",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            }),
          if (loading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (!loading &&
              filteredBooks.isEmpty &&
              query.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: const [
                  Text("No books found"),
                ],
              ),
            )
        ],
      ),
    );
  }
}