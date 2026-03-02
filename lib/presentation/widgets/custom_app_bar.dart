import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final bool transparent;
  final bool centerTitle;
  final double elevation;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.onBackPressed,
    this.transparent = false,
    this.centerTitle = true,
    this.elevation = 0,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: titleWidget ?? (title != null ? Text(title!, style: AppTypography.heading) : null),
      centerTitle: centerTitle,
      backgroundColor: transparent ? Colors.transparent : AppColors.backgroundPrimary,
      elevation: elevation,
      leading: leading ?? (showBackButton && Navigator.canPop(context)
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: onBackPressed ?? () => Navigator.pop(context),
            )
          : null),
      actions: actions,
      bottom: bottom,
      flexibleSpace: transparent
          ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.backgroundPrimary.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
            )
          : null,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );
}

class SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  final double expandedHeight;
  final Widget? background;
  final List<Widget>? actions;

  SliverAppBarDelegate({
    required this.title,
    this.expandedHeight = 300,
    this.background,
    this.actions,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final progress = shrinkOffset / expandedHeight;
    final titleOpacity = progress.clamp(0.0, 1.0);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Background
        if (background != null)
          Opacity(
            opacity: 1 - progress,
            child: background,
          ),

        // Gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.backgroundPrimary.withOpacity(0.8 * progress),
                AppColors.backgroundPrimary.withOpacity(0.3 * progress),
                Colors.transparent,
              ],
            ),
          ),
        ),

        // App bar content
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Opacity(
                    opacity: titleOpacity,
                    child: Text(
                      title,
                      style: AppTypography.heading,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                if (actions != null) ...actions!,
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => kToolbarHeight + 24; // Approximate status bar height

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}
