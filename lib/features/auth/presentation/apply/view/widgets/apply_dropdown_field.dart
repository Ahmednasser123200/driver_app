import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import 'package:driver_app/core/themes/app_colors/app_colors.dart';

class ApplyDropdownItem<T> {
  final T value;
  final String label;
  final String? fieldText;
  final Widget? leading;

  const ApplyDropdownItem({
    required this.value,
    required this.label,
    this.fieldText,
    this.leading,
  });
}

class ApplyDropdownField<T> extends StatefulWidget {
  final String label;
  final String hint;
  final List<ApplyDropdownItem<T>> items;
  final ValueNotifier<T> valueNotifier;
  final bool searchable;

  const ApplyDropdownField({
    super.key,
    required this.label,
    required this.hint,
    required this.items,
    required this.valueNotifier,
    this.searchable = true,
  });

  @override
  State<ApplyDropdownField<T>> createState() => _ApplyDropdownFieldState<T>();
}

class _ApplyDropdownFieldState<T> extends State<ApplyDropdownField<T>> {
  late final TextEditingController _controller;
  final LayerLink _layerLink = LayerLink();
  late final ValueNotifier<List<ApplyDropdownItem<T>>> _filteredItemsNotifier;
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: _getFieldTextForValue(widget.valueNotifier.value),
    );
    _filteredItemsNotifier = ValueNotifier<List<ApplyDropdownItem<T>>>(
      widget.items,
    );
    widget.valueNotifier.addListener(_onValueChanged);
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant ApplyDropdownField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _filterItems(_controller.text);
    }
  }

  @override
  void dispose() {
    _closeMenu(false);
    widget.valueNotifier.removeListener(_onValueChanged);
    _focusNode.removeListener(_onFocusChange);
    _filteredItemsNotifier.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onValueChanged() {
    final newText = _getFieldTextForValue(widget.valueNotifier.value);
    if (_controller.text != newText) {
      _controller.text = newText;
    }
  }

  String _getFieldTextForValue(T value) {
    try {
      final match = widget.items.firstWhere((item) => item.value == value);
      return match.fieldText ?? match.label;
    } catch (_) {
      return '';
    }
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus && widget.searchable && !_isOpen) {
      _openMenu();
    }
  }

  void _filterItems(String query) {
    if (query.isEmpty) {
      _filteredItemsNotifier.value = widget.items;
    } else {
      final lower = query.toLowerCase();
      _filteredItemsNotifier.value = widget.items
          .where((item) => item.label.toLowerCase().contains(lower))
          .toList();
    }
  }

  void _toggleMenu() {
    if (_isOpen) {
      _closeMenu(true);
    } else {
      _openMenu();
    }
  }

  void _openMenu() {
    if (_isOpen) return;
    _filterItems('');
    setState(() {
      _isOpen = true;
    });
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _closeMenu(bool revert) {
    if (!_isOpen) return;
    if (revert) {
      _controller.text = _getFieldTextForValue(widget.valueNotifier.value);
    }
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() {
        _isOpen = false;
      });
    }
    _focusNode.unfocus();
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox?;
    final size = renderBox?.size ?? Size.zero;

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => _closeMenu(true),
              child: const SizedBox.expand(),
            ),
          ),
          CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, size.height + 4.h),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: size.width,
                maxWidth: size.width,
                maxHeight: 250.h,
              ),
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8.r),
                color: AppColors.surface,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: ValueListenableBuilder<List<ApplyDropdownItem<T>>>(
                    valueListenable: _filteredItemsNotifier,
                    builder: (context, filteredItems, _) {
                      if (filteredItems.isEmpty) {
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                          child: Text(
                            'No results',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.grey.shade400,
                            ),
                          ),
                        );
                      }

                      return ValueListenableBuilder<T>(
                        valueListenable: widget.valueNotifier,
                        builder: (context, selectedValue, _) {
                          return ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = filteredItems[index];
                              final isSelected = item.value == selectedValue;

                              return InkWell(
                                onTap: () {
                                  widget.valueNotifier.value = item.value;
                                  _controller.text =
                                      item.fieldText ?? item.label;
                                  _closeMenu(false);
                                },
                                child: Container(
                                  color: isSelected
                                      ? AppColors.primary.shade50
                                      : Colors.transparent,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 12.h,
                                  ),
                                  child: Row(
                                    children: [
                                      if (item.leading != null) ...[
                                        item.leading!,
                                        SizedBox(width: 8.w),
                                      ],
                                      Expanded(
                                        child: Text(
                                          item.label,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: AppColors.black,
                                                fontWeight: isSelected
                                                    ? FontWeight.w600
                                                    : FontWeight.normal,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        controller: _controller,
        focusNode: _focusNode,
        readOnly: !widget.searchable,
        onTap: () {
          if (!widget.searchable) {
            _toggleMenu();
          } else if (!_isOpen) {
            _openMenu();
          }
        },
        onChanged: widget.searchable
            ? (val) {
                _filterItems(val);
                if (!_isOpen) _openMenu();
              }
            : null,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.black,
            ),
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          suffixIcon: IconButton(
            icon: Icon(
              _isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            ),
            onPressed: _toggleMenu,
          ),
        ),
      ),
    );
  }
}