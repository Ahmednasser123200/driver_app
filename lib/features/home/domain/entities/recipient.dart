
import 'package:equatable/equatable.dart';

class Recipient extends Equatable {
  final String name;
  final String city;
  final String area;

  const Recipient({
    required this.name,
    required this.city,
    required this.area,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [
    name,
    city,
    area,
  ];
}