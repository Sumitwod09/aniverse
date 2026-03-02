import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class SearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final VoidCallback? onMicTap;
  final bool autofocus;

  const SearchBar({
    super.key,
    this.controller,
    this.hintText = 'Search anime, manga...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.onMicTap,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        style: AppTypography.body,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTypography.body.copyWith(color: AppColors.textMuted),
          prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (controller?.text.isNotEmpty ?? false)
                IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.textMuted, size: 20),
                  onPressed: onClear,
                ),
              IconButton(
                icon: const Icon(Icons.mic, color: AppColors.textMuted, size: 20),
                onPressed: onMicTap,
              ),
            ],
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      ),
    );
  }
}

class SearchBarExtended extends StatefulWidget {
  final String hintText;
  final ValueChanged<String>? onSearch;
  final VoidCallback? onFilterTap;

  const SearchBarExtended({
    super.key,
    this.hintText = 'Search anime, manga...',
    this.onSearch,
    this.onFilterTap,
  });

  @override
  State<SearchBarExtended> createState() => _SearchBarExtendedState();
}

class _SearchBarExtendedState extends State<SearchBarExtended> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SearchBar(
            controller: _controller,
            hintText: widget.hintText,
            onChanged: (_) => setState(() {}),
            onSubmitted: widget.onSearch,
            onClear: _clear,
          ),
        ),
        if (widget.onFilterTap != null) ...[
          const SizedBox(width: 8),
          IconButton(
            onPressed: widget.onFilterTap,
            icon: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.tune,
                color: AppColors.primaryAccent,
                size: 20,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
