import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../main.dart';
import '../models/person.dart';
import '../widgets/common.dart';
import 'person_detail.dart';

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});
  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  String _query = '';
  String? _group; // null = all
  bool _showDeceased = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        var list = store.people.where((p) {
          if (!_showDeceased && p.deceased) return false;
          if (_group != null && p.group != _group) return false;
          if (_query.isNotEmpty &&
              !p.name.toLowerCase().contains(_query.toLowerCase())) return false;
          return true;
        }).toList()
          ..sort((a, b) => a.daysUntil().compareTo(b.daysUntil()));

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Поиск...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _chip('Все', _group == null, () => setState(() => _group = null)),
                  for (final g in ['family', 'friends', 'work', 'other'])
                    _chip(AppColors.groupLabel(g), _group == g,
                        () => setState(() => _group = g),
                        color: AppColors.group(g)),
                  _chip('Ушедшие', _showDeceased,
                      () => setState(() => _showDeceased = !_showDeceased)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: list.isEmpty
                  ? const Center(
                      child: Text('Никого не найдено',
                          style: TextStyle(color: AppColors.muted)))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      itemCount: list.length,
                      itemBuilder: (_, i) => _tile(context, list[i]),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _chip(String label, bool active, VoidCallback onTap, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: active ? (color ?? AppColors.ink) : Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: active && color == null ? Colors.white : AppColors.ink)),
        ),
      ),
    );
  }

  Widget _tile(BuildContext context, Person p) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SoftCard(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => PersonDetail(personId: p.id))),
        child: Row(
          children: [
            Avatar(p, size: 48),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: p.deceased ? AppColors.muted : AppColors.ink)),
                  if (p.bd.isNotEmpty)
                    Text(DateFormat('d MMMM yyyy', 'ru').format(p.birthDate!),
                        style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                ],
              ),
            ),
            if (!p.deceased) DayBadge(p.daysUntil()),
          ],
        ),
      ),
    );
  }
}
