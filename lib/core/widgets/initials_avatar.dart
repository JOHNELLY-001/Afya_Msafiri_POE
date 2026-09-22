import 'package:flutter/material.dart';

/// Officer/traveller avatar from a display name ("John Mushi" → "JM").
class InitialsAvatar extends StatelessWidget {
  final String name;
  final double radius;
  final Color? background;
  final Color? foreground;

  const InitialsAvatar({
    super.key,
    required this.name,
    this.radius = 24,
    this.background,
    this.foreground,
  });

  String get _initials {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: radius,
      backgroundColor: background ?? scheme.primary,
      foregroundColor: foreground ?? scheme.onPrimary,
      child: Text(
        _initials,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: radius * 0.75,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
