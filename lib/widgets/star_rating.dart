import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final int rating; // 0-5
  final Color color;
  final double size;
  final bool allowHalfRating;
  final ValueChanged<int>? onRatingChanged;

  const StarRating({
    super.key,
    required this.rating,
    required this.color,
    this.size = 20,
    this.allowHalfRating = false,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starRating = index + 1;
        final isFilled = starRating <= rating;
        final isHalfFilled = allowHalfRating && 
            starRating - 0.5 <= rating && 
            starRating > rating;
        
        IconData icon;
        if (isFilled) {
          icon = Icons.star;
        } else if (isHalfFilled) {
          icon = Icons.star_half;
        } else {
          icon = Icons.star_border;
        }

        return IconButton(
          onPressed: onRatingChanged != null
              ? () => onRatingChanged!(index + 1)
              : null,
          icon: Icon(icon, size: size, color: color),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        );
      }),
    );
  }
}
