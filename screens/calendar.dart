import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../main.dart';
import '../models/person.dart';
import '../widgets/common.dart';
import 'person_detail.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int _offset = 0;

  @override
  Widget build(BuildContext context) {
    final base = DateTime.now();
    final month = DateTime(base.year, base.month + _offset);
    final first = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leading = (first.weekday + 6) % 7; // Monday-first

    // Map day-of-month -> people with birthday that day this month.
    final byDay = <int, List<Person>>{};
    for (final p in store.people) {
      final d = p.birthDate;
      if (d == null || p.deceased) continue;
      if (d.month == month.month) {
        byDay.putIfAbsent(d.day, () => []).add(p);
      }
    }

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: () => setState(() => _offset--),
                  icon: const Icon(Icons.chevron_left_rounded)),
              Text(toBeginningOfSentenceCase(DateFormat('LLLL yyyy', 'ru').format(month))!,
                  style: AppTheme.numbers(22)),
              IconButton(
                  onPressed: () => setState(() => _offset++),
                  icon: const Icon(Icons.chevron_right_rounded)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс']
                .map((d) => Expanded(
                    child: Center(
                        child: Text(d,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.muted,
                                fontWeight: FontWeight.w700)))))
                .toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7, childAspectRatio: 0.85),
            itemCount: leading + daysInMonth,
            itemBuilder: (_, i) {
              if (i < leading) return const SizedBox();
              final day = i - leading + 1;
              final people = byDay[day] ?? const [];
              final isToday = _offset == 0 && day == base.day;
              return GestureDetector(
                onTap: people.isEmpty ? null : () => _showDay(context, day, month, people),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: isToday ? AppColors.ink : Colors.transparent,
                          shape: BoxShape.circle),
                      child: Text('$day',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: isToday ? AppColors.gold : AppColors.ink)),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: people
                          .take(3)
                          .map((p) => Container(
                                width: 5,
                                height: 5,
                                margin: const EdgeInsets.symmetric(horizontal: 1),
                                decoration: BoxDecoration(
                                    color: AppColors.group(p.group),
                                    shape: BoxShape.circle),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showDay(BuildContext context, int day, DateTime month, List<Person> people) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('d MMMM', 'ru').format(DateTime(month.year, month.month, day)),
                style: AppTheme.numbers(22)),
            const SizedBox(height: 12),
            ...people.map((p) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Avatar(p, size: 44),
                  title: Text(p.name,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(AppColors.groupLabel(p.group)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => PersonDetail(personId: p.id)));
                  },
                )),
          ],
        ),
      ),
    );
  }
}
