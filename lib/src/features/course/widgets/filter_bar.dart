import 'dart:async';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter/widgets.dart';

class FilterBar extends StatefulWidget {
  final void Function(String query) onSearch;
  final void Function(String? category) onCategorySelected;
  final String? selectedCategory;

  const FilterBar({
    super.key,
    required this.onSearch,
    required this.onCategorySelected,
    this.selectedCategory,
  });

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  final _ctrl = TextEditingController();
  Timer? _debounce;
  final categories = ['Flutter', 'AI', 'Web', 'DevOps', 'Design', 'All'];
  String? selected;

  @override
  void initState() {
    super.initState();
    selected = widget.selectedCategory ?? 'All';
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

  @override
  Widget build(BuildContext context) {
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
                value: selected,
                itemBuilder: (context, value) => Text(value),
                popupWidthConstraint: PopoverConstraint.anchorFixedSize,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selected = value);
                    widget.onCategorySelected(value == 'All' ? 'All' : value);
                  }
                },
                popup: SelectPopup(
                  items: SelectItemList(
                    children: categories
                        .map(
                          (cat) =>
                              SelectItemButton(value: cat, child: Text(cat)),
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
