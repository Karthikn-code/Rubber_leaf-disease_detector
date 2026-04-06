import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../widgets/common_widgets.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  @override
  Widget build(BuildContext context) => AppBg(child: Scaffold(
    backgroundColor: Colors.transparent,
    body: SafeArea(child: ListView(padding: const EdgeInsets.all(20), children: [
      const SizedBox(height: 10),
      Center(child: Column(children: [
        Container(width: 90, height: 90,
          decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [kGreen, kCyan])),
          child: const Icon(Icons.eco_rounded, color: Colors.black, size: 48)),
        const SizedBox(height: 14),
        Text('app_title'.tr(), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
      ])),
      const SizedBox(height: 28),
      _Section('🤖 ' + 'AI Model'.tr(), kGreen, ['MobileNetV2 — Transfer Learning'.tr(), 'Accuracy: 99.7%'.tr()]),
      const SizedBox(height: 12),
      _Section('🏗️ ' + 'Tech Stack'.tr(), kPurple, ['Flutter'.tr(), 'Python Flask'.tr(), 'OpenCV'.tr()]),
    ])),
  ));
}

class _Section extends StatelessWidget {
  final String title; final Color accent; final List<String> items;
  const _Section(this.title, this.accent, this.items);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(18), border: Border.all(color: accent.withOpacity(0.3))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: TextStyle(color: accent, fontSize: 14, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      ...items.map((i) => Text(i, style: const TextStyle(color: kW70, fontSize: 13))),
    ]));
}
