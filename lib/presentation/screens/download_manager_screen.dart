import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/providers/download_providers.dart';
import '../../data/services/download_service.dart';
import '../widgets/custom_app_bar.dart';

class DownloadManagerScreen extends ConsumerStatefulWidget {
  const DownloadManagerScreen({super.key});

  @override
  ConsumerState<DownloadManagerScreen> createState() => _DownloadManagerScreenState();
}

class _DownloadManagerScreenState extends ConsumerState<DownloadManagerScreen> {
  @override
  Widget build(BuildContext context) {
    final downloads = ref.watch(downloadsProvider);
    final downloadService = ref.watch(downloadServiceProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: CustomAppBar(
        title: 'Download Manager',
        actions: [
          IconButton(
            icon: const Icon(Icons.storage),
            onPressed: () => _showStorageInfo(downloadService),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'clear_completed':
                  ref.read(downloadNotifierProvider.notifier).clearCompleted();
                  break;
                case 'pause_all':
                  // TODO: Implement pause all
                  break;
                case 'resume_all':
                  // TODO: Implement resume all
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_completed',
                child: Text('Clear Completed'),
              ),
              const PopupMenuItem(
                value: 'pause_all',
                child: Text('Pause All'),
              ),
              const PopupMenuItem(
                value: 'resume_all',
                child: Text('Resume All'),
              ),
            ],
          ),
        ],
      ),
      body: downloads.when(
        data: (list) {
          if (list.isEmpty) {
            return const _EmptyDownloadsView();
          }
          return _DownloadList(downloads: list);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('Error: $error', style: AppTypography.body),
        ),
      ),
    );
  }

  void _showStorageInfo(DownloadService service) async {
    final used = await service.getUsedSpace();
    final available = await service.getAvailableSpace();
    
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: Text('Storage', style: AppTypography.subheading),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StorageRow(
                label: 'Used',
                value: service.formatBytes(used),
                color: AppColors.primaryAccent,
              ),
              const SizedBox(height: AppSpacing.sm),
              _StorageRow(
                label: 'Available',
                value: service.formatBytes(available),
                color: AppColors.ctaSuccess,
              ),
              const SizedBox(height: AppSpacing.md),
              LinearProgressIndicator(
                value: available > 0 ? used / (used + available) : 0,
                backgroundColor: AppColors.borderDivider,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primaryAccent,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }
}

class _DownloadList extends StatelessWidget {
  final List<dynamic> downloads;

  const _DownloadList({required this.downloads});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: downloads.length,
      itemBuilder: (context, index) {
        final item = downloads[index];
        return _DownloadListItem(item: item);
      },
    );
  }
}

class _DownloadListItem extends StatelessWidget {
  final dynamic item;

  const _DownloadListItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 60,
            height: 80,
            color: AppColors.cardBackground,
            child: item.thumbnailUrl != null
                ? Image.network(
                    item.thumbnailUrl as String,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.movie, color: AppColors.textMuted),
          ),
        ),
        title: Text(
          item.animeTitle as String,
          style: AppTypography.bodyMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Episode ${item.episodeNumber}',
              style: AppTypography.caption,
            ),
            const SizedBox(height: AppSpacing.sm),
            if (item.status.toString().contains('downloading'))
              LinearProgressIndicator(
                value: ((item.progress as double?) ?? 0) / 100,
                backgroundColor: AppColors.borderDivider,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primaryAccent,
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(item.status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.status.toString().split('.').last,
                  style: AppTypography.caption.copyWith(
                    color: _getStatusColor(item.status),
                  ),
                ),
              ),
          ],
        ),
        trailing: _buildTrailingAction(),
      ),
    );
  }

  Widget _buildTrailingAction() {
    if (item.status.toString().contains('downloading')) {
      return IconButton(
        icon: const Icon(Icons.pause, color: AppColors.primaryAccent),
        onPressed: () {},
      );
    } else if (item.status.toString().contains('paused')) {
      return IconButton(
        icon: const Icon(Icons.play_arrow, color: AppColors.ctaSuccess),
        onPressed: () {},
      );
    } else if (item.status.toString().contains('completed')) {
      return IconButton(
        icon: const Icon(Icons.play_arrow, color: AppColors.primaryAccent),
        onPressed: () {},
      );
    } else {
      return IconButton(
        icon: const Icon(Icons.refresh, color: AppColors.textMuted),
        onPressed: () {},
      );
    }
  }

  Color _getStatusColor(dynamic status) {
    final statusStr = status.toString().split('.').last;
    switch (statusStr) {
      case 'completed':
        return AppColors.ctaSuccess;
      case 'downloading':
        return AppColors.primaryAccent;
      case 'paused':
        return AppColors.warning;
      case 'failed':
        return AppColors.error;
      default:
        return AppColors.textMuted;
    }
  }
}

class _StorageRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StorageRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(label, style: AppTypography.body),
        const Spacer(),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
          const Icon(Icons.download_done, size: 64, color: AppColors.textMuted),
          const SizedBox(height: AppSpacing.md),
          Text('No downloads', style: AppTypography.subheading),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Your download queue is empty',
            style: AppTypography.body.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
