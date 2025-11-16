import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../models/entities/course.dart';
import '../models/entities/module.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final bool isJoined;
  const CourseCard({super.key, required this.course, this.isJoined = false});

  @override
  Widget build(BuildContext context) {
    final modules = course.modules ?? <Module>[];
    final totalLessons = modules.fold<int>(
      0,
      (sum, mod) => sum + (mod.numberOfLessons),
    );
    final moduleCount = modules.isEmpty
        ? course.numberOfModules
        : modules.length;
    final description = course.description ?? 'No description provided yet.';

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
            child: course.thumbnail != null && course.thumbnail!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      course.thumbnail!,
                      fit: BoxFit.cover,
                      width: 90,
                      height: 64,
                      errorBuilder: (context, error, stackTrace) => Center(
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
                  )
                : Center(
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
                  description,
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
                    _infoRow(icon: LucideIcons.clock, label: course.duration),
                    _infoRow(
                      icon: LucideIcons.bookOpen,
                      label: '$moduleCount modules, $totalLessons lessons',
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
                  if (isJoined) {
                    context.push('/learn/${course.id}');
                  } else {
                    String source = 'all';
                    final route = GoRouterState.of(context).uri.path;
                    if (route.contains('wishlist')) {
                      source = 'wishlist';
                    }
                    context.push('/courses/${course.id}?source=$source');
                  }
                },
                child: Text(isJoined ? 'Learn' : 'View'),
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
}
