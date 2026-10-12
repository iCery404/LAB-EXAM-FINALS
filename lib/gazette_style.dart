import 'package:flutter/material.dart';

// Colors used on all screens
const Color paperColor = Color(0xFFF5F0E8);
const Color cardPaper = Color(0xFFFBF8F2);
const Color inkColor = Color(0xFF3B2A20);
const Color rustColor = Color(0xFFC4622D);
const Color oliveColor = Color(0xFF6B7A4A);
const Color lineColor = Color(0xFFD9CFC0);
const Color softInk = Color(0xFF7A6A5E);

// Small letter-spaced label style
TextStyle labelStyle({double size = 11, Color color = rustColor}) {
  return TextStyle(
    fontFamily: 'sans-serif',
    fontSize: size,
    fontWeight: FontWeight.w700,
    letterSpacing: 2,
    color: color,
  );
}

// Paper-like card with soft shadow
class PaperCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  const PaperCard({
    super.key,
    required this.child,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          color: cardPaper,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: lineColor),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F3B2A20),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

// Orange label with a line on each side, like "EXCLUSIVE REPORT"
class SectionLabel extends StatelessWidget {
  final String text;

  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: lineColor)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(text, style: labelStyle(size: 10)),
        ),
        Expanded(child: Container(height: 1, color: lineColor)),
      ],
    );
  }
}

// Big centered heading, like "THE ARCHIVES"
class Masthead extends StatelessWidget {
  final String title;
  final String subtitle;

  const Masthead({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: labelStyle(size: 9, color: softInk),
          ),
          const SizedBox(height: 10),
          Container(height: 1, color: lineColor),
        ],
      ),
    );
  }
}

// Green for success, orange-red for failure
class MessageBanner extends StatelessWidget {
  final String text;
  final bool success;

  const MessageBanner({super.key, required this.text, required this.success});

  @override
  Widget build(BuildContext context) {
    final color = success ? oliveColor : rustColor;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: success ? const Color(0xFFE6EBD9) : const Color(0xFFF6E1D6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(success ? Icons.check_circle : Icons.error, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}