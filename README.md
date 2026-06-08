# Birthdayz Alarm — Flutter

Flutter-порт приложения Birthdayz Alarm v2. Офлайн, данные в `shared_preferences`, нативные локальные уведомления.

## Запуск

```bash
flutter create . --org com.birthday --project-name birthdayz_alarm   # генерирует android/ ios/
# скопируй lib/ и pubspec.yaml поверх созданных
flutter pub get
flutter run
```

## Структура

```
lib/
  main.dart                 splash → onboarding → home
  theme.dart                палитра, шрифты Onest/Nunito, Material 3
  models/person.dart        модель Person + расчёт дней/возраста
  data/greetings.dart       база поздравлений + определение пола (forPerson)
  data/gifts.dart           28 интересов → идеи подарков
  services/store.dart       персист в shared_preferences
  services/notifications.dart  flutter_local_notifications + tz
  widgets/common.dart       Avatar, DayBadge, SoftCard
  screens/
    onboarding.dart         5 слайдов
    home.dart               bottom nav + FAB
    today.dart              hero-дата, сегодня, ближайшие
    calendar.dart           месячный календарь с точками
    people.dart             поиск + фильтры + ушедшие
    stats.dart              метрики + график fl_chart
    person_detail.dart      возраст, подарки, поздравления, будильники
    person_form.dart        добавление/редактирование
```

## Соответствие документации

- Палитра, группы, типографика — раздел 4.
- Person + notif слоты (d7/d3/d2/d1/morning, d2=OFF по умолчанию) — раздел 6.
- `detectGender` / `ageWord` / `greetingsFor` — раздел 7, Приложение B.
- 5 слотов уведомлений в 9:00 по tz человека — разделы 8, 10.
- Онбординг с ключом `bday_onboard_v2` — раздел 9.
- Ключ хранилища `bday_people_v2` — раздел 6.

Нативные DEX/Manifest-патчи из разделов 11–13 в Flutter не нужны — fullscreen решается через `SystemChrome` и Material 3.

## Android: android/app/src/main/AndroidManifest.xml

В `<manifest>`:
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
```

В `<application>` (для пересоздания уведомлений после перезагрузки):
```xml
<receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver"
    android:exported="false">
  <intent-filter>
    <action android:name="android.intent.action.BOOT_COMPLETED"/>
  </intent-filter>
</receiver>
```

`minSdkVersion 23` в `android/app/build.gradle`.

## iOS

В `ios/Runner/Info.plist` добавь `NSPhotoLibraryUsageDescription`. Уведомления и tz работают из коробки.
