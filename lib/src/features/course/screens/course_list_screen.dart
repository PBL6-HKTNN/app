import 'package:codemy_app/src/presentation/layouts/main_navigation_bar.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../utils/safe_pop.dart';
import '../models/dto/course_requests.dart';
import '../models/dto/enrollment_responses.dart';
import '../models/entities/course.dart';
import '../providers/category_provider.dart';
import '../providers/course_provider.dart';
import '../providers/enrollment_provider.dart';
import '../widgets/course_card.dart';
import '../widgets/filter_bar.dart';
import '../widgets/filter_sheet.dart';

class CourseListScreen extends ConsumerStatefulWidget {
  const CourseListScreen({super.key});

  @override
  ConsumerState<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends ConsumerState<CourseListScreen> {
  List<Course> _allCourses = [];
  bool _loading = false;
  CourseFilter _filter = const CourseFilter();

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() => _loading = true);
    try {
      final service = ref.read(courseServiceProvider);
      final params = CourseQueryParams(
        pageSize: 100,
      ); // Load more for filtering
      final response = await service.getCourses(queryParams: params);
      if (response.isSuccess && response.data != null) {
        setState(() => _allCourses = response.data!);
      }
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _loading = false);
    }
  }

  bool _isCourseJoined(Course course, List<JoinedCourse>? enrolledCourses) {
    if (enrolledCourses == null) return false;
    return enrolledCourses.any(
      (enrolledCourse) => enrolledCourse.id == course.id,
    );
  }

  List<Course> get _filteredCourses {
    return _allCourses.where((course) {
      final matchesQuery =
          _filter.query.isEmpty ||
          course.title.toLowerCase().contains(_filter.query.toLowerCase());
      final matchesCategory =
          _filter.category == null || course.categoryId == _filter.category;
      return matchesQuery && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final enrolledCoursesAsync = ref.watch(enrolledCoursesProvider);

    return MainNavigationBar(
      child: DrawerOverlay(
        child: Container(
          color: Theme.of(context).colorScheme.background,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 HEADER
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.popover,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Button.ghost(
                        onPressed: () => safePop(context),
                        child: const Icon(LucideIcons.arrowLeft),
                      ),
                      const Spacer(),
                      Text(
                        'Courses',
                        style: Theme.of(
                          context,
                        ).typography.h4.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      SecondaryButton(
                        size: ButtonSize.small,
                        onPressed: () {
                          openSheet(
                            context: context,
                            builder: (context) => FilterSheet(
                              initialQuery: _filter.query,
                              initialCategoryId: _filter.category,
                              categories: (categoriesAsync.value ?? [])
                                  .map(
                                    (category) => FilterCategoryOption(
                                      id: category.id,
                                      label: category.name,
                                    ),
                                  )
                                  .toList(),
                              onApply: (query, categoryId) {
                                setState(
                                  () => _filter = CourseFilter(
                                    query: query,
                                    category: categoryId,
                                  ),
                                );
                              },
                            ),
                            position: OverlayPosition.end,
                          );
                        },
                        child: const Row(
                          children: [Icon(LucideIcons.filter, size: 18)],
                        ),
                      ),
                      const Gap(12),
                      SecondaryButton(
                        size: ButtonSize.small,
                        onPressed: _loadCourses,
                        child: const Row(
                          children: [Icon(LucideIcons.refreshCcw, size: 18)],
                        ),
                      ),
                    ],
                  ),
                ),

                // 📚 COURSE LIST
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _loading
                        ? const Center(
                            child: CircularProgressIndicator(size: 28),
                          )
                        : _filteredCourses.isEmpty
                        ? Center(
                            child: Text(
                              'No courses found',
                              style: Theme.of(
                                context,
                              ).typography.h4.copyWith(color: Colors.gray),
                            ),
                          )
                        : material.RefreshIndicator(
                            onRefresh: _loadCourses,
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              itemCount: _filteredCourses.length,
                              separatorBuilder: (_, __) => const Gap(12),
                              itemBuilder: (context, index) {
                                final course = _filteredCourses[index];
                                final enrolledCourses =
                                    enrolledCoursesAsync.value;
                                final isJoined = _isCourseJoined(
                                  course,
                                  enrolledCourses,
                                );
                                return CourseCard(
                                  course: course,
                                  isJoined: isJoined,
                                );
                              },
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
