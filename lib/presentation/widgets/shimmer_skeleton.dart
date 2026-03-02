import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';

class ShimmerSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final BoxShape shape;

  const ShimmerSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.cardBackground,
      highlightColor: AppColors.backgroundSurface,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: shape == BoxShape.rectangle
              ? BorderRadius.circular(borderRadius)
              : null,
          shape: shape,
        ),
      ),
    );
  }
}

class AnimeCardSkeleton extends StatelessWidget {
  const AnimeCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image placeholder
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: const ShimmerSkeleton(
            width: 120,
            height: 180,
            borderRadius: 12,
          ),
        ),
        const SizedBox(height: 8),
        // Title placeholder
        const ShimmerSkeleton(width: 100, height: 14),
        const SizedBox(height: 4),
        // Subtitle placeholder
        const ShimmerSkeleton(width: 60, height: 12),
      ],
    );
  }
}

class HeroSkeleton extends StatelessWidget {
  const HeroSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.cardBackground,
      highlightColor: AppColors.backgroundSurface,
      child: Container(
        height: 400,
        width: double.infinity,
        color: AppColors.cardBackground,
      ),
    );
  }
}

class ListItemSkeleton extends StatelessWidget {
  final double height;

  const ListItemSkeleton({super.key, this.height = 80});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const ShimmerSkeleton(width: 60, height: 80, borderRadius: 8),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerSkeleton(width: double.infinity, height: 16),
                const SizedBox(height: 8),
                const ShimmerSkeleton(width: 150, height: 12),
                const SizedBox(height: 8),
                const ShimmerSkeleton(width: 100, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
