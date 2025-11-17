// lib/screens/review_screen.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../providers/review_provider.dart';
import '../widgets/review_widgets.dart';
import '../models/entities/review.dart';
import 'package:go_router/go_router.dart';

class ReviewScreen extends ConsumerWidget {
  final String courseId;
  final bool enrolled;

  const ReviewScreen({
    super.key,
    required this.courseId,
    this.enrolled = true, // tạm thời giả sử đã enroll
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reviewProvider(courseId));
    final notifier = ref.read(reviewProvider(courseId).notifier);

    return WillPopScope(
      onWillPop: () async {
        context.pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Button.ghost(
                      onPressed: () => context.pop(),
                      child: const Icon(LucideIcons.arrowLeft, size: 20),
                    ),
                    const Spacer(),
                    Text(
                      'Course Reviews',
                      style: Theme.of(context).typography.h3,
                    ),
                    const Spacer(),
                    const SizedBox(width: 40),
                  ],
                ),
                const Gap(16),
                if (enrolled)
                  ReviewForm(
                    onSubmit: (rating, comment) async {
                      final review = Review(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        userName: 'You',
                        rating: rating,
                        comment: comment,
                        date: DateTime.now(),
                      );
                      await notifier.submitReview(review);
                    },
                  ),
                const Gap(16),
                Expanded(
                  child: state.when(
                    data: (reviews) => ListView.separated(
                      itemCount: reviews.length,
                      separatorBuilder: (_, __) => const Gap(12),
                      itemBuilder: (context, i) =>
                          ReviewItem(review: reviews[i]),
                    ),
                    loading: () => const Center(
                      child: CircularProgressIndicator(size: 28),
                    ),
                    error: (e, _) =>
                        Center(child: Text('Error loading reviews: $e')),
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
