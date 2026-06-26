import 'package:flutter/material.dart';
import '../theme.dart';

/// Wiederverwendbare Editorial-Bausteine: Kicker-Label, Haarlinie,
/// Section-Header (Kicker + Serif-Headline) und Werte-Zeile mit Punktführung.

/// Kleines, weit gesperrtes Großbuchstaben-Label über Überschriften.
class Kicker extends StatelessWidget {
  const Kicker(this.text, {super.key, this.color});
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.8,
        color: color ?? context.terracotta,
      ),
    );
  }
}

/// Dünne Trennlinie im Raster.
class Hairline extends StatelessWidget {
  const Hairline({super.key, this.top = 0, this.bottom = 0});
  final double top;
  final double bottom;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(top: top, bottom: bottom),
        child: Container(height: 1, color: context.borderColor),
      );
}

/// Kicker + große Serif-Überschrift, optional mit Element rechts.
class EditorialHeader extends StatelessWidget {
  const EditorialHeader({
    super.key,
    required this.kicker,
    required this.title,
    this.titleSize = 30,
    this.trailing,
  });
  final String kicker;
  final String title;
  final double titleSize;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final head = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Kicker(kicker),
        const SizedBox(height: Sp.sm),
        Text(title, style: serif(size: titleSize, color: context.inkColor)),
      ],
    );
    if (trailing == null) return head;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [Expanded(child: head), trailing!],
    );
  }
}

/// Label (gesperrt, muted) links — Wert (Serif) rechts. Optional Punktführung.
class StatRow extends StatelessWidget {
  const StatRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.leaders = false,
    this.valueSize = 15,
  });
  final String label;
  final String value;
  final Color? valueColor;
  final bool leaders;
  final double valueSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: context.mutedColor,
            ),
          ),
          if (leaders)
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 8, right: 8, bottom: 4),
                height: 1,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                        color: context.borderColor,
                        width: 1,
                        style: BorderStyle.solid),
                  ),
                ),
              ),
            )
          else
            const Spacer(),
          Text(
            value,
            style: serif(
                size: valueSize,
                color: valueColor ?? context.inkColor,
                spacing: 0),
          ),
        ],
      ),
    );
  }
}

/// Hervorgehobener Hinweis-/Beobachtungsblock (linker Akzentstrich).
class PullQuote extends StatelessWidget {
  const PullQuote({super.key, required this.text, this.kicker});
  final String text;
  final String? kicker;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: context.terracotta, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (kicker != null) ...[
            Kicker(kicker!),
            const SizedBox(height: Sp.sm),
          ],
          Text(
            text,
            style: serif(
                size: 15,
                weight: FontWeight.w500,
                color: context.inkColor,
                height: 1.45,
                spacing: 0,
                style: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}
