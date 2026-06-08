import 'package:flutter/material.dart';
import '../theme.dart';

class _Slide {
  final String title, sub;
  final Color bg, fg;
  final IconData icon;
  const _Slide(this.title, this.sub, this.bg, this.fg, this.icon);
}

const _slides = [
  _Slide('Не забудь никого', 'Все дни рождения в одном месте. Всегда под рукой.',
      AppColors.ink, Colors.white, Icons.cake_rounded),
  _Slide('Умные уведомления', 'Напоминания за 7, 3 и 1 день. Никогда не опоздаешь.',
      AppColors.family, AppColors.ink, Icons.notifications_active_rounded),
  _Slide('Идеальные поздравления', '100+ шаблонов для любого стиля. Скопируй и отправь.',
      AppColors.friends, AppColors.ink, Icons.favorite_rounded),
  _Slide('Подарки и интересы', 'Укажи хобби — получи готовые идеи подарков.',
      AppColors.work, AppColors.ink, Icons.card_giftcard_rounded),
  _Slide('Всё готово!', 'Добавь первый день рождения и будь на шаг впереди.',
      AppColors.gold, AppColors.ink, Icons.check_circle_rounded),
];

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onDone;
  const OnboardingScreen({super.key, required this.onDone});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _i = 0;

  void _next() {
    if (_i < _slides.length - 1) {
      _ctrl.nextPage(
          duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
    } else {
      widget.onDone();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _slides[_i];
    final last = _i == _slides.length - 1;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      color: s.bg,
      child: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: last ? null : widget.onDone,
                child: Text(last ? '' : 'Пропустить',
                    style: TextStyle(color: s.fg.withOpacity(0.5))),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _ctrl,
                itemCount: _slides.length,
                onPageChanged: (v) => setState(() => _i = v),
                itemBuilder: (_, idx) {
                  final sl = _slides[idx];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                            color: sl.fg.withOpacity(0.12),
                            shape: BoxShape.circle),
                        child: Icon(sl.icon, size: 80, color: sl.fg),
                      ),
                      const SizedBox(height: 48),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(sl.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: sl.fg,
                                letterSpacing: -0.5)),
                      ),
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 36),
                        child: Text(sl.sub,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 15,
                                height: 1.6,
                                fontWeight: FontWeight.w500,
                                color: sl.fg.withOpacity(0.7))),
                      ),
                    ],
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (i) {
                final active = i == _i;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 8,
                  width: active ? 24 : 8,
                  decoration: BoxDecoration(
                      color: active ? s.fg : s.fg.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4)),
                );
              }),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: last ? AppColors.ink : s.fg.withOpacity(0.18),
                    foregroundColor: last
                        ? (s.bg == AppColors.ink ? AppColors.gold : Colors.white)
                        : s.fg,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                  ),
                  onPressed: _next,
                  child: Text(last ? 'Начать' : 'Далее',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
