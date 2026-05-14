import 'package:flutter/material.dart';
import '../services/api_service.dart';

class UserProfileScreen extends StatefulWidget {
  final int userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final api = ApiService();

  bool loading = true;
  Map user = {};
  List shelves = [];
  List reviews = [];

  int totalBooks = 0;
  int totalReviews = 0;
  double avgRating = 0;
  int favourites = 0;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final userRes = await api.get("user/${widget.userId}");
      final shelvesRes = await api.get("user/${widget.userId}/shelves");
      final reviewsRes = await api.get("user/${widget.userId}/reviews");

      final shelfData = shelvesRes['data'] ?? [];
      final reviewData = reviewsRes['data'] ?? [];

      final rated = reviewData.where((r) => r['rating'] != null).toList();

      setState(() {
        user = userRes['data'] ?? {};
        shelves = shelfData;
        reviews = reviewData;

        totalBooks = shelfData.where((s) => s['status'] == 'read').length;
        totalReviews = reviewData.length;

        avgRating = rated.isEmpty
            ? 0
            : rated.fold(0.0, (a, b) => a + (b['rating'] ?? 0)) /
            rated.length;

        favourites =
            shelfData.where((s) => s['favourite'] == true).length;

        loading = false;
      });
    } catch (_) {
      setState(() => loading = false);
    }
  }

  String initials(String name) {
    return name
        .split(" ")
        .where((e) => e.isNotEmpty)
        .map((e) => e[0])
        .join()
        .toUpperCase();
  }

  String formatDate(String? date) {
    if (date == null) return "";
    final d = DateTime.parse(date);
    return "${d.day}/${d.month}/${d.year}";
  }

  Widget statCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6)
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                    const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
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
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.white),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white24,
                  child: Text(
                    initials(user['name'] ?? ""),
                    style: const TextStyle(
                        fontSize: 24, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user['name'] ?? "",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                if (user['location'] != null)
                  Text(user['location'],
                      style:
                      const TextStyle(color: Colors.white70)),
                if (user['joined_at'] != null)
                  Text(
                    "Joined ${formatDate(user['joined_at'])}",
                    style:
                    const TextStyle(color: Colors.white70),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.6,
              ),
              itemBuilder: (context, i) {
                final items = [
                  {
                    "icon": Icons.menu_book,
                    "label": "Books read",
                    "value": totalBooks.toString(),
                    "color": Colors.blue
                  },
                  {
                    "icon": Icons.star,
                    "label": "Reviews",
                    "value": totalReviews.toString(),
                    "color": Colors.amber
                  },
                  {
                    "icon": Icons.trending_up,
                    "label": "Avg rating",
                    "value":
                    avgRating.toStringAsFixed(1),
                    "color": Colors.purple
                  },
                  {
                    "icon": Icons.favorite,
                    "label": "Favourites",
                    "value": favourites.toString(),
                    "color": Colors.red
                  },
                ];

                final item = items[i];

                return statCard(
                  item["icon"] as IconData,
                  item["label"] as String,
                  item["value"] as String,
                  item["color"] as Color,
                );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text("Recently Read",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),
          ...shelves.map((s) {
            final book = s['edition']['book'];

            return Container(
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
                    width: 60,
                    height: 90,
                    color: Colors.grey[300],
                    child: s['edition']['cover_url'] != null
                        ? Image.network(
                      s['edition']['cover_url'],
                      fit: BoxFit.cover,
                    )
                        : const Icon(Icons.book),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(book['title'],
                            style: const TextStyle(
                                fontWeight:
                                FontWeight.bold)),
                        Text(book['author'],
                            style: const TextStyle(
                                color: Colors.grey)),
                      ],
                    ),
                  ),
                  if (s['favourite'] == true)
                    const Icon(Icons.favorite,
                        color: Colors.red)
                ],
              ),
            );
          }),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text("Reviews",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),
          ...reviews.map((r) {
            return Container(
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
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  if (r['rating'] != null)
                    Row(
                      children: List.generate(
                        5,
                            (i) => Icon(
                          i < r['rating']
                              ? Icons.star
                              : Icons.star_border,
                          size: 16,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  if (r['review_text'] != null)
                    Padding(
                      padding:
                      const EdgeInsets.only(top: 6),
                      child: Text(r['review_text']),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    formatDate(r['reviewed_at']),
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey),
                  )
                ],
              ),
            );
          }),
          const SizedBox(height: 30)
        ],
      ),
    );
  }
}