import 'package:equatable/equatable.dart';

class TransactionEntity extends Equatable {

 final String id;
 final double amount;
 final String category;
 final String description;
 final DateTime date;

 const TransactionEntity({
  required this.id,
  required this.amount,
  required this.category,
  required this.description,
  required this.date,
 });

 @override
  List<Object?> get props => [id, amount, category, description, date];

}