import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/dashboard/dashboard_bloc.dart';
import '../bloc/dashboard/dashboard_state.dart';
import '../bloc/dashboard/dashboard_event.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text("History", style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 24)),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.dark_mode_outlined, color: Theme.of(context).colorScheme.onSurface))],
        ),
        body: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoaded) {
              return Column(
                children: [
                  _buildSearchBar(context),
                  _buildFilterChips(),
                  Expanded(child: _buildTransactionList(state.transactions)),
                ],
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
    );
  }


  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: TextField(
        onChanged: (value) => context.read<DashboardBloc>().add(SearchTransactionsEvent(value)),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: "Search transactions",
          filled: true,
          fillColor: const Color(0xFFF8F9FA),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
      );
  } 

  Widget _buildFilterChips() {
    return Container(
      height: 180,
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade100), borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("CATEGORY", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
               _FilterChip(label: "All", isSelected: true),
               _FilterChip(label: "Groceries" , emoji: "🛒"),
               _FilterChip(label: "Transport", emoji: "🚗"),
               _FilterChip(label: "Bills" , emoji: "💡"),
               _FilterChip(label: "Food", emoji: "🍔"),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTransactionList(List transactions) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final t = transactions[index];
        final dateStr = DateFormat("MMM d, yyyy").format(t.date).toUpperCase();

        return Column(
          children: [
            Row(
              children: [
                Text(dateStr, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                const Expanded(child: Divider(indent: 10, endIndent: 10)),
                Text("${t.amount.toInt()} PKR", style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Text("🛒", style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.description, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(t.category, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  const Spacer(),
                  Text("-${t.amount.toInt()} PKR", style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            )
          ],
        );
      } ,
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String? emoji;
  final bool isSelected;
  const _FilterChip({required this.label, this.emoji, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
           if (emoji != null) Text(emoji!, style: const TextStyle(fontSize: 14)),
           if (emoji != null) const SizedBox(width: 4),
           Text(label, style: TextStyle(color: isSelected ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.onSurface, fontSize: 12)),
        ],
      ),
    );
  }
}