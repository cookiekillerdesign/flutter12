import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'theme.dart';
import 'services/store.dart';
import 'services/notifications.dart';
import 'screens/onboarding.dart';
import 'screens/home.dart';

final store = Store();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru');
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.bg,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  await store.init();
  await Notifications.init();
  await Notifications.rescheduleAll(store.people);
  runApp(const BirthdayzApp());
}

class BirthdayzApp extends StatelessWidget {
  const BirthdayzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Birthdayz Alarm',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: const Locale('ru'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ru'), Locale('en')],
      home: const _Gate(),
    );
  }
}

class _Gate extends StatefulWidget {
  const _Gate();
  @override
  State<_Gate> createState() => _GateState();
}

class _GateState extends State<_Gate> {
  bool _splash = true;
  late bool _onboard;

  @override
  void initState() {
    super.initState();
    _onboard = !store.onboardDone;
    Future.delayed(const Duration(milliseconds: 1600),
        () => mounted ? setState(() => _splash = false) : null);
  }

  @override
  Widget build(BuildContext context) {
    if (_splash) return const _Splash();
    if (_onboard) {
      return OnboardingScreen(onDone: () async {
        await store.setOnboardDone();
        setState(() => _onboard = false);
      });
    }
    return const HomeScreen();
  }
}

class _Splash extends StatelessWidget {
  const _Splash();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.2),
                  shape: BoxShape.circle),
              child: const Icon(Icons.cake_rounded,
                  size: 52, color: AppColors.gold),
            ),
            const SizedBox(height: 20),
            Text('Birthdayz Alarm', style: AppTheme.numbers(30)),
          ],
        ),
      ),
    );
  }
}
