import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class FetchExpensesEvent extends DashboardEvent {}

class SearchTransactionsEvent extends DashboardEvent {
  final String query;
  const SearchTransactionsEvent(this.query);

  @override
  List<Object?> get props => [query];
}
