import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/finance_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final FinanceRepository repository;

  DashboardBloc({required this.repository}) : super(DashboardInitial()) {
    on<FetchExpensesEvent>(_onFetchExpenses);
    on<SearchTransactionsEvent>(_onSearchTransactions);
  }

  Future<void> _onFetchExpenses(
    FetchExpensesEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    try {
      final transactions = await repository.getAllTransactions();

      double total = 0;
      for (var t in transactions) {
        total += t.amount;
      }

      final Map<String, double> categories = {};
      for(var t in transactions) {
        if(categories.containsKey(t.category)) {
          categories[t.category] = categories[t.category]! + t.amount;
        } else {
          categories[t.category] = t.amount;
        }
      }

      emit(DashboardLoaded(
        transactions: transactions,
        totalSpending: total,
        categoryTotals: categories,
      ));

    } catch(e) {
      emit(const DashboardError("Failed to load dashboard data"));
    }
  }

  Future<void> _onSearchTransactions(
    SearchTransactionsEvent event,
    Emitter<DashboardState> emit,
  ) async {
    if(event.query.isEmpty) {
      add(FetchExpensesEvent());
      return;
    }

    emit(DashboardLoading());
    try {
      final results = await repository.searchTransactions(event.query);

      double total = results.fold(0, (sum, t) => sum + t.amount);

      emit(DashboardLoaded(
        transactions: results,
         totalSpending: total,
          categoryTotals: {},
          ));
    } catch (e) {
       emit(DashboardError("Search failed"));
    }
  }
}