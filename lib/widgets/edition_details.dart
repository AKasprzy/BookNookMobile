import 'package:flutter/material.dart';

class EditionDetails extends StatelessWidget {
  final Map edition;

  const EditionDetails({
    super.key,
    required this.edition,
  });

  @override
  Widget build(BuildContext context) {
    final details = [
      {
        "icon": Icons.business,
        "label": "Publisher",
        "value": edition['publisher'],
      },
      {
        "icon": Icons.calendar_month,
        "label": "Publication Date",
        "value": edition['edition_publication_date'],
      },
      {
        "icon": Icons.menu_book,
        "label": "Pages",
        "value": edition['page_count'] != null
            ? "${edition['page_count']} pages"
            : null,
      },
      {
        "icon": Icons.timer,
        "label": "Length",
        "value": edition['length_minutes'] != null
            ? "${edition['length_minutes']} min"
            : null,
      },
      {
        "icon": Icons.language,
        "label": "Language",
        "value": edition['edition_language'],
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: decoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Edition Details",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          ...details
              .where((d) => d['value'] != null)
              .map(
                (d) => Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    d['icon'] as IconData,
                    color: Colors.indigo,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d['label'] as String,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          d['value'].toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  BoxDecoration decoration() {
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