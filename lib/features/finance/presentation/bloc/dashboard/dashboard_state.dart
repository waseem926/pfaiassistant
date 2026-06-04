import 'package:equatable/equatable.dart';
import '../../../domain/entities/transaction_entity.dart';


abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final List<TransactionEntity> transactions;
  final double totalSpending;
  final Map<String, double> categoryTotals;

  const DashboardLoaded({
    required this.transactions,
    required this.totalSpending,
    required this.categoryTotals,
  });

  @override
  List<Object?> get props => [transactions, totalSpending, categoryTotals];
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}