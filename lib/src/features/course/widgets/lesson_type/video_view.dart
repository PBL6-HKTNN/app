import 'package:codemy_app/src/features/course/models/entities/lesson.dart';
import 'package:codemy_app/src/core/utils/logger.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:codemy_app/src/features/course/providers/lesson_provider.dart';

class VideoView extends ConsumerStatefulWidget {
  final Lesson? lesson;
  final String? lessonId;

  const VideoView({super.key, this.lesson, this.lessonId})
    : assert(
        lesson != null || lessonId != null,
        'Either lesson or lessonId must be provided',
      );

  @override
  ConsumerState<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends ConsumerState<VideoView> {
  VideoPlayerController? _controller;
  bool _initializing = true;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  double _progress = 0.0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Video initialization will happen in build when lesson is available
  }

  @override
  void dispose() {
    _controller?.removeListener(_onVideoPositionChanged);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeVideo(String contentUrl) async {
    if (contentUrl.isEmpty) {
      setState(() {
        _errorMessage = 'Video content is not available yet.';
        _initializing = false;
      });
      return;
    }

    try {
      final uri = Uri.parse(contentUrl);
      _controller = uri.scheme == 'asset'
          ? VideoPlayerController.asset(uri.path)
          : VideoPlayerController.networkUrl(uri);

      await _controller!.initialize();
      _totalDuration = _controller!.value.duration;
      _controller!.addListener(_onVideoPositionChanged);

      setState(() {
        _initializing = false;
      });
    } catch (error) {
      Logger.error(
        'Failed to initialize video',
        tag: 'LESSON_VIDEO',
        error: error,
      );
      setState(() {
        _errorMessage = 'Failed to load video content.';
        _initializing = false;
      });
    }
  }

  void _onVideoPositionChanged() {
    if (!mounted || _controller == null || !_controller!.value.isInitialized) {
      return;
    }

    setState(() {
      _currentPosition = _controller!.value.position;
      _isPlaying = _controller!.value.isPlaying;
      final totalMillis = _totalDuration.inMilliseconds;
      _progress = totalMillis > 0
          ? (_currentPosition.inMilliseconds / totalMillis).clamp(0.0, 1.0)
          : 0.0;
    });
  }

  void _togglePlayPause() {
    if (_controller == null) return;
    if (_controller!.value.isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.lessonId != null) {
      return Consumer(
        builder: (context, ref, child) {
          final lessonAsync = ref.watch(lessonDetailProvider(widget.lessonId!));

          return lessonAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) {
              Logger.error(
                'Failed to load lesson for video',
                tag: 'VIDEO_VIEW',
                error: error,
              );
              return Center(
                child: Text(
                  'Failed to load lesson content.',
                  style: Theme.of(
                    context,
                  ).typography.small.copyWith(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              );
            },
            data: (lesson) {
              if (lesson.contentUrl == null || lesson.contentUrl!.isEmpty) {
                return const Center(child: Text('Video content not available'));
              }

              // Initialize video if not already done
              if (_controller == null && !_initializing) {
                _initializing = true;
                _initializeVideo(lesson.contentUrl!);
              }

              return _buildVideoContent();
            },
          );
        },
      );
    }

    // Fallback to direct lesson if provided
    if (widget.lesson == null) {
      return const Center(child: Text('Lesson not available'));
    }

    if (widget.lesson!.contentUrl == null ||
        widget.lesson!.contentUrl!.isEmpty) {
      return const Center(child: Text('Video content not available'));
    }

    // Initialize video if not already done
    if (_controller == null && !_initializing) {
      _initializing = true;
      _initializeVideo(widget.lesson!.contentUrl!);
    }

    return _buildVideoContent();
  }

  Widget _buildVideoContent() {
    if (_initializing) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: Theme.of(context).typography.small.copyWith(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_controller == null) {
      return const Center(child: Text('Video not available'));
    }

    return Card(
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          ),
          LinearProgressIndicator(value: _progress, minHeight: 4),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Progress: ${(_progress * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Gap(8),
                Text(
                  '${_formatDuration(_currentPosition)} / ${_formatDuration(_totalDuration)}',
                  style: const TextStyle(fontSize: 12),
                ),
                const Gap(16),
                Button(
                  style: ButtonStyle.primary(),
                  onPressed: _togglePlayPause,
                  child: Icon(_isPlaying ? RadixIcons.pause : RadixIcons.play),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
