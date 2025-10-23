import 'package:codemy_app/src/presentation/providers/theme_provider.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:codemy_app/src/features/course/providers/lesson_provider.mock.dart';

class MdView extends ConsumerStatefulWidget {
  const MdView({super.key});

  @override
  ConsumerState<MdView> createState() => _MdViewState();
}

class _MdViewState extends ConsumerState<MdView> {
  final ScrollController _scrollController = ScrollController();
  String _markdownContent = '';
  bool _isLoading = true;
  late final LessonNotifier _lessonNotifier;
  @override
  void initState() {
    super.initState();
    _loadMarkdownContent();
    _scrollController.addListener(_onScroll);
    _lessonNotifier = ref.read(lessonProvider.notifier);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    // Mock unmount trigger for progress saving
    _lessonNotifier.saveProgress();
    super.dispose();
  }

  Future<void> _loadMarkdownContent() async {
    try {
      final content = await rootBundle.loadString('assets/test/md_content.md');
      setState(() {
        _markdownContent = content;
        _isLoading = false;
      });
      // Set the lesson content in the provider
      _lessonNotifier.setLesson(content);

      // Auto-scroll to saved progress position after layout is complete
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _restoreScrollPosition();
      });
    } catch (e) {
      setState(() {
        _markdownContent = 'Error loading markdown content: $e';
        _isLoading = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      final progress = maxScroll > 0
          ? (currentScroll / maxScroll).clamp(0.0, 1.0)
          : 0.0;
      _lessonNotifier.setProgress(progress);
    }
  }

  void _restoreScrollPosition() {
    if (_scrollController.hasClients && mounted) {
      final lessonState = ref.read(lessonProvider);
      final maxScroll = _scrollController.position.maxScrollExtent;
      final targetScrollPosition = maxScroll * lessonState.currentProgress;

      if (targetScrollPosition > 0) {
        _scrollController.animateTo(
          targetScrollPosition,
          duration: const Duration(milliseconds: 300),
          curve: material.Curves.easeOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lessonState = ref.watch(lessonProvider);
    final currentTheme = ref.watch(themeModeProvider);
    final isDark = currentTheme == ShadcnThemeMode.dark;
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Card(
      child: Column(
        children: [
          // Progress indicator at the top
          LinearProgressIndicator(
            value: lessonState.currentProgress,
            minHeight: 4,
          ),
          // Progress text
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Progress: ${(lessonState.currentProgress * 100).toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          const Divider(),
          // Markdown content with fixed height constraint
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: MarkdownBlock(
                data: _markdownContent,
                config: isDark
                    ? MarkdownConfig.darkConfig
                    : MarkdownConfig.defaultConfig,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
