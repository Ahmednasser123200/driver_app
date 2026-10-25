import 'package:equatable/equatable.dart';

class RecipientInfoEntity extends Equatable {
  final bool isGift;
  final String recipientName;
  final String recipientPhone;

  const RecipientInfoEntity({
    required this.isGift,
    required this.recipientName,
    required this.recipientPhone,
  });

  @override
  List<Object?> get props => [isGift, recipientName, recipientPhone];
}
