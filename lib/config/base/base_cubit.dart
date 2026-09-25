import 'package:driver_app/config/base/ui_event_stream_mixin.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BaseCubit<State, UiEvent> extends Cubit<State>
    with UiEventStreamMixin<State, UiEvent> {
  BaseCubit(super.initialState);
}
