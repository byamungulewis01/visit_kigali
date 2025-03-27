import 'package:flutter/material.dart';
import '../models/review.dart';
import '../widgets/rating_bar.dart';

class ReviewCard extends StatelessWidget {
  final Review review;

  const ReviewCard({Key? key, required this.review}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('${review.name}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                CustomRatingBar(rating: review.rating.toDouble(), size: 16),
              ],
            ),
            Text(review.content),
          ],
        ),
      ),
    );
  }
}
