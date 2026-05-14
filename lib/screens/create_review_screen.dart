import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CreateReviewScreen extends StatefulWidget {
  final int editionId;

  const CreateReviewScreen({
    super.key,
    required this.editionId,
  });

  @override
  State<CreateReviewScreen> createState() => _CreateReviewScreenState();
}

class _CreateReviewScreenState extends State<CreateReviewScreen> {
  final api = ApiService();

  final rating = TextEditingController();
  final reviewText = TextEditingController();
  final reviewedAt = TextEditingController();

  bool spoiler = false;
  bool reread = false;

  bool loading = false;

  Future<void> submit() async {
    setState(() => loading = true);

    try {
      await api.post("reviews", {
        "book_edition_id": widget.editionId,
        "rating": rating.text.trim().isEmpty
            ? null
            : int.parse(rating.text.trim()),
        "review_text": reviewText.text.trim().isEmpty
            ? null
            : reviewText.text.trim(),
        "spoiler": spoiler,
        "reread": reread,
        "reviewed_at": reviewedAt.text.trim().isEmpty
            ? null
            : reviewedAt.text.trim(),
      });

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  Widget input(
      String label,
      TextEditingController c, {
        TextInputType? type,
        bool required = false,
        int maxLines = 1,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
            ),
            children: [
              TextSpan(
                text: label,
                style: TextStyle(
                  fontWeight:
                  required ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (required)
                const TextSpan(
                  text: " *",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: c,
          keyboardType: type,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  Widget checkbox(
      String label,
      bool value,
      Function(bool?) onChanged,
      ) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      controlAffinity: ListTileControlAffinity.leading,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Create Review",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Share your thoughts about this edition",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                section("Review Information", [
                  input(
                    "Rating (1-10)",
                    rating,
                    type: TextInputType.number,
                  ),
                  input(
                    "Review Text",
                    reviewText,
                    maxLines: 6,
                  ),
                  input(
                    "Reviewed At",
                    reviewedAt,
                  ),
                  checkbox(
                    "Contains Spoilers",
                    spoiler,
                        (v) => setState(() => spoiler = v ?? false),
                  ),
                  checkbox(
                    "Reread",
                    reread,
                        (v) => setState(() => reread = v ?? false),
                  ),
                ]),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: loading ? null : submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                  child: Text(
                    loading ? "Creating..." : "Create Review",
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget section(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...children.map(
                (w) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: w,
            ),
          )
        ],
      ),
    );
  }
}