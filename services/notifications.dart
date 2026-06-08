import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../models/person.dart';

class Notifications {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _ready = false;

  static Future<void> init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation(await FlutterTimezone.getLocalTimezone()));
    } catch (_) {}
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
        const InitializationSettings(android: android, iOS: ios));
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    _ready = true;
  }

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'birthdayz', 'Дни рождения',
      channelDescription: 'Напоминания о днях рождения',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  // Stable per-person+slot id.
  static int _id(String personId, String slot) =>
      (personId + slot).hashCode & 0x7FFFFFFF;

  static Future<void> schedulePerson(Person p) async {
    await cancelPerson(p);
    if (p.deceased || p.bd.isEmpty) return;
    tz.Location loc;
    try {
      loc = tz.getLocation(p.tz);
    } catch (_) {
      loc = tz.local;
    }
    for (final slot in p.notif.enabledSlots()) {
      final fireAt = _nextFire(p, slot.value, loc);
      final age = p.ageTurning();
      final body = slot.value == 0
          ? 'Сегодня день рождения! Исполняется $age ${ageWord(age)}'
          : 'Через ${slot.value} ${ageWord(slot.value)} — день рождения';
      await _plugin.zonedSchedule(
        _id(p.id, slot.key),
        p.name,
        body,
        fireAt,
        _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
      );
    }
  }

  static tz.TZDateTime _nextFire(Person p, int daysAhead, tz.Location loc) {
    final next = p.nextBirthday();
    var fire = tz.TZDateTime(
        loc, next.year, next.month, next.day - daysAhead, 9, 0);
    final now = tz.TZDateTime.now(loc);
    if (fire.isBefore(now)) {
      fire = tz.TZDateTime(loc, next.year + 1, next.month, next.day - daysAhead, 9, 0);
    }
    return fire;
  }

  static Future<void> cancelPerson(Person p) async {
    for (final slot in ['d7', 'd3', 'd2', 'd1', 'morning']) {
      await _plugin.cancel(_id(p.id, slot));
    }
  }

  static Future<void> rescheduleAll(List<Person> people) async {
    for (final p in people) {
      await schedulePerson(p);
    }
  }
}
