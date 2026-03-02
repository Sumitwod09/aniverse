import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/anime.dart';
import '../../data/providers/anime_providers.dart';
import '../widgets/anime_card.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/shimmer_skeleton.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _days.length, vsync: this);
    _tabController.index = _getCurrentDayIndex();
  }

  int _getCurrentDayIndex() {
    final now = DateTime.now();
    final weekday = now.weekday; // 1 = Monday, 7 = Sunday
    return weekday - 1;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheduleAsync = ref.watch(scheduleProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: CustomAppBar(
        title: 'Schedule',
        showBackButton: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppColors.primaryAccent,
            labelColor: AppColors.primaryAccent,
            unselectedLabelColor: AppColors.textMuted,
            tabs: _days.map((day) {
              final isToday = _days.indexOf(day) == _getCurrentDayIndex();
              return Tab(
                child: Row(
                  children: [
                    Text(day.substring(0, 3)),
                    if (isToday) ...[
                      const SizedBox(width: 4),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.ctaSuccess,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
      body: scheduleAsync.when(
        data: (schedules) {
          return TabBarView(
            controller: _tabController,
            children: _days.map((day) {
              final daySchedule = schedules.firstWhere(
                (s) => s.day.toLowerCase() == day.toLowerCase(),
                orElse: () => Schedule(day: day, anime: []),
              );
              return _DayScheduleContent(schedule: daySchedule);
            }).toList(),
          );
        },
        loading: () => const _ScheduleLoadingView(),
        error: (error, _) => _ScheduleErrorView(
          onRetry: () => ref.invalidate(scheduleProvider),
        ),
      ),
    );
  }
}

class _DayScheduleContent extends StatelessWidget {
  final Schedule schedule;

  const _DayScheduleContent({required this.schedule});

  @override
  Widget build(BuildContext context) {
    if (schedule.anime.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No releases on ${schedule.day}',
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
      itemCount: schedule.anime.length,
      itemBuilder: (context, index) {
        final anime = schedule.anime[index];
        return _ScheduleCard(anime: anime);
      },
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final ScheduledAnime anime;

  const _ScheduleCard({required this.anime});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // Time
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  anime.time ?? 'TBA',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.primaryAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 120,
                  color: AppColors.cardBackground,
                  child: anime.coverImage != null
                      ? Image.network(
                          anime.coverImage!,
                          fit: BoxFit.cover,
                        )
                      : const Center(
                          child: Icon(
                            Icons.movie,
                            color: AppColors.textMuted,
                          ),
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
                      anime.title,
                      style: AppTypography.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (anime.episodeNumber != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Episode ${anime.episodeNumber}',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.notifications_outlined,
                            size: 20,
                            color: AppColors.textMuted,
                          ),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.add,
                            size: 20,
                            color: AppColors.primaryAccent,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScheduleLoadingView extends StatelessWidget {
  const _ScheduleLoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: 5,
      itemBuilder: (context, index) => const ListItemSkeleton(),
    );
  }
}

class _ScheduleErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _ScheduleErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: AppSpacing.md),
          Text('Failed to load schedule', style: AppTypography.subheading),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
