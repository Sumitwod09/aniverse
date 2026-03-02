import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/download_item.dart';
import '../../data/providers/download_providers.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/shimmer_skeleton.dart';

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloads = ref.watch(downloadsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        appBar: CustomAppBar(
          title: 'Downloads',
          showBackButton: false,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: TabBar(
              indicatorColor: AppColors.primaryAccent,
              labelColor: AppColors.primaryAccent,
              unselectedLabelColor: AppColors.textMuted,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.downloading, size: 18),
                      const SizedBox(width: 8),
                      const Text('Active'),
                      const SizedBox(width: 4),
                      Consumer(
                        builder: (context, ref, child) {
                          final active = ref.watch(activeDownloadsProvider);
                          return active.when(
                            data: (list) => list.isNotEmpty
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryAccent,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${list.length}',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, size: 18),
                      const SizedBox(width: 8),
                      const Text('Completed'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body: downloads.when(
          data: (list) {
            if (list.isEmpty) {
              return const _EmptyDownloadsView();
            }
            return TabBarView(
              children: [
                _DownloadsList(
                  downloads: list
                      .where((d) =>
                          d.status == DownloadStatus.downloading ||
                          d.status == DownloadStatus.pending ||
                          d.status == DownloadStatus.paused)
                      .toList(),
                  isActive: true,
                ),
                _DownloadsList(
                  downloads: list
                      .where((d) => d.status == DownloadStatus.completed)
                      .toList(),
                  isActive: false,
                ),
              ],
            );
          },
          loading: () => const _DownloadsLoadingView(),
          error: (error, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    size: 48, color: AppColors.error),
                const SizedBox(height: AppSpacing.md),
                Text('Failed to load downloads', style: AppTypography.subheading),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DownloadsList extends StatelessWidget {
  final List<DownloadItem> downloads;
  final bool isActive;

  const _DownloadsList({
    required this.downloads,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    if (downloads.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Icons.downloading : Icons.check_circle,
              size: 64,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              isActive ? 'No active downloads' : 'No completed downloads',
              style: AppTypography.subheading.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: downloads.length,
      itemBuilder: (context, index) {
        final item = downloads[index];
        return _DownloadTile(item: item, isActive: isActive);
      },
    );
  }
}

class _DownloadTile extends ConsumerWidget {
  final DownloadItem item;
  final bool isActive;

  const _DownloadTile({
    required this.item,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 100,
                height: 60,
                color: AppColors.cardBackground,
                child: item.thumbnailUrl != null
                    ? Image.network(
                        item.thumbnailUrl!,
                        fit: BoxFit.cover,
                      )
                    : const Center(
                        child: Icon(Icons.movie, color: AppColors.textMuted),
                      ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.animeTitle,
                    style: AppTypography.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Episode ${item.episodeNumber}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (isActive && item.status == DownloadStatus.downloading) ...[
                    const SizedBox(height: AppSpacing.sm),
                    LinearProgressIndicator(
                      value: (item.progress ?? 0) / 100,
                      backgroundColor: AppColors.borderDivider,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primaryAccent,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${item.progress?.toStringAsFixed(1) ?? 0}%',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Actions
            if (isActive)
              Row(
                children: [
                  if (item.status == DownloadStatus.downloading)
                    IconButton(
                      icon: const Icon(Icons.pause),
                      onPressed: () {},
                    )
                  else if (item.status == DownloadStatus.paused)
                    IconButton(
                      icon: const Icon(Icons.play_arrow),
                      onPressed: () {},
                    ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: AppColors.error),
                    onPressed: () {
                      ref
                          .read(downloadNotifierProvider.notifier)
                          .deleteDownload(item.id);
                    },
                  ),
                ],
              )
            else
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.error),
                    onPressed: () {
                      ref
                          .read(downloadNotifierProvider.notifier)
                          .deleteDownload(item.id);
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyDownloadsView extends StatelessWidget {
  const _EmptyDownloadsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.download, size: 64, color: AppColors.textMuted),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No downloads yet',
            style: AppTypography.subheading,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Download episodes to watch offline',
            style: AppTypography.body.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to browse
            },
            icon: const Icon(Icons.explore),
            label: const Text('Browse Anime'),
          ),
        ],
      ),
    );
  }
}

class _DownloadsLoadingView extends StatelessWidget {
  const _DownloadsLoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: 5,
      itemBuilder: (context, index) => const ListItemSkeleton(),
    );
  }
}
