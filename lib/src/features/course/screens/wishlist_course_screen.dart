import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:go_router/go_router.dart';
import '../providers/course_provider.dart';
import '../../course/widgets/filter_bar.dart';
import '../../course/widgets/course_card.dart';
import '../services/course_service.dart';

class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen> {
  bool _isSidebarOpen = false;

  void _toggleSidebar() {
    setState(() => _isSidebarOpen = !_isSidebarOpen);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(wishlistCoursesProvider);
    final notifier = ref.read(wishlistCoursesProvider.notifier);
    final courses = notifier.filtered;

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
                          'Wishlist',
                          style: Theme.of(
                            context,
                          ).typography.h4.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        SecondaryButton(
                          size: ButtonSize.small,
                          onPressed: () =>
                              notifier.load(type: CourseListType.wishlist),
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
                        child: FilterBar(
                          onSearch: (q) {
                            notifier.applyFilter(
                              notifier.state.filter.copyWith(query: q),
                            );
                          },
                          selectedCategory: notifier.state.filter.category,
                          onCategorySelected: (cat) async {
                            if (cat == null || cat.toLowerCase() == 'all') {
                              await notifier.load(
                                type: CourseListType.wishlist,
                              );
                              notifier.applyFilter(
                                notifier.state.filter.copyWith(category: 'All'),
                              );
                            } else {
                              notifier.applyFilter(
                                notifier.state.filter.copyWith(category: cat),
                              );
                            }
                          },
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
                      icon: LucideIcons.library,
                      label: "All Courses",
                      onTap: () {
                        context.go('/courses');
                        _toggleSidebar();
                      },
                    ),
                    _buildSidebarButton(
                      icon: LucideIcons.heart,
                      label: "Joined Courses",
                      onTap: () {
                        context.go('/your-courses');
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
