sealed class BaseUiEvent {
  const BaseUiEvent();
}

class ShowSuccessMessage extends BaseUiEvent {
  final String message;
  const ShowSuccessMessage(this.message);
}

class ShowErrorMessage extends BaseUiEvent {
  final String message;
  const ShowErrorMessage(this.message);
}

class NavigateTo extends BaseUiEvent {
  final String routeName;
  final Object? arguments;
  const NavigateTo(this.routeName, {this.arguments});
}

class PopRoute extends BaseUiEvent {
  final Object? result;
  const PopRoute([this.result]);
}
