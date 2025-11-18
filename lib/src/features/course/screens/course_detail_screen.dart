import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../user/providers/auth_providers.dart';
import '../providers/course_content_provider.dart';
import '../providers/enrollment_provider.dart';
import '../providers/wishlist_provider.dart';
import '../widgets/course_content_view.dart';

class CourseDetailScreen extends ConsumerStatefulWidget {
  final String courseId;
  final String source;

  const CourseDetailScreen({
    super.key,
    required this.courseId,
    this.source = 'all',
  });

  @override
  ConsumerState<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Refresh data when screen is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(courseContentProvider(widget.courseId));
      ref.invalidate(courseEnrollmentProvider(widget.courseId));
      ref.invalidate(wishlistProvider);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Note: Provider invalidation removed from dispose to avoid unsafe ref usage
    // AutoDispose providers will clean up automatically
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Refresh data when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(courseEnrollmentProvider(widget.courseId));
      ref.invalidate(wishlistProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final contentAsync = ref.watch(courseContentProvider(widget.courseId));
    final enrollmentAsync = ref.watch(
      courseEnrollmentProvider(widget.courseId),
    );
    final wishlistAsync = ref.watch(wishlistProvider);

    return contentAsync.when(
      loading: () =>
          const Scaffold(child: Center(child: CircularProgressIndicator())),
      error: (error, _) =>
          _ErrorView(onBack: () => _goBack(context), message: error.toString()),
      data: (content) {
        final course = content.course;
        final theme = Theme.of(context);
        final authState = ref.watch(authStateProvider);
        final isGuest = !authState.isAuthenticated;
        final thumbnail = course.thumbnail;
        final modules = content.modules;

        // Check enrollment and wishlist status
        final isEnrolled = enrollmentAsync.when(
          data: (enrollment) => enrollment.success,
          loading: () => false,
          error: (_, __) => false,
        );

        final isInWishlist = wishlistAsync.when(
          data: (wishlist) =>
              wishlist.any((item) => item.courseId == widget.courseId),
          loading: () => false,
          error: (_, __) => false,
        );

        return Scaffold(
          backgroundColor: theme.colorScheme.background,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Button.ghost(
                        onPressed: () => _goBack(context),
                        child: const Icon(LucideIcons.arrowLeft, size: 24),
                      ),
                      Expanded(
                        child: Text(
                          course.title,
                          style: theme.typography.h4,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Button.ghost(
                        onPressed: () => context.go('/'),
                        child: const Icon(Icons.home_outlined, size: 24),
                      ),
                    ],
                  ),
                  const Gap(16),
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: theme.colorScheme.muted,
                    ),
                    child: thumbnail != null && thumbnail.isNotEmpty
                        ? Image.network(
                            thumbnail,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(
                                  child: Icon(LucideIcons.imageOff, size: 48),
                                ),
                          )
                        : const Center(
                            child: Icon(LucideIcons.imageOff, size: 48),
                          ),
                  ),
                  const Gap(20),
                  Text(course.title, style: theme.typography.h3),
                  const Gap(8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const Gap(4),
                      Text(_formatRating(course.averageRating)),
                      const Gap(8),
                      Text(
                        '(${course.numberOfReviews} reviews)',
                        style: TextStyle(
                          color: theme.colorScheme.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                  const Gap(16),
                  if (course.description != null)
                    Text(course.description!, style: theme.typography.small),
                  if (course.description != null) const Gap(20),
                  Wrap(
                    spacing: 16,
                    runSpacing: 6,
                    children: [
                      Chip(
                        leading: Icon(Icons.access_time),
                        child: Text(_formatDuration(course.duration)),
                      ),
                      Chip(
                        leading: Icon(LucideIcons.languages),
                        child: Text(course.language),
                      ),
                      Chip(
                        leading: Icon(Icons.monetization_on_outlined),
                        child: Text(_formatPrice(course.price)),
                      ),
                      Chip(
                        leading: Icon(LucideIcons.layers),
                        child: Text('${course.numberOfModules} modules'),
                      ),
                    ],
                  ),
                  const Gap(24),
                  if (modules.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Course Content',
                              style: theme.typography.h4.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Button.outline(
                              onPressed: () => CourseContentView.show(
                                context,
                                courseId: course.id,
                                onLessonTap: (lesson) {
                                  Navigator.of(context).pop();
                                  _handleLessonNavigate(
                                    context,
                                    course.id,
                                    lesson.moduleId,
                                    lesson.id,
                                  );
                                },
                              ),
                              child: const Text('Open as panel'),
                            ),
                          ],
                        ),
                        const Gap(12),
                        Card(
                          padding: const EdgeInsets.all(12),
                          child: CourseContentView(
                            courseId: course.id,
                            showHeader: false,
                            onLessonTap: (lesson) => _handleLessonNavigate(
                              context,
                              course.id,
                              lesson.moduleId,
                              lesson.id,
                            ),
                          ),
                        ),
                        if (kDebugMode) ...[
                          const Gap(12),
                          Button.outline(
                            onPressed: () =>
                                context.push('/learn/${course.id}'),
                            child: const Text('Open Learning (Debug)'),
                          ),
                        ],
                      ],
                    ),
                  if (modules.isNotEmpty) const Gap(24),

                  // Action buttons based on enrollment status
                  if (isEnrolled)
                    Button.primary(
                      onPressed: () =>
                          context.push('/learn/${widget.courseId}'),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.play, size: 18),
                          Gap(8),
                          Text('Continue Learning'),
                        ],
                      ),
                    )
                  else
                    Button.primary(
                      onPressed: isGuest
                          ? () => _handleEnroll(context, isGuest)
                          : () => _handleEnrollAction(context, ref),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.bookOpen, size: 18),
                          Gap(8),
                          Text('Enroll Now'),
                        ],
                      ),
                    ),

                  const Gap(12),

                  // Wishlist button
                  if (!isGuest && !isEnrolled)
                    Button.secondary(
                      onPressed: () =>
                          _handleWishlistAction(context, ref, isInWishlist),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isInWishlist
                                ? LucideIcons.heart
                                : LucideIcons.heartOff,
                            size: 18,
                          ),
                          const Gap(8),
                          Text(
                            isInWishlist
                                ? 'Remove from Wishlist'
                                : 'Add to Wishlist',
                          ),
                        ],
                      ),
                    ),

                  const Gap(12),

                  // Reviews button
                  Button.ghost(
                    onPressed: () =>
                        context.push('/course/${course.id}/reviews'),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.messageSquare, size: 20),
                        Gap(8),
                        Text('View & Add Reviews'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleEnroll(BuildContext context, bool isGuest) {
    if (!isGuest) {
      // This shouldn't be called for authenticated users
      return;
    }

    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (dialogContext) => AlertDialog(
        leading: const Icon(LucideIcons.circleAlert, size: 40),
        title: const Text(
          'You are not logged in',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: const Text(
          'Please sign in to enroll in this course and access its content.',
          textAlign: TextAlign.center,
        ),
        actions: [
          SecondaryButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          PrimaryButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.push('/login');
            },
            child: const Text('Go to Login'),
          ),
        ],
      ),
    );
  }

  void _handleEnrollAction(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(enrollCourseProvider(widget.courseId).future);
      if (context.mounted) {
        _showSuccessDialog(
          context,
          'Enrollment Successful',
          'You have successfully enrolled in this course!',
        );
        // Refresh enrollment status
        ref.invalidate(courseEnrollmentProvider(widget.courseId));
      }
    } catch (error) {
      if (context.mounted) {
        _showErrorDialog(context, 'Enrollment Failed', error.toString());
      }
    }
  }

  void _handleWishlistAction(
    BuildContext context,
    WidgetRef ref,
    bool isInWishlist,
  ) async {
    try {
      if (isInWishlist) {
        await ref.read(removeFromWishlistProvider(widget.courseId).future);
        if (context.mounted) {
          _showSuccessDialog(
            context,
            'Removed from Wishlist',
            'Course has been removed from your wishlist.',
          );
        }
      } else {
        await ref.read(addToWishlistProvider(widget.courseId).future);
        if (context.mounted) {
          _showSuccessDialog(
            context,
            'Added to Wishlist',
            'Course has been added to your wishlist.',
          );
        }
      }
      // Refresh wishlist
      ref.invalidate(wishlistProvider);
    } catch (error) {
      if (context.mounted) {
        _showErrorDialog(
          context,
          isInWishlist ? 'Remove Failed' : 'Add Failed',
          error.toString(),
        );
      }
    }
  }

  void _showSuccessDialog(BuildContext context, String title, String message) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        leading: Icon(LucideIcons.check, size: 40, color: Colors.green),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Text(message, textAlign: TextAlign.center),
        actions: [
          PrimaryButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        leading: Icon(LucideIcons.x, size: 40, color: Colors.red),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Text(message, textAlign: TextAlign.center),
        actions: [
          PrimaryButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleLessonNavigate(
    BuildContext context,
    String courseId,
    String moduleId,
    String lessonId,
  ) {
    context.push('/learn/$courseId/$moduleId/$lessonId');
  }

  void _goBack(BuildContext context) {
    context.pop();
  }

  static String _formatPrice(Decimal price) {
    final value = double.tryParse(price.toString()) ?? 0;
    return "\$${value.toStringAsFixed(2)}";
  }

  static String _formatDuration(String raw) {
    final parts = raw.split(':');
    if (parts.length == 3) {
      final hours = int.tryParse(parts[0]) ?? 0;
      final minutes = int.tryParse(parts[1]) ?? 0;
      if (hours > 0) {
        return '${hours}h ${minutes}m';
      }
      return '${minutes}m';
    }
    return raw;
  }

  static String _formatRating(double value) {
    return value.toStringAsFixed(1);
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onBack;
  final String message;

  const _ErrorView({required this.onBack, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.triangleAlert, size: 48),
              const Gap(12),
              Text('Course Not Found', style: theme.typography.h4),
              const Gap(8),
              Text(
                message,
                style: theme.typography.small,
                textAlign: TextAlign.center,
              ),
              const Gap(16),
              PrimaryButton(
                onPressed: onBack,
                child: const Text('Back to Courses'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
