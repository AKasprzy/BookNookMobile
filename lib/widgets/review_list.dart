import 'package:flutter/material.dart';

class ReviewList extends StatefulWidget {
  final List reviews;
  final Function(int) onUserTap;

  const ReviewList({super.key, required this.reviews, required this.onUserTap});

  @override
  State<ReviewList> createState() => _ReviewListState();
}

class _ReviewListState extends State<ReviewList> {
  Set<int> revealed = {};

  void toggle(int id) {
    setState(() {
      revealed.contains(id) ? revealed.remove(id) : revealed.add(id);
    });
  }

  String timeAgo(String date) {
    final diff = DateTime.now().difference(DateTime.parse(date));
    if (diff.inHours < 1) return "Just now";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    return "${diff.inDays}d ago";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.reviews.map((r) {
        final spoiler = r['spoiler'] == true;
        final show = revealed.contains(r['id']);

        return GestureDetector(
          onTap: () => widget.onUserTap(r['user']['id']),
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r['user']['name']),
                Text(timeAgo(r['created_at']), style: const TextStyle(fontSize: 12)),
                Text(r['book']['title']),
                if (spoiler && !show)
                  TextButton(onPressed: () => toggle(r['id']), child: const Text("Show spoiler"))
                else
                  Text(r['review_text'] ?? "")
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}