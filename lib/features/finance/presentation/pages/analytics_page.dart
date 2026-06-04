import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfaiassistant/features/finance/presentation/bloc/dashboard/dashboard_bloc.dart';
import 'package:pfaiassistant/features/finance/presentation/bloc/dashboard/dashboard_state.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
   String selectedPeriod = "Month";

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading) return const Center(child: CircularProgressIndicator());
        if (state is DashboardLoaded) {
          return Scaffold(
            backgroundColor:  Theme.of(context).colorScheme.surface,
            appBar: _buildAppBar(),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  Center(child: _buildPeriodSelector()),
                  const SizedBox(height: 30),


                  _buildStatRow(state),
                  const SizedBox(height: 30),


                  _buildLineChartCard(state),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        }
        return const Center(child: Text("No Data Found"));
      }
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 80,
      title:  Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Analytics", style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 26)),
          Text("Your spending insights", style: TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFF1F5F9)),
          child: IconButton(
            onPressed: () {}, 
            icon:  Icon(Icons.dark_mode_outlined, color: Theme.of(context).colorScheme.onSurface, size: 20),
            ),
        ),
      ],
    );
  }


  Widget _buildStatRow(DashboardLoaded state) {
    return SizedBox(
      height: 160,
      child: Row(
         children: [
             _StatCard(
              title: "Total\nSpent",
              value: "${state.totalSpending.toInt()}",
              unit: "PKR",
              trend: "+12%",
              isPositive: true
              ),
          const SizedBox(width: 12),
             _StatCard(
              title: "Avg\nDaily",
              value: "1,214",
              unit: "PKR",
              trend: "-5%",
              isPositive: false,
           ),
          const SizedBox(width: 12),
            _StatCard(
              title: "Transactions",
              value: "${state.transactions.length}",
              unit: "",
              trend: "+3",
              isPositive: true,
            ),
        ],
      ),
    );
  }

  Widget _buildLineChartCard(DashboardLoaded state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
       color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Theme.of(context).colorScheme.surface),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Spending Trend", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 30),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        if(value % 900 == 0) {
                          return Text(value.toInt().toString(), style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 12));
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        switch (value.toInt()) {
                          case 1: return Text("1", style: TextStyle(color: Theme.of(context).colorScheme.onSurface));
                          case 10: return Text("2", style: TextStyle(color: Theme.of(context).colorScheme.onSurface));
                          case 20: return Text("3", style: TextStyle(color: Theme.of(context).colorScheme.onSurface));
                          case 30: return Text("29", style: TextStyle(color: Theme.of(context).colorScheme.onSurface));
                          case 40: return Text("30", style: TextStyle(color: Theme.of(context).colorScheme.onSurface));
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: false,
                  border: Border(
                    bottom: BorderSide(color: Theme.of(context).colorScheme.surface, width: 1),
                    left: BorderSide(color: Theme.of(context).colorScheme.surface, width: 1),
                  ),
                ),
                minX: 0, maxX: 45,
                minY: 0, maxY: 3600,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(1, 3600),
                      FlSpot(2, 1200),
                      FlSpot(3, 500),
                      FlSpot(4, 2500),
                      FlSpot(5, 800),
                    ],
                    isCurved: true,
                    color: const Color(0xFF7C3AED),
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 6,
                        color: const Color(0xFF6366F1),
                        strokeWidth: 2,
                        strokeColor: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildPeriodSelector() {
  return Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: const Color(0xFFF1F5F9).withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(16)
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: ["Week", "Month", "Year"].map((e) {
        bool isSelected = selectedPeriod == e;
        return GestureDetector(
          onTap: () => setState(() => selectedPeriod = e),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? Theme.of(context).colorScheme.surface : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isSelected 
                 ? [BoxShadow(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))]
                 : [],
            ),
          child : Text(
            e,
            style: TextStyle(
              color: isSelected ? Theme.of(context).colorScheme.onSurface : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    ),
  );
}}


class _StatCard extends StatelessWidget {
  final String title, value, unit, trend;
  final bool isPositive;
  const _StatCard({required this.title, required this.value, required this.unit, required this.trend, required this.isPositive});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.2)),
            const Spacer(),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (unit.isNotEmpty) Text(unit, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  size: 14,
                  color: isPositive ? Colors.grey : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(trend, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
