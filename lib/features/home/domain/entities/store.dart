
import 'package:equatable/equatable.dart';

class Store extends Equatable {
  final String name;
  final String address;

  const Store({
    required this.name,
    required this.address,
  });

  @override
  List<Object?> get props => [name, address];
}