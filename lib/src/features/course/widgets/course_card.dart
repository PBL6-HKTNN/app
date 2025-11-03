import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../models/entities/course.dart';
import 'package:go_router/go_router.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  const CourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final totalLessons = course.modules.fold<int>(
      0,
      (sum, mod) => sum + mod.numLessons,
    );

    return Card(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          Container(
            width: 90,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.muted,
            ),
            child: Center(
              child: Text(
                _getShortTitle(course.title),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.background,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const Gap(12),

          // Nội dung khóa học
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên khóa học
                Text(
                  course.title,
                  style: Theme.of(context).typography.h4,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const Gap(4),

                // Mô tả
                Text(
                  course.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.mutedForeground,
                  ),
                ),

                const Gap(10),

                // Thông tin phụ (duration, modules)
                Wrap(
                  spacing: 16,
                  runSpacing: 6,
                  children: [
                    _infoRow(
                      icon: LucideIcons.clock,
                      label: _formatDuration(course.duration),
                    ),
                    _infoRow(
                      icon: LucideIcons.bookOpen,
                      label:
                          '${course.modules.length} modules, $totalLessons lessons',
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Gap(12),

          // Giá + nút
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${course.price.toString()}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.foreground,
                ),
              ),
              const Gap(8),
              PrimaryButton(
                size: ButtonSize.small,
                onPressed: () {
                  String source = 'all';
                  final route = GoRouterState.of(context).uri.path;
                  if (route.contains('your-courses'))
                    source = 'joined';
                  else if (route.contains('wishlist'))
                    source = 'wishlist';

                  context.push('/courses/${course.id}?source=$source');
                },
                child: const Text('View'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow({required IconData icon, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14),
        const Gap(4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _getShortTitle(String title) {
    final words = title.split(' ');
    if (words.length > 1) {
      return '${words[0]}\n${words[1]}';
    }
    return title;
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final mins = d.inMinutes % 60;
    if (hours > 0) return '${hours}h ${mins}m';
    return '${mins}m';
  }
}
