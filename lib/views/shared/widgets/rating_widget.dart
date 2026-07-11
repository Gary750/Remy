import 'package:flutter/material.dart';

class RatingWidget extends StatelessWidget {
  final double rating;
  final int maxRating;
  final VoidCallback? onTap;
  final bool showLabel;

  const RatingWidget({
    super.key,
    required this.rating,
    this.maxRating = 10,
    this.onTap,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _getColor(),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.star,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              showLabel 
                  ? '$rating / $maxRating'
                  : rating.toStringAsFixed(1),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColor() {
    if (rating >= 9) return Colors.green;
    if (rating >= 7) return Colors.orange;
    return Colors.red;
  }
}