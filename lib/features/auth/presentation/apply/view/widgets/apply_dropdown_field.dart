import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import 'package:driver_app/core/themes/app_colors/app_colors.dart';

class ApplyDropdownItem<T> {
  final T value;
  final String label;
  final String? fieldText; // CHANGED: text shown in the closed field; falls back to label
  final Widget? leading;

  const ApplyDropdownItem({
    required this.value,
    required this.label,
    this.fieldText, // CHANGED
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
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  String _searchQuery = '';
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _getFieldTextForValue(widget.valueNotifier.value)); // CHANGED
    widget.valueNotifier.addListener(_onValueChanged);
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _closeMenu(false);
    widget.valueNotifier.removeListener(_onValueChanged);
    _focusNode.removeListener(_onFocusChange);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onValueChanged() {
    final newText = _getFieldTextForValue(widget.valueNotifier.value); // CHANGED
    if (_controller.text != newText) {
      _controller.text = newText;
    }
  }

  // CHANGED: new helper, used for the closed field's text
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

  void _toggleMenu() {
    if (_isOpen) {
      _closeMenu(true);
    } else {
      _openMenu();
    }
  }

  void _openMenu() {
    if (_isOpen) return;
    setState(() {
      _isOpen = true;
      _searchQuery = '';
    });
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _closeMenu(bool revert) {
    if (!_isOpen) return;
    if (revert) {
      _controller.text = _getFieldTextForValue(widget.valueNotifier.value); // CHANGED
    }
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() {
        _isOpen = false;
        _searchQuery = '';
      });
    }
    _focusNode.unfocus();
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox? renderBox = context.findRenderObject() as RenderBox?;
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
                borderRadius: BorderRadius.circular(4),
                color: AppColors.surface,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: ValueListenableBuilder<T>(
                    valueListenable: widget.valueNotifier,
                    builder: (context, selectedValue, _) {
                      final filteredItems = widget.items.where((item) {
                        if (_searchQuery.isEmpty) return true;
                        return item.label.toLowerCase().contains(_searchQuery.toLowerCase());
                      }).toList();

                      if (filteredItems.isEmpty) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                          child: Text(
                            'No results',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.grey.shade400,
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          final isSelected = item.value == selectedValue;

                          return InkWell(
                            onTap: () {
                              widget.valueNotifier.value = item.value;
                              _controller.text = item.fieldText ?? item.label; // CHANGED
                              _closeMenu(false);
                            },
                            child: Container(
                              color: isSelected ? AppColors.primary.shade50 : Colors.transparent,
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                              child: Row(
                                children: [
                                  if (item.leading != null) ...[
                                    item.leading!,
                                    SizedBox(width: 8.w),
                                  ],
                                  Expanded(
                                    child: Text(
                                      item.label,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppColors.black,
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
          setState(() {
            _searchQuery = val;
          });
          if (!_isOpen) _openMenu();
          _overlayEntry?.markNeedsBuild();
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
            icon: Icon(_isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
            onPressed: _toggleMenu,
          ),
        ),
      ),
    );
  }
}