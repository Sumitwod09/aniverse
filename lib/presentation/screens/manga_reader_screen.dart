import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/manga.dart';
import '../../data/providers/manga_providers.dart';

class MangaReaderScreen extends ConsumerStatefulWidget {
  final String chapterId;
  final Chapter chapter;

  const MangaReaderScreen({
    super.key,
    required this.chapterId,
    required this.chapter,
  });

  @override
  ConsumerState<MangaReaderScreen> createState() => _MangaReaderScreenState();
}

class _MangaReaderScreenState extends ConsumerState<MangaReaderScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  bool _showControls = true;
  bool _isHorizontal = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
  }

  void _nextPage(int totalPages) {
    if (_currentPage < totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pagesAsync = ref.watch(chapterPagesProvider(widget.chapterId));

    return Scaffold(
      backgroundColor: Colors.black,
      body: pagesAsync.when(
        data: (pages) => Stack(
          children: [
            // Page Viewer
            GestureDetector(
              onTap: _toggleControls,
              child: PhotoViewGallery.builder(
                pageController: _pageController,
                scrollDirection: _isHorizontal ? Axis.horizontal : Axis.vertical,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: pages.pages.length,
                builder: (context, index) {
                  return PhotoViewGalleryPageOptions(
                    imageProvider: NetworkImage(pages.pages[index]),
                    initialScale: PhotoViewComputedScale.contained,
                    minScale: PhotoViewComputedScale.contained * 0.8,
                    maxScale: PhotoViewComputedScale.covered * 2,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.broken_image, color: Colors.white, size: 48),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Failed to load image',
                            style: AppTypography.body.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                loadingBuilder: (context, event) => Center(
                  child: CircularProgressIndicator(
                    value: event == null
                        ? 0
                        : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
                    color: AppColors.primaryAccent,
                  ),
                ),
              ),
            ),

            // Controls Overlay
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: SafeArea(
                child: Column(
                  children: [
                    // Top Bar
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.chapter.title,
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Page ${_currentPage + 1} / ${pages.pages.length}',
                                  style: AppTypography.caption.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              _isHorizontal ? Icons.swap_vert : Icons.swap_horiz,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() => _isHorizontal = !_isHorizontal);
                            },
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Bottom Controls
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.skip_previous, color: Colors.white),
                            onPressed: _currentPage > 0 ? _prevPage : null,
                          ),
                          Expanded(
                            child: Slider(
                              value: _currentPage.toDouble(),
                              min: 0,
                              max: (pages.pages.length - 1).toDouble(),
                              onChanged: (value) {
                                _pageController.jumpToPage(value.toInt());
                              },
                              activeColor: AppColors.primaryAccent,
                              inactiveColor: Colors.white30,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.skip_next, color: Colors.white),
                            onPressed: _currentPage < pages.pages.length - 1
                                ? () => _nextPage(pages.pages.length)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryAccent),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 48),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Failed to load chapter',
                style: AppTypography.subheading.copyWith(color: Colors.white),
              ),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: () => ref.invalidate(chapterPagesProvider(widget.chapterId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
