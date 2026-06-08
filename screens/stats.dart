import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme.dart';
import '../main.dart';
import '../models/person.dart';
import '../widgets/common.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final alive = store.people.where((p) => !p.deceased).toList();
        final total = alive.length;
        final thisMonth = alive
            .where((p) => p.birthDate?.month == DateTime.now().month)
            .length;
        final next = store.upcoming.isEmpty ? null : store.upcoming.first;
        final avgAge = alive.where((p) => p.bd.isNotEmpty).isEmpty
            ? 0
            : (alive
                    .where((p) => p.bd.isNotEmpty)
                    .map((p) => p.ageTurning() - 1)
                    .reduce((a, b) => a + b) /
                alive.where((p) => p.bd.isNotEmpty).length)
                .round();

        final perMonth = List.filled(12, 0);
        for (final p in alive) {
          final d = p.birthDate;
          if (d != null) perMonth[d.month - 1]++;
        }

        final byGroup = <String, int>{};
        for (final p in alive) {
          byGroup[p.group] = (byGroup[p.group] ?? 0) + 1;
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            Text('Статистика', style: AppTheme.numbers(28)),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _Metric('Всего', '$total', Icons.people_rounded)),
              const SizedBox(width: 12),
              Expanded(child: _Metric('В этом месяце', '$thisMonth', Icons.cake_rounded)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: _Metric('Ближайший', next == null ? '—' : '${next.daysUntil()} дн.',
                      Icons.event_rounded)),
              const SizedBox(width: 12),
              Expanded(child: _Metric('Средний возраст', '$avgAge', Icons.timeline_rounded)),
            ]),
            const SizedBox(height: 20),
            const Text('По месяцам',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            SoftCard(
              child: SizedBox(
                height: 160,
                child: BarChart(BarChartData(
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          const m = ['Я','Ф','М','А','М','И','И','А','С','О','Н','Д'];
                          return Text(m[v.toInt()],
                              style: const TextStyle(fontSize: 10, color: AppColors.muted));
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    for (var i = 0; i < 12; i++)
                      BarChartGroupData(x: i, barRods: [
                        BarChartRodData(
                            toY: perMonth[i].toDouble(),
                            color: AppColors.gold,
                            width: 12,
                            borderRadius: BorderRadius.circular(4))
                      ])
                  ],
                )),
              ),
            ),
            const SizedBox(height: 20),
            const Text('По группам',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            ...['family', 'friends', 'work', 'other'].map((g) {
              final n = byGroup[g] ?? 0;
              final ratio = total == 0 ? 0.0 : n / total;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(children: [
                  SizedBox(
                      width: 80,
                      child: Text(AppColors.groupLabel(g),
                          style: const TextStyle(fontWeight: FontWeight.w600))),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 12,
                        backgroundColor: Colors.white,
                        color: AppColors.group(g),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('$n', style: const TextStyle(fontWeight: FontWeight.w700)),
                ]),
              );
            }),
          ],
        );
      },
    );
  }
}

class _Metric extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _Metric(this.label, this.value, this.icon);
  @override
  Widget build(BuildContext context) => SoftCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.gold),
            const SizedBox(height: 8),
            Text(value, style: AppTheme.numbers(32)),
            Text(label,
                style: const TextStyle(fontSize: 12, color: AppColors.muted)),
          ],
        ),
      );
}
