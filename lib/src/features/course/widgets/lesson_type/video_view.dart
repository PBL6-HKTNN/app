import 'dart:async';

import 'package:codemy_app/src/core/utils/logger.dart';
import 'package:codemy_app/src/features/course/models/entities/lesson.dart';
import 'package:codemy_app/src/features/course/providers/lesson_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:video_player/video_player.dart';

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
  bool _initializing = false;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  double _progress = 0.0;
  String? _errorMessage;
  String? _currentContentUrl;

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

  @override
  void didUpdateWidget(VideoView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset video if lesson changed
    if (oldWidget.lesson?.id != widget.lesson?.id ||
        oldWidget.lessonId != widget.lessonId) {
      _resetVideo();
    }
  }

  void _resetVideo() {
    setState(() {
      _controller?.removeListener(_onVideoPositionChanged);
      _controller?.dispose();
      _controller = null;
      _initializing = false;
      _isPlaying = false;
      _currentPosition = Duration.zero;
      _totalDuration = Duration.zero;
      _progress = 0.0;
      _errorMessage = null;
      _currentContentUrl = null;
    });
  }

  Future<void> _initializeVideo(String contentUrl) async {
    setState(() {
      _initializing = true;
      _errorMessage = null;
      _currentContentUrl = contentUrl;
    });

    if (contentUrl.isEmpty) {
      setState(() {
        _errorMessage = 'Video content is not available yet.';
        _initializing = false;
      });
      return;
    }

    Logger.info('Initializing video with URL: $contentUrl', tag: 'VIDEO_VIEW');

    try {
      final uri = Uri.parse(contentUrl);
      Logger.info('Parsed URI: ${uri.scheme} - ${uri.path}', tag: 'VIDEO_VIEW');

      if (uri.scheme == 'asset') {
        _controller = VideoPlayerController.asset(uri.path);
      } else if (uri.scheme.startsWith('http')) {
        _controller = VideoPlayerController.networkUrl(uri);
      } else {
        // Handle file:// or other schemes
        _controller = VideoPlayerController.networkUrl(uri);
      }

      Logger.info('Controller created, initializing...', tag: 'VIDEO_VIEW');
      await _controller!.initialize().timeout(const Duration(seconds: 10));

      if (!_controller!.value.isInitialized) {
        throw Exception('Video controller failed to initialize');
      }

      if (!mounted) return;

      _totalDuration = _controller!.value.duration;
      Logger.info(
        'Video initialized successfully. Duration: $_totalDuration, Aspect ratio: ${_controller!.value.aspectRatio}',
        tag: 'VIDEO_VIEW',
      );

      _controller!.addListener(_onVideoPositionChanged);

      setState(() {
        _initializing = false;
      });
    } catch (error, stackTrace) {
      Logger.error(
        'Failed to initialize video',
        tag: 'LESSON_VIDEO',
        error: error,
        stackTrace: stackTrace,
      );
      setState(() {
        _errorMessage = 'Failed to load video content: $error';
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
          final contentUrl = lesson.contentUrl;
          if (contentUrl == null || contentUrl.isEmpty) {
            return const Center(child: Text('Video content not available'));
          }

          if (_controller == null && !_initializing) {
            _initializeVideo(contentUrl);
          }

          return _buildVideoContent(contentUrl);
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
      _initializeVideo(widget.lesson!.contentUrl!);
    }

    return _buildVideoContent(widget.lesson!.contentUrl!);
  }

  Widget _buildVideoContent(String contentUrl) {
    if (_initializing) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _errorMessage!,
              style: Theme.of(
                context,
              ).typography.small.copyWith(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const Gap(8),
            Text(
              'URL: ${_currentContentUrl ?? contentUrl}',
              style: Theme.of(context).typography.xSmall.copyWith(
                color: Theme.of(context).colorScheme.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: Text('Video not available'));
    }

    // Ensure aspect ratio is valid
    final aspectRatio = _controller!.value.aspectRatio;
    final validAspectRatio = aspectRatio > 0 && aspectRatio.isFinite
        ? aspectRatio
        : 16 / 9;

    Logger.info(
      'Rendering video with aspect ratio: $validAspectRatio',
      tag: 'VIDEO_VIEW',
    );

    return Card(
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: validAspectRatio,
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
