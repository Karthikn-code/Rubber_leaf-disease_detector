import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/disease_item.dart';
import '../widgets/common_widgets.dart';

class DiseaseDetailView extends StatelessWidget {
  final DiseaseItem item;
  const DiseaseDetailView({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return AppBg(child: Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          // ─── PARALLAX HEADER ───────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            backgroundColor: kBg,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              title: Text(item.classLabel.tr(), 
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, 
                  shadows: [Shadow(color: Colors.black, blurRadius: 10)])),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [item.color.withOpacity(0.3), kBg],
                  ),
                ),
                child: Center(
                  child: Hero(
                    tag: 'emoji_${item.classLabel}',
                    child: Text(item.emoji, style: const TextStyle(fontSize: 80)),
                  ),
                ),
              ),
            ),
          ),

          // ─── CONTENT ───────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(item.name.tr(), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(item.scientificName, style: const TextStyle(color: kW40, fontSize: 13, fontStyle: FontStyle.italic)),
                  ])),
                  Tag(l: item.severity.tr(), c: item.color),
                ]),
                const SizedBox(height: 24),

                _Section(title: 'ROOT CAUSE'.tr(), color: item.color, content: item.rootCause.tr(), icon: Icons.psychology_outlined),
                _SectionList(title: 'SYMPTOMS'.tr(), color: item.color, items: item.symptoms, icon: Icons.warning_amber_rounded),
                _SectionList(title: 'TREATMENT'.tr(), color: Colors.blueAccent, items: item.treatment, icon: Icons.medication_outlined),
                _SectionList(title: 'PREVENTION'.tr(), color: kGreen, items: item.prevention, icon: Icons.shield_outlined),
                _Section(title: 'ECONOMIC IMPACT'.tr(), color: kRed, content: item.economicImpact.tr(), icon: Icons.trending_down_rounded),

                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    ));
  }
}

class _Section extends StatelessWidget {
  final String title; final Color color; final String content; final IconData icon;
  const _Section({required this.title, required this.color, required this.content, required this.icon});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: GCard(
      border: color.withOpacity(0.2),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        ]),
        const Divider(color: kW06, height: 20),
        Text(content, style: const TextStyle(color: kW70, fontSize: 14, height: 1.5)),
      ]),
    ),
  );
}

class _SectionList extends StatelessWidget {
  final String title; final Color color; final List<String> items; final IconData icon;
  const _SectionList({required this.title, required this.color, required this.items, required this.icon});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: GCard(
      border: color.withOpacity(0.2),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        ]),
        const Divider(color: kW06, height: 20),
        ...items.map((i) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('• ', style: TextStyle(color: kW40, fontSize: 16)),
            Expanded(child: Text(i.tr(), style: const TextStyle(color: kW70, fontSize: 14, height: 1.4))),
          ]),
        )),
      ]),
    ),
  );
}
