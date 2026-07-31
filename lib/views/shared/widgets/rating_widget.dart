import 'package:flutter/material.dart';

class RatingWidget extends StatelessWidget {
  final double rating;
  final int maxRating;
  final VoidCallback? onTap;
  final bool showLabel;
  final bool isExpanded; // ✅ Nuevo parámetro para expandir

  const RatingWidget({
    super.key,
    required this.rating,
    this.maxRating = 10,
    this.onTap,
    this.showLabel = true,
    this.isExpanded = false, // ✅ Por defecto false
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Si rating es 0 o menor, no mostrar nada
    if (rating <= 0) {
      return const SizedBox.shrink();
    }

    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getColor(),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star,
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            showLabel 
                ? '${rating.toStringAsFixed(1)} / $maxRating'
                : rating.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );

    // ✅ Si isExpanded es true, ocupa todo el ancho disponible
    return isExpanded 
        ? SizedBox(
            width: double.infinity,
            child: child,
          )
        : child;
  }

  Color _getColor() {
    final percentage = rating / maxRating;
    if (percentage >= 0.8) return Colors.green.shade600;
    if (percentage >= 0.6) return Colors.orange.shade600;
    return Colors.red.shade600;
  }
}