import 'dart:async';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter/widgets.dart';

class FilterCategoryOption {
  final String id;
  final String label;

  const FilterCategoryOption({required this.id, required this.label});
}

class FilterBar extends StatefulWidget {
  final void Function(String query) onSearch;
  final void Function(String? categoryId) onCategorySelected;
  final String? selectedCategoryId;
  final List<FilterCategoryOption> categories;

  const FilterBar({
    super.key,
    required this.onSearch,
    required this.onCategorySelected,
    this.selectedCategoryId,
    this.categories = const <FilterCategoryOption>[],
  });

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  final _ctrl = TextEditingController();
  Timer? _debounce;
  String? selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.selectedCategoryId ?? _defaultCategoryId;
  }

  @override
  void didUpdateWidget(covariant FilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newDefault = widget.selectedCategoryId ?? _defaultCategoryId;
    if (selectedValue != newDefault) {
      setState(() {
        selectedValue = newDefault;
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      widget.onSearch(v.trim());
    });
  }

  static const _allSentinel = '__all__';

  String get _defaultCategoryId {
    if (widget.categories.isEmpty) {
      return _allSentinel;
    }
    return widget.categories.first.id;
  }

  List<FilterCategoryOption> get _categoriesWithAll {
    if (widget.categories.any((option) => option.id == _allSentinel)) {
      return widget.categories;
    }
    return [
      const FilterCategoryOption(id: _allSentinel, label: 'All'),
      ...widget.categories,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final categories = _categoriesWithAll;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🔍 Thanh tìm kiếm
            TextField(
              controller: _ctrl,
              hintText: 'Search courses...',
              features: [
                InputFeature.leading(const Icon(LucideIcons.search, size: 18)),
              ],
              onChanged: _onSearchChanged,
              onSubmitted: (v) => widget.onSearch(v.trim()),
            ),

            const Gap(12),

            // 🔽 Menu xổ xuống chọn bộ lọc
            SizedBox(
              width: 200,
              child: Select<String>(
                value: selectedValue,
                itemBuilder: (context, value) {
                  final option = categories.firstWhere(
                    (element) => element.id == value,
                    orElse: () => FilterCategoryOption(id: value, label: value),
                  );
                  return Text(option.label);
                },
                popupWidthConstraint: PopoverConstraint.anchorFixedSize,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedValue = value);
                    widget.onCategorySelected(
                      value == _allSentinel ? null : value,
                    );
                  }
                },
                popup: SelectPopup(
                  items: SelectItemList(
                    children: categories
                        .map(
                          (cat) => SelectItemButton(
                            value: cat.id,
                            child: Text(cat.label),
                          ),
                        )
                        .toList(),
                  ),
                ).call,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
