import 'package:flutter/material.dart';

class BookStats extends StatelessWidget {
  final Map stats;

  const BookStats({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        "icon": Icons.star,
        "label": "Rating",
        "value": stats["avg"].toStringAsFixed(1)
      },
      {
        "icon": Icons.rate_review,
        "label": "Reviews",
        "value": stats["reviews"].toString()
      },
      {
        "icon": Icons.people,
        "label": "Readers",
        "value": stats["readers"].toString()
      },
      {
        "icon": Icons.favorite,
        "label": "Favourites",
        "value": stats["favourites"].toString()
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (_, i) {
          final item = items[i];

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                )
              ],
            ),
            child: Row(
              children: [
                Icon(
                  item["icon"] as IconData,
                  color: Colors.indigo,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["label"] as String,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item["value"] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}