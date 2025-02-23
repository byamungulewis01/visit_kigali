import 'package:flutter/material.dart';

class CustomRatingBar extends StatelessWidget {
  final double rating;
  final double size;
  final bool isInteractive;
  final ValueChanged<double>? onRatingUpdate;

  const CustomRatingBar({
    Key? key,
    required this.rating,
    this.size = 24,
    this.isInteractive = false,
    this.onRatingUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: isInteractive
              ? () => onRatingUpdate?.call(index + 1.0)
              : null,
          child: Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: size,
          ),
        );
      }),
    );
  }
}