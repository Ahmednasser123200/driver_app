import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../errors/app_failure.dart';
import 'base_state.dart';

abstract class BaseCubit<T> extends Cubit<BaseState<T>> {
  BaseCubit() : super(BaseState<T>());

  final StreamController<AppFailure> _uiEvents =
      StreamController<AppFailure>.broadcast();

  /// UI-facing event stream. Listeners localize and display failures without
  /// coupling the presentation layer to the cubit state.
  Stream<AppFailure> get uiEventStream => _uiEvents.stream;

  void emitLoading() {
    emit(state.copyWith(isLoading: true, errorMessage: ''));
  }

  void emitSuccess(T data) {
    emit(
      state.copyWith(isLoading: false, errorMessage: '', data: data),
    );
  }

  void emitFailure(AppFailure failure) {
    _uiEvents.add(failure);
    emit(state.copyWith(isLoading: false, errorMessage: ''));
  }

  @override
  Future<void> close() async {
    await _uiEvents.close();
    return super.close();
  }
}