import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../main.dart';
import '../models/person.dart';
import '../data/gifts.dart';
import '../services/notifications.dart';

const _timezones = [
  'Europe/Moscow', 'Europe/Kaliningrad', 'Europe/Samara', 'Europe/Kiev',
  'Europe/Minsk', 'Europe/London', 'Europe/Berlin', 'Europe/Paris',
  'Europe/Istanbul', 'Asia/Almaty', 'Asia/Tashkent', 'Asia/Yekaterinburg',
  'Asia/Novosibirsk', 'Asia/Krasnoyarsk', 'Asia/Irkutsk', 'Asia/Vladivostok',
  'Asia/Dubai', 'Asia/Tbilisi', 'Asia/Yerevan', 'America/New_York',
  'America/Los_Angeles',
];

class PersonForm extends StatefulWidget {
  final Person person;
  const PersonForm({super.key, required this.person});
  @override
  State<PersonForm> createState() => _PersonFormState();
}

class _PersonFormState extends State<PersonForm> {
  late Person p;
  late TextEditingController _name, _phone, _note;

  @override
  void initState() {
    super.initState();
    p = widget.person;
    _name = TextEditingController(text: p.name);
    _phone = TextEditingController(text: p.phone);
    _note = TextEditingController(text: p.note);
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final x = await ImagePicker()
        .pickImage(source: ImageSource.gallery, maxWidth: 600, imageQuality: 80);
    if (x != null) {
      final bytes = await x.readAsBytes();
      setState(() => p.photo = base64Encode(bytes));
    }
  }

  Future<void> _save() async {
    p.name = _name.text.trim();
    p.phone = _phone.text.trim();
    p.note = _note.text.trim();
    if (p.name.isEmpty || p.bd.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Укажите имя и дату')));
      return;
    }
    await store.save(p);
    await Notifications.schedulePerson(p);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.person.name.isEmpty ? 'Новый человек' : 'Редактировать'),
        actions: [
          TextButton(
              onPressed: _save,
              child: const Text('Сохранить',
                  style: TextStyle(fontWeight: FontWeight.w800))),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          Center(
            child: GestureDetector(
              onTap: _pickPhoto,
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.group(p.group),
                  shape: BoxShape.circle,
                  image: p.photo != null && p.photo!.isNotEmpty
                      ? DecorationImage(
                          image: MemoryImage(base64Decode(p.photo!)),
                          fit: BoxFit.cover)
                      : null,
                ),
                child: p.photo == null || p.photo!.isEmpty
                    ? const Icon(Icons.add_a_photo_rounded, color: AppColors.ink)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _field(_name, 'Имя'),
          const SizedBox(height: 12),
          _DateField(
            value: p.birthDate,
            onPick: (d) => setState(
                () => p.bd = DateFormat('yyyy-MM-dd').format(d)),
          ),
          const SizedBox(height: 16),
          const _Label('Группа'),
          Wrap(
            spacing: 8,
            children: ['family', 'friends', 'work', 'other'].map((g) {
              final active = p.group == g;
              return ChoiceChip(
                label: Text(AppColors.groupLabel(g)),
                selected: active,
                selectedColor: AppColors.group(g),
                backgroundColor: Colors.white,
                onSelected: (_) => setState(() => p.group = g),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          _field(_phone, 'Телефон', keyboard: TextInputType.phone),
          const SizedBox(height: 12),
          _field(_note, 'Заметка', maxLines: 2),
          const SizedBox(height: 16),
          const _Label('Часовой пояс'),
          DropdownButtonFormField<String>(
            value: _timezones.contains(p.tz) ? p.tz : _timezones.first,
            decoration: _dec(),
            items: _timezones
                .map((tz) => DropdownMenuItem(value: tz, child: Text(tz)))
                .toList(),
            onChanged: (v) => setState(() => p.tz = v ?? p.tz),
          ),
          const SizedBox(height: 16),
          const _Label('Интересы'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: kInterests.map((i) {
              final active = p.interests.contains(i);
              return GestureDetector(
                onTap: () => setState(() {
                  active ? p.interests.remove(i) : p.interests.add(i);
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: active ? AppColors.ink : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(i,
                      style: TextStyle(
                          color: active ? Colors.white : AppColors.ink,
                          fontWeight: FontWeight.w600)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeColor: AppColors.gold,
            title: const Text('Ушедший'),
            subtitle: const Text('Серый вид, без уведомлений'),
            value: p.deceased,
            onChanged: (v) => setState(() => p.deceased = v),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String hint,
          {TextInputType? keyboard, int maxLines = 1}) =>
      TextField(
        controller: c,
        keyboardType: keyboard,
        maxLines: maxLines,
        decoration: _dec(hint: hint),
      );

  InputDecoration _dec({String? hint}) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      );
}

class _DateField extends StatelessWidget {
  final DateTime? value;
  final ValueChanged<DateTime> onPick;
  const _DateField({required this.value, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime(2000),
          firstDate: DateTime(1920),
          lastDate: DateTime.now(),
          locale: const Locale('ru'),
        );
        if (d != null) onPick(d);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          const Icon(Icons.cake_rounded, color: AppColors.muted),
          const SizedBox(width: 12),
          Text(
            value == null
                ? 'Дата рождения'
                : DateFormat('d MMMM yyyy', 'ru').format(value!),
            style: TextStyle(
                color: value == null ? AppColors.muted : AppColors.ink,
                fontSize: 16),
          ),
        ]),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
      );
}
