import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../models/entities/course.dart';
import '../providers/enrollment_provider.dart';
import '../providers/wishlist_provider.dart';
import '../services/course_service.dart';
import '../widgets/course_card.dart';

enum YourCoursesTab { joined, wishlist }

class YourCoursesScreen extends ConsumerStatefulWidget {
  const YourCoursesScreen({super.key, this.initialTab = YourCoursesTab.joined});

  final YourCoursesTab initialTab;

  @override
  ConsumerState<YourCoursesScreen> createState() => _YourCoursesScreenState();
}

class _YourCoursesScreenState extends ConsumerState<YourCoursesScreen> {
  late YourCoursesTab _currentTab;
  late ScrollController _scrollController;

  // Joined courses state
  List<Course> _joinedCourses = [];
  bool _joinedLoading = false;
  bool _joinedLoadingMore = false;
  bool _joinedHasMore = true;
  int _joinedCurrentPage = 0;

  // Wishlist courses state
  List<Course> _wishlistCourses = [];
  bool _wishlistLoading = false;

  // Course service for fetching course details
  late final CourseService _courseService;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
    _scrollController = ScrollController()..addListener(_onScroll);
    _courseService = CourseService();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      if (_currentTab == YourCoursesTab.joined) {
        _loadMoreJoinedCourses();
      }
      // Wishlist doesn't have pagination
    }
  }

  void _changeTab(YourCoursesTab tab) {
    if (_currentTab == tab) return;
    setState(() => _currentTab = tab);
    _loadInitialData();
  }

  Future<void> _reloadCurrentTab() async {
    if (_currentTab == YourCoursesTab.joined) {
      await _loadJoinedCourses(isRefresh: true);
    } else {
      await _loadWishlistCourses();
    }
  }

  // Simplified - no complex filtering for now
  List<Course> get _activeCourses {
    return _currentTab == YourCoursesTab.joined
        ? _joinedCourses
        : _wishlistCourses;
  }

  bool get _activeLoading {
    return _currentTab == YourCoursesTab.joined
        ? _joinedLoading
        : _wishlistLoading;
  }

  bool get _activeLoadingMore {
    return _currentTab == YourCoursesTab.joined
        ? _joinedLoadingMore
        : false; // Wishlist doesn't have pagination
  }

  String _emptyMessage() {
    return _currentTab == YourCoursesTab.joined
        ? 'You have not joined any courses yet'
        : 'Your wishlist is empty';
  }

  Future<void> _loadInitialData() async {
    if (_currentTab == YourCoursesTab.joined) {
      await _loadJoinedCourses(isRefresh: true);
    } else {
      await _loadWishlistCourses();
    }
  }

  Future<void> _loadJoinedCourses({bool isRefresh = false}) async {
    if (_joinedLoading) return;

    setState(() {
      if (isRefresh) {
        _joinedLoading = true;
        _joinedCurrentPage = 0;
        _joinedHasMore = true;
      }
    });

    try {
      final enrollmentService = ref.read(enrollmentServiceProvider);
      final page = isRefresh ? 1 : _joinedCurrentPage + 1;
      final response = await enrollmentService.getMyCourses(
        page: page,
        pageSize: 10,
      );

      if (response.isSuccess && response.data != null) {
        final joinedCourses = response.data!;
        final courseIds = joinedCourses.map((c) => c.id).toSet().toList();

        final courseResponses = await Future.wait(
          courseIds.map((id) => _courseService.getCourseById(id)),
        );

        final courses = <Course>[];
        for (final res in courseResponses) {
          if (res.isSuccess && res.data != null) {
            courses.add(res.data!);
          }
        }

        setState(() {
          if (isRefresh) {
            _joinedCourses = courses;
          } else {
            _joinedCourses.addAll(courses);
          }
          _joinedCurrentPage = page;
          _joinedHasMore = joinedCourses.length == 10;
          _joinedLoading = false;
          _joinedLoadingMore = false;
        });
      } else {
        setState(() {
          _joinedLoading = false;
          _joinedLoadingMore = false;
        });
      }
    } catch (error) {
      setState(() {
        _joinedLoading = false;
        _joinedLoadingMore = false;
      });
    }
  }

  Future<void> _loadMoreJoinedCourses() async {
    if (!_joinedHasMore || _joinedLoadingMore) return;

    setState(() {
      _joinedLoadingMore = true;
    });

    await _loadJoinedCourses();
  }

  Future<void> _loadWishlistCourses() async {
    if (_wishlistLoading) return;

    setState(() {
      _wishlistLoading = true;
    });

    try {
      final wishlistService = ref.read(wishlistServiceProvider);
      final response = await wishlistService.getWishlist();

      if (response.isSuccess && response.data != null) {
        final wishlistedCourses = response.data!;
        final courseIds = wishlistedCourses
            .map((c) => c.courseId)
            .toSet()
            .toList();

        final courseResponses = await Future.wait(
          courseIds.map((id) => _courseService.getCourseById(id)),
        );

        final courses = <Course>[];
        for (final res in courseResponses) {
          if (res.isSuccess && res.data != null) {
            courses.add(res.data!);
          }
        }

        setState(() {
          _wishlistCourses = courses;
          _wishlistLoading = false;
        });
      } else {
        setState(() {
          _wishlistLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _wishlistLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DrawerOverlay(
      child: Container(
        color: Theme.of(context).colorScheme.background,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _activeLoading
                      ? Center(child: CircularProgressIndicator(size: 28))
                      : _activeCourses.isEmpty
                      ? _buildEmptyState(context)
                      : ListView.separated(
                          controller: _scrollController,
                          key: ValueKey(_currentTab),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount:
                              _activeCourses.length +
                              (_activeLoadingMore ? 1 : 0),
                          separatorBuilder: (_, __) => const Gap(12),
                          itemBuilder: (context, index) {
                            if (index == _activeCourses.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: CircularProgressIndicator(size: 24),
                                ),
                              );
                            }
                            return CourseCard(
                              course: _activeCourses[index],
                              isJoined: _currentTab == YourCoursesTab.joined,
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.popover,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Button.ghost(
            onPressed: () => context.go('/user'),
            child: const Icon(LucideIcons.arrowLeft),
          ),
          const Gap(12),
          Expanded(
            child: Tabs(
              index: _currentTab.index,
              onChanged: (index) => _changeTab(YourCoursesTab.values[index]),
              children: [
                TabItem(child: Text('Joined')),
                TabItem(child: Text('Wishlist')),
              ],
            ),
          ),
          const Gap(12),
          SecondaryButton(
            size: ButtonSize.small,
            onPressed: _reloadCurrentTab,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [Icon(LucideIcons.refreshCcw, size: 18)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Text(
        _emptyMessage(),
        style: Theme.of(context).typography.h4.copyWith(
          color: Theme.of(context).colorScheme.mutedForeground,
        ),
      ),
    );
  }
}
