import 'package:codemy_app/src/core/utils/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:codemy_app/src/features/course/providers/lesson_provider.mock.dart';

class VideoView extends ConsumerStatefulWidget {
  const VideoView({super.key});

  @override
  ConsumerState<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends ConsumerState<VideoView> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  late final LessonNotifier _lessonNotifier;

  @override
  void initState() {
    super.initState();
    _lessonNotifier = ref.read(lessonProvider.notifier);
    _initializeVideo();
  }

  @override
  void dispose() {
    _controller?.dispose();
    // Mock unmount trigger for progress saving
    _lessonNotifier.saveProgress();
    super.dispose();
  }

  Future<void> _initializeVideo() async {
    try {
      // Try local asset first
      _controller = VideoPlayerController.asset('assets/test/sample_video.mp4');
      await _controller!.initialize();
      _controller!.addListener(_onVideoPositionChanged);

      setState(() {
        _isInitialized = true;
        _totalDuration = _controller!.value.duration;
      });

      // Restore saved progress
      _restoreVideoPosition();
    } catch (e) {
      Logger.error('Local video not found, trying network video: $e');
      // Fallback to network video for demo
      try {
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
          ),
        );
        await _controller!.initialize();
        _controller!.addListener(_onVideoPositionChanged);

        setState(() {
          _isInitialized = true;
          _totalDuration = _controller!.value.duration;
        });

        _restoreVideoPosition();
      } catch (networkError) {
        Logger.error('Network video failed: $networkError');
        setState(() {
          _isInitialized = true; // Show error state
        });
      }
    }
  }

  void _onVideoPositionChanged() {
    if (_controller != null && _controller!.value.isInitialized) {
      setState(() {
        _currentPosition = _controller!.value.position;
        _isPlaying = _controller!.value.isPlaying;
      });

      // Update progress and current position in provider
      final progress = _totalDuration.inMilliseconds > 0
          ? _currentPosition.inMilliseconds / _totalDuration.inMilliseconds
          : 0.0;
      _lessonNotifier.setProgress(progress.clamp(0.0, 1.0));
      _lessonNotifier.setCurrentPosition(_currentPosition);
    }
  }

  void _restoreVideoPosition() {
    if (_controller != null && _controller!.value.isInitialized) {
      final lessonState = ref.read(lessonProvider);

      // Use currentPosition if available, otherwise fall back to progress calculation
      final targetPosition =
          lessonState.currentPosition ??
          (_totalDuration * lessonState.currentProgress);

      if (targetPosition > Duration.zero) {
        _controller!.seekTo(targetPosition);
      }
    }
  }

  void _togglePlayPause() {
    if (_controller == null) return;

    if (_isPlaying) {
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
    final lessonState = ref.watch(lessonProvider);

    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller == null) {
      return const Center(child: Text('Video not available'));
    }

    return Card(
      child: Column(
        children: [
          // Video player
          AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          ),

          // Progress bar
          LinearProgressIndicator(
            value: lessonState.currentProgress,
            minHeight: 4,
          ),

          // Controls
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Progress text
                Text(
                  'Progress: ${(lessonState.currentProgress * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Gap(8),

                // Time display
                Text(
                  '${_formatDuration(_currentPosition)} / ${_formatDuration(_totalDuration)}',
                  style: const TextStyle(fontSize: 12),
                ),
                const Gap(16),

                // Play/Pause button
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
