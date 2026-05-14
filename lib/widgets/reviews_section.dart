import 'package:flutter/material.dart';

class ReviewsSection extends StatelessWidget {
  final List reviews;

  const ReviewsSection({
    super.key,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Reviews",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        ...reviews.map(
              (review) => ReviewCard(review: review),
        )
      ],
    );
  }
}

class ReviewCard extends StatelessWidget {
  final Map review;

  const ReviewCard({
    super.key,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    final user = review['user'] ?? {};

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      padding: const EdgeInsets.all(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user['name'] ?? "User",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Row(
            children: List.generate(
              5,
                  (i) => Icon(
                i < (review['rating'] ?? 0)
                    ? Icons.star
                    : Icons.star_border,
                size: 18,
                color: Colors.amber,
              ),
            ),
          ),

          if (review['review_text'] != null) ...[
            const SizedBox(height: 10),
            Text(
              review['review_text'],
              style: const TextStyle(height: 1.5),
            ),
          ]
        ],
      ),
    );
  }
}