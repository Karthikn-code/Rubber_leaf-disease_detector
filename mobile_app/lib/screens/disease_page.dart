import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../widgets/common_widgets.dart';
import '../models/disease_item.dart';
import 'disease_detail_view.dart';

class DiseasePage extends StatelessWidget {
  const DiseasePage({super.key});

  @override
  Widget build(BuildContext context) => AppBg(child: Scaffold(
    backgroundColor: Colors.transparent,
    body: SafeArea(child: ListView(padding: const EdgeInsets.all(20), children: [
      Text('nav_diseases'.tr(), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 20),
      ...DiseaseItem.all.map((d) {
        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DiseaseDetailView(item: d))),
          child: Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(18), border: Border.all(color: d.color.withOpacity(0.4))),
            child: Row(children: [
              Hero(tag: 'emoji_${d.classLabel}', child: Text(d.emoji, style: const TextStyle(fontSize: 34))),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(d.name.tr(), style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                Text('${'Language'.tr() == 'Language' ? 'Class' : 'Class'.tr()}: ${d.classLabel.tr()}', style: const TextStyle(color: kW40, fontSize: 11)),
              ])),
              Tag(l: d.severity.tr(), c: d.color),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios_rounded, color: d.color.withOpacity(0.4), size: 14),
            ])),
        );
      }),
    ])),
  ));
}
