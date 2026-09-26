import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

mixin UiEventStreamMixin<State, UiEvent> on Cubit<State> {
  final StreamController<UiEvent> _uiEventController =
      StreamController<UiEvent>.broadcast();

  /// الـ Stream اللي الـ UI بيسمع عليه
  Stream<UiEvent> get uiEventStream => _uiEventController.stream;

  /// دالة موحدة لإرسال الحدث إلى الـ UI
  void emitEvent(UiEvent event) {
    if (_uiEventController.isClosed) return;
    _uiEventController.add(event);
  }

  @override
  Future<void> close() async {
    await _uiEventController.close();
    return super.close();
  }
}
