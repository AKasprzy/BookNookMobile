import 'package:flutter/material.dart';

class BookHero extends StatelessWidget {
  final Map edition;
  final VoidCallback onBrowseEditions;
  final VoidCallback onAddEdition;

  const BookHero({
    super.key,
    required this.edition,
    required this.onBrowseEditions,
    required this.onAddEdition,
  });

  @override
  Widget build(BuildContext context) {
    final book = edition['book'] ?? {};

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E293B),
            Color(0xFF0F172A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        image: edition['cover_url'] != null
            ? DecorationImage(
          image: NetworkImage(edition['cover_url']),
          fit: BoxFit.cover,
          opacity: 0.12,
        )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),

          const SizedBox(height: 20),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 110,
                height: 165,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.white12,
                ),
                clipBehavior: Clip.antiAlias,
                child: edition['cover_url'] != null
                    ? Image.network(
                  edition['cover_url'],
                  fit: BoxFit.cover,
                )
                    : const Icon(
                  Icons.book,
                  size: 50,
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (book['series'] != null)
                      Text(
                        book['series'],
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),

                    const SizedBox(height: 6),

                    Text(
                      edition['edition_title'] ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "by ${book['author'] ?? ''}",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        chip(edition['format']),
                        chip(edition['edition_language']),
                        if (edition['edition_publication_date'] != null)
                          chip(
                            edition['edition_publication_date']
                                .toString()
                                .split('-')
                                .first,
                          ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),

          if (edition['description'] != null) ...[
            const SizedBox(height: 20),
            Text(
              edition['description'],
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white70,
                height: 1.5,
              ),
            ),
          ],

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onAddEdition,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("Add Edition"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: onBrowseEditions,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("Browse Editions"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget chip(String? text) {
    if (text == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}