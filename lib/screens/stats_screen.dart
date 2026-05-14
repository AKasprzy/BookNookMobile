import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final api = ApiService();

  Map? stats;
  bool loading = true;

  final statusColors = [
    const Color(0xFF22C55E),
    const Color(0xFF3B82F6),
    const Color(0xFFF59E0B),
    const Color(0xFF64748B),
  ];

  final defaultColors = [
    const Color(0xFF6366F1),
    const Color(0xFF22C55E),
    const Color(0xFF3B82F6),
    const Color(0xFFF59E0B),
    const Color(0xFFEF4444),
    const Color(0xFF8B5CF6),
    const Color(0xFF14B8A6),
  ];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final res = await api.get("user/stats");
      setState(() {
        stats = res;
        loading = false;
      });
    } catch (_) {
      setState(() => loading = false);
    }
  }

  int totalBooks() {
    if (stats == null) return 0;
    final dist = stats!['status_distribution'] ?? {};
    return dist.values.fold(0, (a, b) => a + b);
  }

  int totalAuthors() {
    return stats?['top_authors']?.length ?? 0;
  }

  Widget pieChart(Map data, List<Color> colors) {
    final entries = data.entries.toList();

    return PieChart(
      PieChartData(
        sections: List.generate(entries.length, (i) {
          return PieChartSectionData(
            value: (entries[i].value as num).toDouble(),
            color: colors[i % colors.length],
            radius: 50,
            showTitle: false,
          );
        }),
      ),
    );
  }

  Widget barChart(List labels, List values, Color color) {
    return BarChart(
      BarChartData(
        barGroups: List.generate(values.length, (i) {
          return BarChartGroupData(x: i, barRods: [
            BarChartRodData(
              toY: (values[i] as num).toDouble(),
              color: color,
              width: 14,
              borderRadius: BorderRadius.circular(4),
            )
          ]);
        }),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= labels.length) return const SizedBox();
                return Text(
                  labels[index].toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget lineChart(List labels, List values) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(values.length,
                    (i) => FlSpot(i.toDouble(), (values[i] as num).toDouble())),
            isCurved: true,
            color: const Color(0xFF6366F1),
            dotData: FlDotData(show: false),
          )
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= labels.length) return const SizedBox();
                return Text(
                  labels[index].toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget card(String title, Widget chart) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(height: 220, child: chart),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : stats == null
          ? const Center(child: Text("Failed to load statistics"))
          : ListView(
        children: [
          Container(
            padding:
            const EdgeInsets.fromLTRB(16, 60, 16, 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F172A),
                  Color(0xFF1E293B),
                  Color(0xFF0F172A),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back,
                      color: Colors.white),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Statistics",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Insights into your reading habits",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                        child: _statBox(
                            "Total Books",
                            totalBooks().toString())),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _statBox(
                            "Authors",
                            totalAuthors().toString())),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _statBox(
                            "Favourites",
                            (stats!['favourites_ratio']
                            ?['favourite'] ??
                                0)
                                .toString())),
                  ],
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                card("Formats",
                    pieChart(stats!['formats'] ?? {}, defaultColors)),
                card(
                    "Top Authors",
                    barChart(
                        (stats!['top_authors'] ?? [])
                            .map((e) => e['author'])
                            .toList(),
                        (stats!['top_authors'] ?? [])
                            .map((e) => e['count'])
                            .toList(),
                        const Color(0xFF3B82F6))),
                card(
                    "Reading Over Time",
                    lineChart(
                        (stats!['reading_over_time'] ?? [])
                            .map((e) => e['date'])
                            .toList(),
                        (stats!['reading_over_time'] ?? [])
                            .map((e) => e['count'])
                            .toList())),
                card(
                    "Favourites Ratio",
                    pieChart(
                        stats!['favourites_ratio'] ?? {},
                        [const Color(0xFFEF4444), const Color(0xFF94A3B8)])),
                card(
                    "Languages",
                    pieChart(stats!['languages'] ?? {}, defaultColors)),
                card(
                    "Book Length",
                    barChart(
                        stats!['pages_distribution']?.keys.toList() ?? [],
                        stats!['pages_distribution']?.values.toList() ?? [],
                        const Color(0xFFF59E0B))),
                card(
                    "Status Distribution",
                    pieChart(stats!['status_distribution'] ?? {},
                        statusColors)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _statBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(fontSize: 22, color: Colors.white)),
          const SizedBox(height: 4),
          Text(label,
              style:
              const TextStyle(color: Colors.white70, fontSize: 12))
        ],
      ),
    );
  }
}