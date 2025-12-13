import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'filter_bar.dart';

class FilterSheet extends StatelessWidget {
  final String initialQuery;
  final String? initialCategoryId;
  final List<FilterCategoryOption> categories;
  final void Function(String query, String? categoryId) onApply;

  const FilterSheet({
    super.key,
    required this.initialQuery,
    this.initialCategoryId,
    required this.categories,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final controller = FormController();

    return Container(
      padding: const EdgeInsets.all(24),
      constraints: const BoxConstraints(maxWidth: 400),
      child: Form(
        controller: controller,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text('Filter Courses').large().medium()),
                TextButton(
                  density: ButtonDensity.icon,
                  child: const Icon(Icons.close),
                  onPressed: () => closeSheet(context),
                ),
              ],
            ),
            const Gap(8),
            Text('Filter courses by search and category.').muted(),
            const Gap(16),
            FormTableLayout(
              rows: [
                FormField<String>(
                  key: const FormKey(#query),
                  label: const Text('Search'),
                  child: TextField(
                    initialValue: initialQuery,
                    placeholder: const Text('Search courses...'),
                  ),
                ),
                FormField<String>(
                  key: const FormKey(#category),
                  label: const Text('Category'),
                  child: Select<String>(
                    value: initialCategoryId ?? '__all__',
                    itemBuilder: (context, value) {
                      if (value == '__all__') return const Text('All');
                      final cat = categories.firstWhere(
                        (c) => c.id == value,
                        orElse: () =>
                            FilterCategoryOption(id: value, label: value),
                      );
                      return Text(cat.label);
                    },
                    popup: SelectPopup(
                      items: SelectItemList(
                        children: [
                          const SelectItemButton(
                            value: '__all__',
                            child: Text('All'),
                          ),
                          ...categories.map(
                            (cat) => SelectItemButton(
                              value: cat.id,
                              child: Text(cat.label),
                            ),
                          ),
                        ],
                      ),
                    ).call,
                  ),
                ),
              ],
            ),
            const Gap(16),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: PrimaryButton(
                onPressed: () {
                  final values = controller.values;
                  final query = values[const FormKey(#query)] as String? ?? '';
                  final categoryValue =
                      values[const FormKey(#category)] as String?;
                  final categoryId = categoryValue == '__all__'
                      ? null
                      : categoryValue;
                  onApply(query, categoryId);
                  closeSheet(context);
                },
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
