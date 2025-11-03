import 'package:decimal/decimal.dart';
import 'package:go_router/go_router.dart';
import '../../course/models/entities/course.dart';
import '../../course/services/course_service.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseId;
  final String source;

  const CourseDetailScreen({
    super.key,
    required this.courseId,
    this.source = 'all',
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final _service = CourseService();
  Course? _course;
  bool _loading = true;
  bool _isGuest =
      true; // Giả lập chưa đăng nhập (sau này đổi theo AuthProvider)

  @override
  void initState() {
    super.initState();
    _loadCourse();
  }

  Future<void> _loadCourse() async {
    final courses = await _service.fetchCourses(limit: 30);
    setState(() {
      _course = courses.firstWhere((c) => c.id == widget.courseId);
      _loading = false;
    });
  }

  void _handleEnroll(BuildContext context) {
    if (_isGuest) {
      showDialog(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.8),
        builder: (_) => AlertDialog(
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
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            PrimaryButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.push('/login');
              },
              child: const Text('Go to Login'),
            ),
          ],
        ),
      );
    } else {
      // Sau này thêm logic nếu user đã đăng nhập
      // showToast(context, 'Enrolled successfully!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return const Scaffold(child: Center(child: CircularProgressIndicator()));
    }

    if (_course == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.triangleAlert, size: 48),
            const Gap(12),
            const Text('Course Not Found'),
            const Gap(8),
            PrimaryButton(
              onPressed: () => _goBack(context),
              child: const Text('Back to Courses'),
            ),
          ],
        ),
      );
    }

    final course = _course!;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Button.ghost(
                    onPressed: () => _goBack(context),
                    child: const Icon(
                      LucideIcons.arrowLeft,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                  Text(course.title, style: theme.typography.h4),
                  Button.ghost(
                    onPressed: () => context.go('/'),
                    child: const Icon(
                      Icons.home_outlined,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const Gap(16),

              // Thumbnail
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: theme.colorScheme.muted,
                  image: course.thumbnail.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(course.thumbnail),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: course.thumbnail.isEmpty
                    ? const Center(child: Icon(LucideIcons.imageOff, size: 48))
                    : null,
              ),
              const Gap(20),

              // Title + rating
              Text(course.title, style: theme.typography.h3),
              const Gap(8),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const Gap(4),
                  Text('${course.averageRating}'),
                  const Gap(8),
                  Text(
                    '(${course.numReviews} reviews)',
                    style: TextStyle(color: theme.colorScheme.mutedForeground),
                  ),
                ],
              ),
              const Gap(16),

              // Description
              Text(course.description, style: theme.typography.small),
              const Gap(20),

              // Info
              Wrap(
                spacing: 16,
                runSpacing: 6,
                children: [
                  _infoRow(
                    Icons.access_time,
                    '${course.duration.inMinutes} min',
                  ),
                  _infoRow(LucideIcons.languages, course.language),
                  _infoRow(
                    Icons.monetization_on_outlined,
                    '${course.price} USD',
                  ),
                ],
              ),
              const Gap(24),

              // Modules
              Text(
                'Course Modules',
                style: theme.typography.h4.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(12),

              ...course.modules.map(
                (m) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        const Icon(Icons.menu_book_outlined),
                        const Gap(10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(m.title, style: theme.typography.small),
                              const Gap(4),
                              Text(
                                '${m.numLessons} lessons • ${m.duration.inMinutes} min',
                                style: TextStyle(
                                  color: theme.colorScheme.mutedForeground,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Gap(40),

              Button.primary(
                onPressed: () => context.push('/course/${course.id}/reviews'),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.messageSquare,
                      size: 20,
                      color: Colors.white,
                    ),
                    Gap(8),
                    Text(
                      'View & Add Reviews',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              const Gap(40),

              // Enroll button
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: Button(
                    style: ButtonStyle.primary(
                      size: ButtonSize.large,
                      shape: ButtonShape.rectangle,
                    ),
                    onPressed: () => _handleEnroll(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.school_outlined,
                          size: 20,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isGuest ? 'Enroll Now' : 'Enrolled',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20),
        const Gap(15),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  void _goBack(BuildContext context) {
    switch (widget.source) {
      case 'joined':
        context.go('/your-courses');
        break;
      case 'wishlist':
        context.go('/wishlist');
        break;
      default:
        context.go('/courses');
    }
  }
}
