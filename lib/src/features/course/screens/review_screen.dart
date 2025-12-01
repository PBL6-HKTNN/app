// lib/screens/review_screen.dart
import 'package:flutter/material.dart' as material;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../utils/safe_pop.dart';
import '../providers/review_provider.dart';
import '../widgets/review_widgets.dart';

class ReviewScreen extends StatefulWidget {
  final String courseId;
  final bool enrolled;

  const ReviewScreen({super.key, required this.courseId, this.enrolled = true});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final reviewsAsync = ref.watch(
          reviewsByCourseProvider(widget.courseId),
        );
        final averageRatingAsync = ref.watch(
          averageRatingProvider(widget.courseId),
        );

        return PopScope(
          onPopInvoked: (didPop) {
            if (!didPop) {
              safePop(context);
            }
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
                          onPressed: () => safePop(context),
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
                    Expanded(
                      child: Column(
                        children: [
                          // Average Rating Section
                          averageRatingAsync.when(
                            data: (rating) => Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.border,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Average Rating',
                                    style: Theme.of(context).typography.small,
                                  ),
                                  const Gap(8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        rating == 0.0
                                            ? 'No ratings yet'
                                            : rating.toStringAsFixed(1),
                                        style: Theme.of(context).typography.h2,
                                      ),
                                      if (rating > 0.0) ...[
                                        const Gap(8),
                                        Row(
                                          children: List.generate(
                                            5,
                                            (i) => Icon(
                                              i < rating.toInt()
                                                  ? BootstrapIcons.starFill
                                                  : BootstrapIcons.star,
                                              size: 16,
                                              color: i < rating.toInt()
                                                  ? Colors.amber
                                                  : Colors.gray,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            loading: () =>
                                const CircularProgressIndicator(size: 24),
                            error: (_, __) => Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.border,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Average Rating',
                                    style: Theme.of(context).typography.small,
                                  ),
                                  const Gap(8),
                                  Text(
                                    'Unable to load rating',
                                    style: Theme.of(
                                      context,
                                    ).typography.p.copyWith(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Gap(16),
                          // Reviews List
                          Expanded(
                            child: reviewsAsync.when(
                              data: (reviews) {
                                if (reviews.isEmpty) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          LucideIcons.messageSquare,
                                          size: 48,
                                          color: material.Colors.grey,
                                        ),
                                        const Gap(16),
                                        Text(
                                          'No reviews yet',
                                          style: Theme.of(
                                            context,
                                          ).typography.h3,
                                        ),
                                        const Gap(8),
                                        Text(
                                          'Be the first to review this course!',
                                          style: Theme.of(context).typography.p
                                              .copyWith(
                                                color: Colors.amber.shade700,
                                              ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return ListView.separated(
                                  itemCount: reviews.length,
                                  separatorBuilder: (_, __) => const Gap(12),
                                  itemBuilder: (context, i) =>
                                      ReviewItem(review: reviews[i]),
                                );
                              },
                              loading: () => const Center(
                                child: CircularProgressIndicator(size: 28),
                              ),
                              error: (e, _) => Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      LucideIcons.x,
                                      size: 48,
                                      color: Colors.red,
                                    ),
                                    const Gap(16),
                                    Text(
                                      'Failed to load reviews',
                                      style: Theme.of(context).typography.h3,
                                    ),
                                    const Gap(8),
                                    Text(
                                      'Please try again later',
                                      style: Theme.of(context).typography.p
                                          .copyWith(
                                            color: Colors.amber.shade700,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const Gap(16),
                                    PrimaryButton(
                                      onPressed: () {
                                        // Refresh the reviews
                                        ref.invalidate(
                                          reviewsByCourseProvider(
                                            widget.courseId,
                                          ),
                                        );
                                      },
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(16),
                    PrimaryButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text('Write a Review'),
                            content: ReviewForm(
                              courseId: widget.courseId,
                              onSubmitComplete: () {
                                Navigator.of(dialogContext).pop();
                                // Refresh reviews and rating after submission
                                ref.invalidate(
                                  reviewsByCourseProvider(widget.courseId),
                                );
                                ref.invalidate(
                                  averageRatingProvider(widget.courseId),
                                );
                              },
                            ),
                          ),
                        );
                      },
                      child: const Text('Write a Review'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
