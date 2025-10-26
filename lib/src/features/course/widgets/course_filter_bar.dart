import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../providers/course_provider.dart';

class CourseFilterBar extends ConsumerWidget {
  const CourseFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[300],
        border: Border(
          bottom: BorderSide(color: Colors.black),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Category Filter
          Row(
            children: [
              const Text(
                'Courses',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Select<String>(
                value: selectedCategory,
                onChanged: (value) {
                  ref.read(selectedCategoryProvider.notifier).state = value;
                },
                itemBuilder: (context, value) {
                  return Text(value ?? 'All Categories');
                },
                popup: (context) => SelectPopup(
                  items: Future.value(
                    SelectItemList(
                      children: [
                        SelectItemButton(
                          value: null,
                          child: const Text('All Categories'),
                        ),
                        SelectItemButton(
                          value: 'Development',
                          child: const Text('Development'),
                        ),
                        SelectItemButton(
                          value: 'Design', 
                          child: const Text('Design'),
                        ),
                        SelectItemButton(
                          value: 'Business',
                          child: const Text('Business'),
                        ),
                      ],
                    ),
                  ),
                ),
                placeholder: const Text('Select Category'),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Search Bar
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.stone[300],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(
                    Icons.search,
                    size: 20,
                    color: Colors.black,
                  ),
                ),
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      ref.read(searchQueryProvider.notifier).state = value;
                    },
                    placeholder: const Text('Search courses...'),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                if (searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      ref.read(searchQueryProvider.notifier).state = '';
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(
                        Icons.close,
                        size: 20,
                        color: Colors.stone[800],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}