import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';

class MangaCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final double? rating;
  final String? status;
  final int? chapterCount;
  final VoidCallback? onTap;

  const MangaCard({
    super.key,
    required this.imageUrl,
    required this.title,
    this.rating,
    this.status,
    this.chapterCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            AspectRatio(
              aspectRatio: 2 / 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: AppColors.cardBackground,
                        highlightColor: AppColors.backgroundSurface,
                        child: Container(color: AppColors.cardBackground),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.cardBackground,
                        child: const Icon(Icons.error, color: AppColors.textMuted),
                      ),
                    ),
                    // Rating badge
                    if (rating != null)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.ctaSuccess,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            rating!.toStringAsFixed(1),
                            style: AppTypography.captionMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    // Status badge
                    if (status != null)
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            status!.toUpperCase(),
                            style: AppTypography.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            // Title
            Text(
              title,
              style: AppTypography.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xs),
            // Chapter count
            if (chapterCount != null)
              Text(
                '$chapterCount Chapters',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class MangaCardSkeleton extends StatelessWidget {
  const MangaCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Shimmer.fromColors(
            baseColor: AppColors.cardBackground,
            highlightColor: AppColors.backgroundSurface,
            child: Container(
              width: 120,
              height: 180,
              color: AppColors.cardBackground,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Shimmer.fromColors(
          baseColor: AppColors.cardBackground,
          highlightColor: AppColors.backgroundSurface,
          child: Container(
            width: 100,
            height: 14,
            color: AppColors.cardBackground,
          ),
        ),
        const SizedBox(height: 4),
        Shimmer.fromColors(
          baseColor: AppColors.cardBackground,
          highlightColor: AppColors.backgroundSurface,
          child: Container(
            width: 60,
            height: 12,
            color: AppColors.cardBackground,
          ),
        ),
      ],
    );
  }
}
