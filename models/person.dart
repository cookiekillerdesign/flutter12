import 'dart:math';

class NotifPrefs {
  bool d7, d3, d2, d1, morning;
  NotifPrefs({
    this.d7 = true,
    this.d3 = true,
    this.d2 = false,
    this.d1 = true,
    this.morning = true,
  });

  Map<String, dynamic> toJson() =>
      {'d7': d7, 'd3': d3, 'd2': d2, 'd1': d1, 'morning': morning};

  factory NotifPrefs.fromJson(Map<String, dynamic> j) => NotifPrefs(
        d7: j['d7'] ?? true,
        d3: j['d3'] ?? true,
        d2: j['d2'] ?? false,
        d1: j['d1'] ?? true,
        morning: j['morning'] ?? true,
      );

  // Returns list of (key, daysAhead) for every enabled slot.
  List<MapEntry<String, int>> enabledSlots() => [
        if (d7) const MapEntry('d7', 7),
        if (d3) const MapEntry('d3', 3),
        if (d2) const MapEntry('d2', 2),
        if (d1) const MapEntry('d1', 1),
        if (morning) const MapEntry('morning', 0),
      ];
}

class Person {
  String id;
  String name;
  String bd; // ISO yyyy-MM-dd
  String group; // family|friends|work|other
  List<String> interests;
  String note;
  bool deceased;
  String tz;
  String phone;
  String? photo; // base64, no data-url prefix
  NotifPrefs notif;

  Person({
    String? id,
    this.name = '',
    this.bd = '',
    this.group = 'friends',
    List<String>? interests,
    this.note = '',
    this.deceased = false,
    this.tz = 'Europe/Moscow',
    this.phone = '',
    this.photo,
    NotifPrefs? notif,
  })  : id = id ?? _genId(),
        interests = interests ?? [],
        notif = notif ?? NotifPrefs();

  static String _genId() =>
      DateTime.now().millisecondsSinceEpoch.toRadixString(36) +
      Random().nextInt(1 << 20).toRadixString(36);

  DateTime? get birthDate => bd.isEmpty ? null : DateTime.tryParse(bd);

  // Days until next birthday. 0 == today.
  int daysUntil([DateTime? from]) {
    final d = birthDate;
    if (d == null) return 9999;
    final now = _atMidnight(from ?? DateTime.now());
    var next = DateTime(now.year, d.month, d.day);
    if (next.isBefore(now)) next = DateTime(now.year + 1, d.month, d.day);
    return next.difference(now).inDays;
  }

  // Age the person turns on the next birthday.
  int ageTurning([DateTime? from]) {
    final d = birthDate;
    if (d == null) return 0;
    final now = _atMidnight(from ?? DateTime.now());
    var age = now.year - d.year;
    final passed = DateTime(now.year, d.month, d.day);
    if (passed.isBefore(now)) age++;
    return age;
  }

  DateTime nextBirthday([DateTime? from]) {
    final d = birthDate!;
    final now = _atMidnight(from ?? DateTime.now());
    var next = DateTime(now.year, d.month, d.day);
    if (next.isBefore(now)) next = DateTime(now.year + 1, d.month, d.day);
    return next;
  }

  static DateTime _atMidnight(DateTime t) => DateTime(t.year, t.month, t.day);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'bd': bd,
        'group': group,
        'interests': interests,
        'note': note,
        'deceased': deceased,
        'tz': tz,
        'phone': phone,
        'photo': photo,
        'notif': notif.toJson(),
      };

  factory Person.fromJson(Map<String, dynamic> j) => Person(
        id: j['id'],
        name: j['name'] ?? '',
        bd: j['bd'] ?? '',
        group: j['group'] ?? 'friends',
        interests: (j['interests'] as List?)?.map((e) => '$e').toList() ?? [],
        note: j['note'] ?? '',
        deceased: j['deceased'] ?? false,
        tz: j['tz'] ?? 'Europe/Moscow',
        phone: j['phone'] ?? '',
        photo: j['photo'],
        notif: j['notif'] != null
            ? NotifPrefs.fromJson(Map<String, dynamic>.from(j['notif']))
            : NotifPrefs(),
      );
}

// Russian age word: год / года / лет
String ageWord(int age) {
  final a = age % 10, b = age % 100;
  if (a == 1 && b != 11) return 'год';
  if ([2, 3, 4].contains(a) && ![12, 13, 14].contains(b)) return 'года';
  return 'лет';
}
