import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../widgets/course_card.dart';
import '../widgets/course_filter_bar.dart';
import '../providers/course_provider.dart';

class CourseListScreen extends ConsumerWidget {
  const CourseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(filteredCoursesProvider);
    final viewPadding = MediaQuery.of(context).viewPadding;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          color: Colors.gray,
          padding: EdgeInsets.only(
            top: viewPadding.top,
            bottom: viewPadding.bottom,
          ),
          child: Column(
            children: [
              const CourseFilterBar(),
              Expanded(
                child: coursesAsync.when(
                  data: (courses) => CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: constraints.maxWidth > 600
                                    ? 3
                                    : 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 0.75,
                                mainAxisExtent: 320,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            if (index >= courses.length) {
                              ref.read(coursesProvider.notifier).loadMore();
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            return CourseCard(course: courses[index]);
                          }, childCount: courses.length + 1),
                        ),
                      ),
                    ],
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Alert(
                      title: Text('Error'),
                      content: Text(error.toString()),
                      trailing: Icon(Icons.dangerous_outlined),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
