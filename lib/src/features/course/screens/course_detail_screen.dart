import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../providers/course_provider.dart';

class CourseDetailScreen extends ConsumerWidget {
  final String courseId;

  const CourseDetailScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseAsync = ref.watch(selectedCourseProvider);
    final viewPadding = MediaQuery.of(context).viewPadding;

    return Container(
      color: Colors.slate[200],
      padding: EdgeInsets.only(
        top: viewPadding.top,
        bottom: viewPadding.bottom,
      ),
      child: courseAsync.when(
        data: (course) {
          if (course == null)
            return const Center(child: Text('Course not found'));

          return Column(
            children: [
              // Header with back button
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.cyan[200],
                  border: Border(bottom: BorderSide(color: Colors.black)),
                ),
                child: Row(
                  children: [
                    IconButton.primary(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        course.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Course content
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    // Course thumbnail
                    SliverToBoxAdapter(
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image(
                          image: NetworkImage(course.thumbnail),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    // Course info
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // Title and badge
                          Row(
                            children: [
                              SecondaryBadge(child: Text(course.category)),
                              const SizedBox(width: 8),
                              SecondaryBadge(
                                child: Text('${course.duration} total'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Title
                          Text(
                            course.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Instructor
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundImage: NetworkImage(
                                  'https://i.pravatar.cc/100',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                course.instructor,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Price and rating
                          Row(
                            children: [
                              Text(
                                '\$${course.price}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.yellow[600],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    course.rating.toString(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Description
                          const Text(
                            'About this course',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            course.description,
                            style: TextStyle(color: Colors.black, height: 1.5),
                          ),

                          // Progress if enrolled
                          if (course.isEnrolled) ...[
                            const SizedBox(height: 24),
                            const Text(
                              'Your Progress',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: course.progress / 100,
                              backgroundColor: Colors.accent.withOpacity(0.2),
                              valueColor: AlwaysStoppedAnimation(
                                ShadColor.accent,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${course.progress.toInt()}% Complete',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ]),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom CTA
              if (!course.isEnrolled)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ShadColor.card,
                    border: Border(top: BorderSide(color: ShadColor.border)),
                    boxShadow: [
                      BoxShadow(
                        color: ShadColor.shadow.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        '\$${course.price}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Button(
                          onPressed: () {
                            // Handle enrollment
                          },
                          child: const Text('Enroll Now'),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Alert(
            type: ShadAlertType.destructive,
            content: Text(error.toString()),
          ),
        ),
      ),
    );
  }
}
