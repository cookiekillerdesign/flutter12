import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/person.dart';

class Store extends ChangeNotifier {
  static const _peopleKey = 'bday_people_v2';
  static const _onboardKey = 'bday_onboard_v2';

  final List<Person> _people = [];
  List<Person> get people => List.unmodifiable(_people);

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs.getString(_peopleKey);
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      _people
        ..clear()
        ..addAll(list.map((e) => Person.fromJson(Map<String, dynamic>.from(e))));
    }
    notifyListeners();
  }

  bool get onboardDone => _prefs.getString(_onboardKey) == '1';
  Future<void> setOnboardDone() async =>
      _prefs.setString(_onboardKey, '1');

  Future<void> _persist() async {
    await _prefs.setString(
        _peopleKey, jsonEncode(_people.map((e) => e.toJson()).toList()));
    notifyListeners();
  }

  Person? byId(String id) {
    for (final p in _people) {
      if (p.id == id) return p;
    }
    return null;
  }

  Future<void> save(Person p) async {
    final i = _people.indexWhere((e) => e.id == p.id);
    if (i >= 0) {
      _people[i] = p;
    } else {
      _people.add(p);
    }
    await _persist();
  }

  Future<void> remove(String id) async {
    _people.removeWhere((e) => e.id == id);
    await _persist();
  }

  // Sorted by upcoming birthday.
  List<Person> get upcoming {
    final l = _people.where((p) => !p.deceased && p.bd.isNotEmpty).toList();
    l.sort((a, b) => a.daysUntil().compareTo(b.daysUntil()));
    return l;
  }

  List<Person> todayBirthdays() =>
      upcoming.where((p) => p.daysUntil() == 0).toList();
}
