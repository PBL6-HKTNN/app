import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/course_provider.dart';
import '../providers/category_provider.dart';
import '../widgets/course_card.dart';
import '../widgets/filter_bar.dart';
import '../services/course_service.dart';

class CourseListScreen extends ConsumerStatefulWidget {
  const CourseListScreen({super.key});

  @override
  ConsumerState<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends ConsumerState<CourseListScreen> {
  bool _isSidebarOpen = false;

  void _toggleSidebar() {
    setState(() => _isSidebarOpen = !_isSidebarOpen);
  }

  // @override
  // void initState() {
  //   super.initState();
  //   Future.microtask(() {
  //     ref.read(courseNotifierProvider.notifier).load(type: CourseListType.all);
  //   });
  // }

  // @override
  // void dispose() {
  //   ref.invalidate(courseNotifierProvider);
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(allCoursesProvider);
    final notifier = ref.read(allCoursesProvider.notifier);
    final courses = notifier.filtered;
    final categoriesAsync = ref.watch(categoriesProvider);

    return DrawerOverlay(
      child: Stack(
        children: [
          // 🧱 MAIN CONTENT
          Container(
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
                        // 🍔 Menu button
                        Button.ghost(
                          onPressed: _toggleSidebar,
                          child: const Icon(
                            LucideIcons.menu,
                            color: Colors.black,
                            size: 24,
                          ),
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
                          onPressed: () => notifier.load(
                            limit: 20,
                            type: CourseListType.all,
                          ),
                          child: const Row(
                            children: [
                              Icon(LucideIcons.refreshCcw, size: 18),
                              Gap(6),
                              Text('Reload'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 🔍 FILTER BAR
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Card(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.card,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      surfaceBlur: 0,
                      surfaceOpacity: 1.0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: categoriesAsync.when(
                          data: (categories) => FilterBar(
                            onSearch: (q) {
                              notifier.applyFilter(
                                state.filter.copyWith(query: q),
                              );
                            },
                            selectedCategoryId: state.filter.category,
                            categories: categories
                                .map(
                                  (category) => FilterCategoryOption(
                                    id: category.id,
                                    label: category.name,
                                  ),
                                )
                                .toList(),
                            onCategorySelected: (categoryId) async {
                              if (categoryId == null) {
                                await notifier.load(
                                  limit: 20,
                                  type: CourseListType.all,
                                );
                                notifier.applyFilter(
                                  state.filter.copyWith(category: null),
                                );
                              } else {
                                notifier.applyFilter(
                                  state.filter.copyWith(category: categoryId),
                                );
                              }
                            },
                          ),
                          loading: () => const Center(
                            child: CircularProgressIndicator(size: 20),
                          ),
                          error: (error, _) => Text(
                            error.toString(),
                            style: Theme.of(
                              context,
                            ).typography.small.copyWith(color: Colors.red),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 📚 COURSE LIST
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: state.loading
                          ? const Center(
                              child: CircularProgressIndicator(size: 28),
                            )
                          : courses.isEmpty
                          ? Center(
                              child: Text(
                                'No courses found',
                                style: Theme.of(
                                  context,
                                ).typography.h4.copyWith(color: Colors.gray),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              itemCount: courses.length,
                              separatorBuilder: (_, __) => const Gap(12),
                              itemBuilder: (context, index) {
                                return CourseCard(course: courses[index]);
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 🟪 OVERLAY (chỉ hiển thị khi sidebar mở)
          if (_isSidebarOpen)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _toggleSidebar,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
            ),

          // 🧱 SIDEBAR
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: _isSidebarOpen ? 0 : -240,
            top: 0,
            bottom: 0,
            child: Container(
              width: 240,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.popover,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(2, 0),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Menu",
                        style: Theme.of(
                          context,
                        ).typography.h4.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Gap(20),
                    _buildSidebarButton(
                      icon: Icons.home,
                      label: "Home",
                      onTap: () {
                        context.go('/');
                        _toggleSidebar();
                      },
                    ),
                    _buildSidebarButton(
                      icon: LucideIcons.graduationCap,
                      label: "Joined Courses",
                      onTap: () {
                        context.go('/your-courses');
                        _toggleSidebar();
                      },
                    ),
                    _buildSidebarButton(
                      icon: LucideIcons.heart,
                      label: "Wishlist",
                      onTap: () {
                        context.go('/wishlist');
                        _toggleSidebar();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // SIDEBAR BUTTON
  Widget _buildSidebarButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Button.ghost(
        style: const ButtonStyle.ghost(size: ButtonSize.large),
        onPressed: onTap,
        child: Row(
          children: [
            Icon(icon, size: 18),
            const Gap(10),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Colors.black.withOpacity(0.85),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
