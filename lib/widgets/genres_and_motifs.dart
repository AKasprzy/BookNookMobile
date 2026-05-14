import 'package:flutter/material.dart';

class GenresAndMotifs extends StatelessWidget {
  final List genres;
  final List motifs;

  const GenresAndMotifs({
    super.key,
    required this.genres,
    required this.motifs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (genres.isNotEmpty) ...[
            const Text(
              "Genres",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: genres.map((g) {
                return chip(
                  g['name'],
                  Colors.green.shade50,
                  Colors.green,
                );
              }).toList(),
            ),
          ],

          if (motifs.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              "Themes & Motifs",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: motifs.map((m) {
                return chip(
                  m['name'],
                  Colors.purple.shade50,
                  Colors.purple,
                );
              }).toList(),
            ),
          ]
        ],
      ),
    );
  }

  Widget chip(String text, Color bg, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  BoxDecoration cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 8,
        )
      ],
    );
  }
}