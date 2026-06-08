import 'dart:convert';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/person.dart';

class Avatar extends StatelessWidget {
  final Person person;
  final double size;
  const Avatar(this.person, {super.key, this.size = 56});

  @override
  Widget build(BuildContext context) {
    final color = person.deceased ? AppColors.deceased : AppColors.group(person.group);
    Widget child;
    if (person.photo != null && person.photo!.isNotEmpty) {
      child = ClipOval(
        child: Image.memory(base64Decode(person.photo!),
            width: size, height: size, fit: BoxFit.cover),
      );
    } else {
      final initials = person.name.trim().isEmpty
          ? '?'
          : person.name.trim().split(' ').take(2).map((w) => w[0]).join();
      child = Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Text(initials.toUpperCase(),
            style: AppTheme.numbers(size * 0.36, color: AppColors.ink)),
      );
    }
    return SizedBox(width: size, height: size, child: child);
  }
}

class DayBadge extends StatelessWidget {
  final int days;
  const DayBadge(this.days, {super.key});

  @override
  Widget build(BuildContext context) {
    final (label, color) = _meta(days);
    if (label == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.ink)),
    );
  }

  static (String?, Color) _meta(int d) {
    if (d == 0) return ('Сегодня', AppColors.gold);
    if (d == 1) return ('Завтра', AppColors.friends);
    if (d <= 3) return ('Через $d дня', AppColors.work);
    if (d <= 7) return ('Через $d дней', AppColors.family);
    return (null, Colors.transparent);
  }
}

class SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  final VoidCallback? onTap;
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
