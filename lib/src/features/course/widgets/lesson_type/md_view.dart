import 'package:codemy_app/src/features/course/models/entities/lesson.dart';
import 'package:codemy_app/src/features/course/providers/lesson_provider.dart';
import 'package:codemy_app/src/presentation/providers/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class MdView extends ConsumerStatefulWidget {
  final Lesson? lesson;
  final String? lessonId;

  const MdView({super.key, this.lesson, this.lessonId})
    : assert(
        lesson != null || lessonId != null,
        'Either lesson or lessonId must be provided',
      );

  @override
  ConsumerState<MdView> createState() => _MdViewState();
}

class _MdViewState extends ConsumerState<MdView> {
  final ScrollController _scrollController = ScrollController();
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      final progress = maxScroll > 0
          ? (currentScroll / maxScroll).clamp(0.0, 1.0)
          : 0.0;
      setState(() {
        _progress = progress;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ShadcnThemeMode.dark;

    // Choose lesson from provided value or from provider
    final lessonAsync = widget.lesson != null
        ? AsyncValue.data(widget.lesson!)
        : ref.watch(lessonDetailProvider(widget.lessonId!));

    return Card(
      child: Column(
        children: [
          LinearProgressIndicator(value: _progress, minHeight: 4),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Progress: ${(_progress * 100).toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          const Divider(),
          SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            child: lessonAsync.when(
              data: (lesson) {
                final raw = lesson.contentUrl?.trim() ?? '';
                final md = raw.isEmpty
                    ? 'Lesson content is not available yet.'
                    : raw;
                return MarkdownBlock(
                  data: md,
                  config: isDark
                      ? MarkdownConfig.darkConfig
                      : MarkdownConfig.defaultConfig,
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) =>
                  Center(child: Text('Failed to load lesson content: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
