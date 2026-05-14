import 'package:flutter/material.dart';
import '../services/api_service.dart';

import '../widgets/book_hero.dart';
import '../widgets/book_stats.dart';
import '../widgets/genres_and_motifs.dart';
import '../widgets/edition_details.dart';
import '../widgets/reviews_section.dart';

class BookScreen extends StatefulWidget {
  final int editionId;

  const BookScreen({
    super.key,
    required this.editionId,
  });

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  final api = ApiService();

  bool loading = true;
  bool loggedIn = false;

  Map edition = {};
  List reviews = [];

  Map? shelf;

  final List statuses = [
    {
      "value": "read",
      "label": "Read",
      "icon": Icons.check_circle,
      "color": Colors.green,
    },
    {
      "value": "reading",
      "label": "Reading",
      "icon": Icons.menu_book,
      "color": Colors.blue,
    },
    {
      "value": "tbr",
      "label": "Want to Read",
      "icon": Icons.bookmark,
      "color": Colors.amber,
    },
    {
      "value": "dnf",
      "label": "DNF",
      "icon": Icons.close,
      "color": Colors.grey,
    },
  ];

  final notesController = TextEditingController();

  int timesRead = 0;

  Map stats = {
    "avg": 0.0,
    "reviews": 0,
    "readers": 0,
    "favourites": 0,
  };

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final token = await api.getToken();

      final editionRes =
      await api.get("book-editions/${widget.editionId}");

      final reviewsRes = await api.get(
        "reviews?book_edition_id=${widget.editionId}",
      );

      final ed = editionRes['data'] ?? {};
      final rev = reviewsRes['data'] ?? [];

      Map? loadedShelf;

      if (token != null && token.isNotEmpty) {
        loggedIn = true;

        final shelvesRes = await api.get("my-shelves");

        final shelves = shelvesRes['data'] ?? [];

        loadedShelf = shelves.cast<Map?>().firstWhere(
              (s) => s?['book_edition_id'] == widget.editionId,
          orElse: () => null,
        );
      }

      setState(() {
        edition = ed;
        reviews = rev;
        shelf = loadedShelf;

        if (shelf != null) {
          notesController.text = shelf?['notes'] ?? '';
          timesRead = shelf?['times_read'] ?? 0;
        }

        stats = {
          "avg": ed['average_rating'] ?? 0,
          "reviews": ed['reviews_count'] ?? rev.length,
          "readers": ed['readers_count'] ?? 0,
          "favourites": ed['favourites_count'] ?? 0,
        };

        loading = false;
      });
    } catch (_) {
      setState(() => loading = false);
    }
  }

  void browseEditions() {
    final book = edition['book'];

    if (book == null || book['id'] == null) return;

    Navigator.pushNamed(
      context,
      '/editions',
      arguments: book['id'],
    );
  }

  void addEdition() {
    final book = edition['book'];

    if (book == null || book['id'] == null) return;

    Navigator.pushNamed(
      context,
      '/book-editions/create',
      arguments: book['id'],
    );
  }

  Future<void> updateStatus(String status) async {
    if (!loggedIn) {
      Navigator.pushNamed(context, '/login');
      return;
    }

    try {
      final res = await api.post("shelves", {
        "book_edition_id": widget.editionId,
        "status": status,
      });

      setState(() {
        shelf = res['data'] ?? res;
      });
    } catch (_) {}
  }

  Future<void> updateShelf() async {
    if (shelf == null) return;

    try {
      final res = await api.post(
        "shelves/${shelf!['id']}",
        {
          "_method": "PUT",
          "favourite": shelf?['favourite'] ?? false,
          "notes": notesController.text.trim(),
          "times_read": timesRead,
          "status": shelf?['status'],
        },
      );

      setState(() {
        shelf = res['data'] ?? res;
      });
    } catch (_) {}
  }

  Future<void> toggleFavourite() async {
    if (shelf == null) return;

    setState(() {
      shelf!['favourite'] = !(shelf?['favourite'] ?? false);
    });

    await updateShelf();
  }

  Future<void> saveShelfMeta() async {
    await updateShelf();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Shelf updated"),
      ),
    );
  }

  void writeReview() {
    if (!loggedIn) {
      Navigator.pushNamed(context, '/login');
      return;
    }

    Navigator.pushNamed(
      context,
      '/reviews/create',
      arguments: widget.editionId,
    );
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  Widget shelfManagementCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Shelf Management",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          if (shelf == null)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: statuses.length,
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.7,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (_, i) {
                final s = statuses[i];

                return ElevatedButton(
                  onPressed: () => updateStatus(s['value'] as String),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: s['color'] as Color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(s['icon'] as IconData),
                      const SizedBox(height: 6),
                      Text(
                        s['label'] as String,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            )
          else
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.menu_book),
                          const SizedBox(width: 8),
                          Text(
                            shelf?['status'] ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: notesController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: "Notes...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Times Read",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          DropdownButton<int>(
                            value: timesRead,
                            items: List.generate(
                              11,
                                  (i) => DropdownMenuItem(
                                value: i,
                                child: Text(i.toString()),
                              ),
                            ),
                            onChanged: (v) {
                              setState(() {
                                timesRead = v ?? 0;
                              });
                            },
                          )
                        ],
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            shelf = null;
                          });
                        },
                        child: const Text("Change"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: saveShelfMeta,
                        child: const Text("Save"),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: toggleFavourite,
                    icon: Icon(
                      (shelf?['favourite'] ?? false)
                          ? Icons.favorite
                          : Icons.favorite_border,
                    ),
                    label: Text(
                      (shelf?['favourite'] ?? false)
                          ? "In Favourites"
                          : "Add to Favourites",
                    ),
                  ),
                )
              ],
            ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: writeReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
              child: const Text("Write Review"),
            ),
          )
        ],
      ),
    );
  }

  Widget originalBookInfoCard() {
    final book = edition['book'];

    if (book == null) {
      return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Original Book Information",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          infoRow(
            Icons.language,
            "Original Language",
            book['original_language'],
          ),

          if (book['original_publication_date'] != null)
            infoRow(
              Icons.calendar_month,
              "Original Publication",
              book['original_publication_date'],
            ),

          if (book['series'] != null)
            infoRow(
              Icons.collections_bookmark,
              "Series",
              book['series'],
            ),
        ],
      ),
    );
  }

  Widget infoRow(
      IconData icon,
      String label,
      dynamic value,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[700]),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
                Text(
                  value.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: load,
        child: ListView(
          children: [
            BookHero(
              edition: edition,
              onBrowseEditions: browseEditions,
              onAddEdition: addEdition,
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  BookStats(
                    stats: stats,
                  ),

                  const SizedBox(height: 20),

                  shelfManagementCard(),

                  const SizedBox(height: 20),

                  GenresAndMotifs(
                    genres: edition['genres'] ?? [],
                    motifs: edition['motifs'] ?? [],
                  ),

                  const SizedBox(height: 20),

                  EditionDetails(
                    edition: edition,
                  ),

                  const SizedBox(height: 20),

                  originalBookInfoCard(),

                  const SizedBox(height: 20),

                  ReviewsSection(
                    reviews: reviews,
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}