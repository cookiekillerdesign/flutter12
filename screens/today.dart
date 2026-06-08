import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../main.dart';
import '../models/person.dart';
import '../widgets/common.dart';
import 'person_detail.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final now = DateTime.now();
        final today = store.todayBirthdays();
        final upcoming = store.upcoming.where((p) => p.daysUntil() > 0).take(12).toList();
        final fmt = DateFormat('EEEE', 'ru');

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            Text(toBeginningOfSentenceCase(fmt.format(now))!,
                style: const TextStyle(
                    fontSize: 15, color: AppColors.muted, fontWeight: FontWeight.w600)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${now.day}', style: AppTheme.numbers(72, weight: FontWeight.w900)),
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Text(DateFormat('MMMM', 'ru').format(now),
                      style: AppTheme.numbers(28, color: AppColors.muted)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (today.isNotEmpty) ...[
              const _SectionTitle('Сегодня празднуют 🎉'),
              ...today.map((p) => _TodayCard(p)),
              const SizedBox(height: 20),
            ],
            const _SectionTitle('Ближайшие'),
            if (upcoming.isEmpty)
              const _Empty()
            else
              ...upcoming.map((p) => _UpcomingTile(p)),
          ],
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(text,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      );
}

class _TodayCard extends StatelessWidget {
  final Person p;
  const _TodayCard(this.p);
  @override
  Widget build(BuildContext context) {
    final age = p.ageTurning();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SoftCard(
        color: AppColors.group(p.group),
        onTap: () => _open(context, p),
        child: Row(
          children: [
            Avatar(p, size: 58),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text('Исполняется $age ${ageWord(age)}',
                      style: const TextStyle(fontSize: 13, color: AppColors.ink)),
                ],
              ),
            ),
            const Icon(Icons.celebration_rounded, color: AppColors.ink),
          ],
        ),
      ),
    );
  }
}

class _UpcomingTile extends StatelessWidget {
  final Person p;
  const _UpcomingTile(this.p);
  @override
  Widget build(BuildContext context) {
    final d = p.daysUntil();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SoftCard(
        onTap: () => _open(context, p),
        child: Row(
          children: [
            Avatar(p, size: 48),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(DateFormat('d MMMM', 'ru').format(p.nextBirthday()),
                      style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                ],
              ),
            ),
            DayBadge(d),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.cake_outlined, size: 56, color: AppColors.muted),
            SizedBox(height: 12),
            Text('Пока никого нет.\nДобавь первый день рождения!',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted)),
          ],
        ),
      );
}

void _open(BuildContext context, Person p) => Navigator.push(
    context, MaterialPageRoute(builder: (_) => PersonDetail(personId: p.id)));
