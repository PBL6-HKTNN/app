// lib/widgets/review_widgets.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../models/dto/review_requests.dart';
import '../models/entities/review.dart';
import '../providers/review_provider.dart';

class ReviewItem extends StatelessWidget {
  final Review review;
  const ReviewItem({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).colorScheme.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.userId,
                  style: Theme.of(context).typography.h4,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Gap(8),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < review.rating
                        ? BootstrapIcons.starFill
                        : BootstrapIcons.star,
                    size: 16,
                    color: i < review.rating
                        ? Colors.amber
                        : Theme.of(context).colorScheme.mutedForeground,
                  ),
                ),
              ),
            ],
          ),
          const Gap(8),
          Text(
            review.comment,
            style: Theme.of(context).typography.p,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
          const Gap(8),
          Text(
            _formatDate(review.createdAt),
            style: Theme.of(context).typography.small.copyWith(
              color: Theme.of(context).colorScheme.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_monthName(date.month)} ${date.year}';
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}

class ReviewForm extends ConsumerStatefulWidget {
  final String courseId;
  final VoidCallback? onSubmitComplete;
  const ReviewForm({super.key, required this.courseId, this.onSubmitComplete});

  @override
  ConsumerState<ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends ConsumerState<ReviewForm> {
  int rating = 0;
  final commentController = TextEditingController();
  bool isSubmitting = false;

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    // Validation
    if (rating == 0) {
      _showValidationError('Please select a rating');
      return;
    }
    if (commentController.text.isEmpty) {
      _showValidationError('Please write a comment');
      return;
    }
    if (commentController.text.length < 10) {
      _showValidationError('Comment must be at least 10 characters');
      return;
    }

    setState(() => isSubmitting = true);

    try {
      // Create the review request
      final request = CreateReviewRequest(
        courseId: widget.courseId,
        rating: rating,
        comment: commentController.text,
      );

      // Submit review via provider
      await ref.read(createReviewProvider(request).future);

      if (mounted) {
        _showSuccessDialog();
        commentController.clear();
        setState(() {
          rating = 0;
          isSubmitting = false;
        });
        widget.onSubmitComplete?.call();
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString());
        setState(() => isSubmitting = false);
      }
    }
  }

  void _showValidationError(String message) {
    showToast(
      context: context,
      builder: (context, overlay) => SurfaceCard(
        child: Basic(
          title: Text(message),
          leading: Icon(LucideIcons.triangleAlert, color: Colors.red),
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Success'),
        content: const Text('Review submitted successfully!'),
        actions: [
          Button.ghost(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Error'),
        content: Text('Failed to submit review: $error'),
        actions: [
          Button.ghost(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(12),
      filled: true,
      fillColor: Theme.of(context).colorScheme.popover,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Write a Review', style: Theme.of(context).typography.h4),
          const Gap(20),
          Text('Rating', style: Theme.of(context).typography.p),
          const Gap(12),
          Row(
            children: List.generate(
              5,
              (i) => Clickable(
                onPressed: () => setState(() => rating = i + 1),
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    i < rating ? BootstrapIcons.starFill : BootstrapIcons.star,
                    size: 28,
                    color: i < rating
                        ? Colors.amber
                        : Theme.of(context).colorScheme.mutedForeground,
                  ),
                ),
              ),
            ),
          ),
          const Gap(20),
          Text('Comment', style: Theme.of(context).typography.p),
          const Gap(12),
          TextArea(
            controller: commentController,
            placeholder: const Text('Share your thoughts about this course...'),
            minHeight: 100,
            maxHeight: 200,
            borderRadius: BorderRadius.circular(8),
            padding: const EdgeInsets.all(12),
            filled: true,
          ),
          const Gap(20),
          PrimaryButton(
            onPressed: isSubmitting ? null : _handleSubmit,
            child: SizedBox(
              width: double.infinity,
              child: Center(
                child: Text(
                  isSubmitting ? 'Submitting...' : 'Submit Review',
                  style: Theme.of(context).typography.p,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
