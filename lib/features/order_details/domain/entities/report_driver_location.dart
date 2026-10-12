
import 'package:equatable/equatable.dart';

class ReportDriverLocationEntity extends Equatable {
  final bool success;
  final String recordedAt;

  const ReportDriverLocationEntity({
    required this.success,
    required this.recordedAt,
  });

  @override
  List<Object?> get props => [
        success,
        recordedAt,
      ];
}