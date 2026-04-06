import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import '../widgets/common_widgets.dart';
import '../providers/history_store.dart';
import '../models/prediction_record.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});
  @override
  Widget build(BuildContext context) => AppBg(child: Scaffold(
    backgroundColor: Colors.transparent,
    body: SafeArea(child: Column(children: [
      Padding(padding: const EdgeInsets.all(20), child: Row(children: [
        Text('nav_history'.tr(), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        const Spacer(),
        IconButton(icon: const Icon(Icons.delete_sweep, color: kRed), onPressed: () => HistoryStore().clear()),
      ])),
      Expanded(child: ListenableBuilder(
        listenable: HistoryStore(),
        builder: (_, __) {
          final recs = HistoryStore().records;
          if (recs.isEmpty) return Center(child: Text('No history yet.'.tr()));
          return ListView.builder(
            itemCount: recs.length,
            itemBuilder: (ctx, i) => _HistoryCard(r: recs[i]),
          );
        },
      )),
    ])),
  ));
}

class _HistoryCard extends StatelessWidget {
  final PredictionRecord r;
  const _HistoryCard({required this.r});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(12)),
    child: Row(children: [
      ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(r.imagePath), width: 60, height: 60, fit: BoxFit.cover)),
      const SizedBox(width: 15),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(r.commonName.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        Text(DateFormat('dd MMM yyyy').format(r.timestamp), style: const TextStyle(color: kW40, fontSize: 12)),
        if (r.latitude != null) 
          Text('Lat: ${r.latitude!.toStringAsFixed(4)}, Lon: ${r.longitude!.toStringAsFixed(4)}', 
            style: const TextStyle(color: kCyan, fontSize: 11)),
      ])),
      Tag(l: '${(r.confidence * 100).toStringAsFixed(0)}%', c: kCyan),
    ]),
  );
}
