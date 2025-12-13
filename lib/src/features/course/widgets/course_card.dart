import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../payment/widgets/add_to_cart_button.dart';
import '../models/entities/course.dart';
import '../models/entities/module.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final bool isJoined;
  const CourseCard({super.key, required this.course, this.isJoined = false});

  @override
  Widget build(BuildContext context) {
    final modules = course.modules ?? <Module>[];
    final moduleCount = modules.isEmpty
        ? course.numberOfModules
        : modules.length;
    final description = course.description ?? 'No description provided yet.';

    return Card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          Container(
            width: double.infinity,
            height: 120,
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
                      width: double.infinity,
                      height: 120,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Text(
                          _getShortTitle(course.title),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.background,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
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
                        fontSize: 16,
                      ),
                    ),
                  ),
          ),

          const Gap(12),

          // Course content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course title
              Text(
                course.title,
                style: Theme.of(context).typography.h4,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const Gap(8),

              // Description
              Text(
                description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.mutedForeground,
                ),
              ),

              const Gap(12),

              // Info rows
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _infoRow(icon: LucideIcons.clock, label: course.duration),
                  _infoRow(
                    icon: LucideIcons.bookOpen,
                    label: '$moduleCount modules',
                  ),
                ],
              ),

              const Gap(16),

              // Price and buttons
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '\$${course.price.toString()}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.foreground,
                      ),
                    ),
                  ),
                  // Buttons
                  OutlineButton(
                    size: ButtonSize.small,
                    onPressed: () {
                      context.push('/courses/${course.id}');
                    },
                    child: const Text('View'),
                  ),
                  const Gap(8),
                  if (isJoined)
                    PrimaryButton(
                      size: ButtonSize.small,
                      onPressed: () {
                        context.push('/learn/${course.id}');
                      },
                      child: const Text('Learn'),
                    )
                  else
                    AddToCartButton(
                      courseId: course.id,
                      size: ButtonSize.small,
                      showText: false,
                    ),
                ],
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
