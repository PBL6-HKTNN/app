// lib/widgets/review_widgets.dart
import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../models/entities/review.dart';

class ReviewItem extends StatelessWidget {
  final Review review;
  const ReviewItem({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Card(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(16),
      filled: true,
      fillColor: Theme.of(context).colorScheme.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(review.userName, style: Theme.of(context).typography.h4),
              const Spacer(),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < review.rating
                        ? BootstrapIcons.starFill
                        : BootstrapIcons.star,
                    size: 16,
                    color: i < review.rating ? Colors.amber : Colors.gray,
                  ),
                ),
              ),
            ],
          ),
          const Gap(8),
          Text(review.comment, style: Theme.of(context).typography.p),
          const Gap(6),
          Text(
            '${review.date.day}/${review.date.month}/${review.date.year}',
            style: Theme.of(
              context,
            ).typography.small.copyWith(color: Colors.gray),
          ),
        ],
      ),
    );
  }
}

class ReviewForm extends StatefulWidget {
  final Function(int, String) onSubmit;
  const ReviewForm({super.key, required this.onSubmit});

  @override
  State<ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
  int rating = 0;
  final commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Card(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(16),
      filled: true,
      fillColor: Theme.of(context).colorScheme.popover,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Review', style: Theme.of(context).typography.h4),
          const Gap(12),
          Row(
            children: List.generate(
              5,
              (i) => GestureDetector(
                onTap: () => setState(() => rating = i + 1),
                child: Icon(
                  i < rating ? BootstrapIcons.starFill : BootstrapIcons.star,
                  size: 28,
                  color: i < rating ? Colors.amber : Colors.gray,
                ),
              ),
            ),
          ),
          const Gap(12),
          TextArea(
            controller: commentController,
            placeholder: const Text('Write your comment...'),
            minHeight: 100,
            maxHeight: 200,
            borderRadius: BorderRadius.circular(12),
            padding: const EdgeInsets.all(12),
            filled: true,
            style: Theme.of(context).typography.p,
            onChanged: (value) {},
          ),
          const Gap(12),
          PrimaryButton(
            onPressed: () {
              if (rating > 0 && commentController.text.isNotEmpty) {
                widget.onSubmit(rating, commentController.text);
                commentController.clear();
                setState(() => rating = 0);
              }
            },
            child: const Text('Submit Review'),
          ),
        ],
      ),
    );
  }
}
