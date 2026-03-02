import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';

class AnimeCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final double? rating;
  final bool hasSub;
  final bool hasDub;
  final VoidCallback? onTap;

  const AnimeCard({
    super.key,
    required this.imageUrl,
    required this.title,
    this.rating,
    this.hasSub = true,
    this.hasDub = false,
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
            // Image with rating badge
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
            // Sub/Dub badges
            Row(
              children: [
                if (hasSub)
                  _buildBadge('SUB', AppColors.primaryAccent),
                if (hasDub) ...[
                  const SizedBox(width: AppSpacing.xs),
                  _buildBadge('DUB', AppColors.ctaSuccess),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5), width: 0.5),
      ),
      child: Text(
        text,
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}
