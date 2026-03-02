import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class VideoPlayerScreen extends ConsumerStatefulWidget {
  final String videoUrl;
  final String title;
  final String? thumbnailUrl;
  final int? episodeNumber;
  final int? totalEpisodes;

  const VideoPlayerScreen({
    super.key,
    required this.videoUrl,
    required this.title,
    this.thumbnailUrl,
    this.episodeNumber,
    this.totalEpisodes,
  });

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );

      await _videoController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoController!.value.aspectRatio,
        placeholder: widget.thumbnailUrl != null
            ? Center(
                child: Image.network(
                  widget.thumbnailUrl!,
                  fit: BoxFit.cover,
                ),
              )
            : Container(color: AppColors.backgroundPrimary),
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.primaryAccent,
          handleColor: AppColors.primaryAccent,
          bufferedColor: AppColors.cardBackground,
          backgroundColor: AppColors.borderDivider,
        ),
        cupertinoProgressColors: ChewieProgressColors(
          playedColor: AppColors.primaryAccent,
          handleColor: AppColors.primaryAccent,
          bufferedColor: AppColors.cardBackground,
          backgroundColor: AppColors.borderDivider,
        ),
        showControls: true,
        allowMuting: true,
        allowFullScreen: true,
        allowPlaybackSpeedChanging: true,
        playbackSpeeds: const [0.5, 0.75, 1.0, 1.25, 1.5, 2.0],
      );

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Column(
        children: [
          // Video Player
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.black,
              child: _buildPlayerContent(),
            ),
          ),

          // Episode Info
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: AppTypography.subheading,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.episodeNumber != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Episode ${widget.episodeNumber}${widget.totalEpisodes != null ? ' / ${widget.totalEpisodes}' : ''}',
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Episode Navigation
          if (widget.episodeNumber != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: widget.episodeNumber! > 1
                        ? () => _navigateEpisode(widget.episodeNumber! - 1)
                        : null,
                    icon: const Icon(Icons.skip_previous),
                    label: const Text('Previous'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cardBackground,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: widget.totalEpisodes != null &&
                            widget.episodeNumber! < widget.totalEpisodes!
                        ? () => _navigateEpisode(widget.episodeNumber! + 1)
                        : null,
                    icon: const Icon(Icons.skip_next),
                    label: const Text('Next'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryAccent,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: AppSpacing.md),

          // Quality Selector
          const _QualitySelector(),
        ],
      ),
    );
  }

  Widget _buildPlayerContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryAccent),
      );
    }

    if (_hasError || _chewieController == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Failed to load video',
              style: AppTypography.subheading,
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _hasError = false;
                });
                _initializePlayer();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Chewie(controller: _chewieController!);
  }

  void _navigateEpisode(int episodeNumber) {
    // Navigate to next/previous episode
  }
}

class _QualitySelector extends StatelessWidget {
  const _QualitySelector();

  @override
  Widget build(BuildContext context) {
    final qualities = ['1080p', '720p', '480p', '360p'];
    String selectedQuality = '1080p';

    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Quality', style: AppTypography.subheading),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                children: qualities.map((quality) {
                  final isSelected = selectedQuality == quality;
                  return ChoiceChip(
                    label: Text(quality),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => selectedQuality = quality);
                      }
                    },
                    backgroundColor: AppColors.cardBackground,
                    selectedColor: AppColors.primaryAccent.withOpacity(0.3),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primaryAccent
                          : AppColors.borderDivider,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
