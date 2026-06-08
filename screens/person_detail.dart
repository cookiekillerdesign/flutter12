import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../theme.dart';
import '../main.dart';
import '../models/person.dart';
import '../data/greetings.dart';
import '../data/gifts.dart';
import '../services/notifications.dart';
import '../widgets/common.dart';
import 'person_form.dart';

class PersonDetail extends StatefulWidget {
  final String personId;
  const PersonDetail({super.key, required this.personId});
  @override
  State<PersonDetail> createState() => _PersonDetailState();
}

class _PersonDetailState extends State<PersonDetail> {
  late List<String> _greetings;

  Person? get p => store.byId(widget.personId);

  @override
  void initState() {
    super.initState();
    _refreshGreetings();
  }

  void _refreshGreetings() {
    final person = p;
    if (person != null) {
      _greetings = greetingsFor(person.name, person.ageTurning(), count: 8);
    } else {
      _greetings = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final person = p;
    if (person == null) return const Scaffold();
    final age = person.ageTurning();
    final days = person.daysUntil();
    final ideas = giftIdeas(person.interests);
    final color = AppColors.group(person.group);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: color,
            actions: [
              IconButton(
                  icon: const Icon(Icons.edit_rounded),
                  onPressed: () async {
                    await Navigator.push(context,
                        MaterialPageRoute(builder: (_) => PersonForm(person: person)));
                    setState(_refreshGreetings);
                  }),
              IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  onPressed: () => _confirmDelete(context, person)),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: color,
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Avatar(person, size: 84),
                      const SizedBox(height: 12),
                      Text(person.name,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.w800)),
                      if (person.bd.isNotEmpty)
                        Text(DateFormat('d MMMM yyyy', 'ru').format(person.birthDate!),
                            style: const TextStyle(color: AppColors.ink)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(children: [
                  Expanded(
                      child: _metric('Исполнится', '$age',
                          '${ageWord(age)}', AppColors.gold)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _metric('Осталось', days == 0 ? '🎉' : '$days',
                          days == 0 ? 'сегодня!' : 'дней', AppColors.ink)),
                ]),
                if (person.phone.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SoftCard(
                    child: Row(children: [
                      const Icon(Icons.phone_rounded, color: AppColors.muted),
                      const SizedBox(width: 12),
                      Text(person.phone),
                    ]),
                  ),
                ],
                const SizedBox(height: 20),
                _alarmsSection(person),
                if (ideas.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const _Title('Идеи подарков 🎁'),
                  ...ideas.map((g) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: SoftCard(
                          padding: const EdgeInsets.all(14),
                          child: Row(children: [
                            const Icon(Icons.card_giftcard_rounded,
                                size: 20, color: AppColors.gold),
                            const SizedBox(width: 10),
                            Expanded(child: Text(g)),
                          ]),
                        ),
                      )),
                ],
                const SizedBox(height: 20),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const _Title('Поздравления'),
                  TextButton.icon(
                      onPressed: () => setState(_refreshGreetings),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Ещё')),
                ]),
                ..._greetings.map((g) => _greetingCard(context, g)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(String label, String value, String unit, Color valueColor) =>
      SoftCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
            const SizedBox(height: 6),
            Row(crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic, children: [
              Text(value, style: AppTheme.numbers(36, color: valueColor)),
              const SizedBox(width: 6),
              Text(unit, style: const TextStyle(color: AppColors.muted)),
            ]),
          ],
        ),
      );

  Widget _alarmsSection(Person person) {
    final n = person.notif;
    final slots = [
      ('d7', 'За 7 дней', n.d7),
      ('d3', 'За 3 дня', n.d3),
      ('d2', 'За 2 дня', n.d2),
      ('d1', 'За 1 день', n.d1),
      ('morning', 'Утром в день рождения', n.morning),
    ];
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Напоминания',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ...slots.map((s) => SwitchListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                activeColor: AppColors.gold,
                title: Text(s.$2),
                value: s.$3,
                onChanged: person.deceased
                    ? null
                    : (v) async {
                        switch (s.$1) {
                          case 'd7': n.d7 = v; break;
                          case 'd3': n.d3 = v; break;
                          case 'd2': n.d2 = v; break;
                          case 'd1': n.d1 = v; break;
                          case 'morning': n.morning = v; break;
                        }
                        await store.save(person);
                        await Notifications.schedulePerson(person);
                        setState(() {});
                      },
              )),
        ],
      ),
    );
  }

  Widget _greetingCard(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text, style: const TextStyle(fontSize: 15, height: 1.5)),
              const SizedBox(height: 10),
              Row(children: [
                TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: text));
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Скопировано')));
                  },
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: const Text('Копировать'),
                ),
                TextButton.icon(
                  onPressed: () => Share.share(text),
                  icon: const Icon(Icons.ios_share_rounded, size: 18),
                  label: const Text('Поделиться'),
                ),
              ]),
            ],
          ),
        ),
      );

  void _confirmDelete(BuildContext context, Person person) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Удалить?'),
        content: Text('Удалить ${person.name} из списка?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            onPressed: () async {
              await Notifications.cancelPerson(person);
              await store.remove(person.id);
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  final String text;
  const _Title(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(text,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      );
}
