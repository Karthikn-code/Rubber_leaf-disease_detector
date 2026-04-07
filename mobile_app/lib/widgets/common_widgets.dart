import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart';

// ─── DESIGN TOKENS ───────────────────────────────────────────────────────────
const kBg      = Color(0xFF060B18);
String get kApiBaseUrl => kIsWeb ? Uri.base.origin : 'http://127.0.0.1:5000';
const kCard    = Color(0xFF111D35);
const kGreen   = Color(0xFF00E676);
const kGreenD  = Color(0xFF00C853);
const kCyan    = Color(0xFF00BCD4);
const kPurple  = Color(0xFF7C4DFF);
const kRed     = Color(0xFFFF5252);
const kOrange  = Color(0xFFFF6D00);
const kW70     = Color(0xB3FFFFFF);
const kW40     = Color(0x66FFFFFF);
const kW12     = Color(0x1FFFFFFF);
const kW06     = Color(0x0FFFFFFF);

final severityColors = {
  'None': kGreen, 'Medium': kOrange,
  'High': kRed,   'Critical': kPurple, 'Unknown': Colors.grey,
};

// ─── ANIMATED BG ──────────────────────────────────────────────────────────────
class AppBg extends StatelessWidget {
  final Widget child;
  const AppBg({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Stack(children: [
    Positioned.fill(child: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF060B18), Color(0xFF0A1628), Color(0xFF060B18)]),
      ),
    )),
    Positioned(top: -80, right: -80, child: Glow(s: 200, c: kGreen.withOpacity(0.06))),
    Positioned(bottom: -60, left: -60, child: Glow(s: 180, c: kCyan.withOpacity(0.05))),
    Positioned(top: 240, left: -30, child: Glow(s: 100, c: kPurple.withOpacity(0.04))),
    child,
  ]);
}

class Glow extends StatelessWidget {
  final double s; final Color c;
  const Glow({super.key, required this.s, required this.c});
  @override
  Widget build(BuildContext context) => Container(
    width: s, height: s,
    decoration: BoxDecoration(shape: BoxShape.circle, color: c,
      boxShadow: [BoxShadow(color: c, blurRadius: 60, spreadRadius: 10)]),
  );
}

// ─── GLASS CARD ───────────────────────────────────────────────────────────────
class GCard extends StatelessWidget {
  final Widget child; final EdgeInsets? pad;
  final Color? border; final BorderRadius? radius;
  const GCard({super.key, required this.child, this.pad, this.border, this.radius});
  @override
  Widget build(BuildContext context) => Container(
    padding: pad ?? const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: kCard, borderRadius: radius ?? BorderRadius.circular(18),
      border: Border.all(color: border ?? kW12),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 12, offset: const Offset(0,4))],
    ),
    child: child,
  );
}

// ─── BOUNCE SCALE ─────────────────────────────────────────────────────────────
class BounceScale extends StatefulWidget {
  final Widget child; final VoidCallback? onTap;
  const BounceScale({super.key, required this.child, this.onTap});
  @override
  State<BounceScale> createState() => _BounceScaleState();
}

class _BounceScaleState extends State<BounceScale> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.onTap != null ? (_) { setState(() => _pressed = false); widget.onTap!(); } : null,
      onTapCancel: widget.onTap != null ? () => setState(() => _pressed = false) : null,
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutBack,
        child: widget.child,
      ),
    );
  }
}

// ─── BUTTONS ──────────────────────────────────────────────────────────────────
class GBtn extends StatelessWidget {
  final IconData? icon; final String label;
  final bool loading; final VoidCallback? onTap;
  const GBtn({super.key, this.icon, required this.label, this.loading = false, this.onTap});
  @override
  Widget build(BuildContext context) => BounceScale(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200), height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        gradient: onTap != null ? const LinearGradient(colors: [kGreenD, kCyan]) : null,
        color: onTap == null ? kW12 : null,
        boxShadow: onTap != null
          ? [BoxShadow(color: kGreen.withOpacity(0.35), blurRadius: 16, offset: const Offset(0,4))]
          : [],
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        if (loading)
          const SizedBox(width: 17, height: 17, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5))
        else if (icon != null)
          Icon(icon!, color: onTap != null ? Colors.black : kW40, size: 19),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(
          color: onTap != null ? Colors.black : kW40,
          fontWeight: FontWeight.w800, fontSize: 13)),
      ]),
    ));
}

class OBtn extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback? onTap;
  const OBtn({super.key, required this.icon, required this.label, this.onTap});
  @override
  Widget build(BuildContext context) => BounceScale(
    onTap: onTap,
    child: Container(height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: kW12), color: kCard),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: kW70, size: 17),
        const SizedBox(width: 7),
        Text(label, style: const TextStyle(color: kW70, fontWeight: FontWeight.w600, fontSize: 13)),
      ]),
    ));
}

class Tag extends StatelessWidget {
  final String l; final Color c;
  const Tag({super.key, required this.l, required this.c});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: c.withOpacity(0.12), borderRadius: BorderRadius.circular(20),
      border: Border.all(color: c.withOpacity(0.4))),
    child: Text(l, style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w700)));
}
