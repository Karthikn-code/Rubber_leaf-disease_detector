import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import '../widgets/common_widgets.dart';
import '../providers/history_store.dart';
import '../models/disease_item.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});
  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;
  bool _isLocal = false;

  @override
  void initState() { super.initState(); _fetch(); }

  Future<void> _fetch() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await http.get(Uri.parse('$kApiBaseUrl/analytics')).timeout(const Duration(seconds: 4));
      setState(() { _data = json.decode(res.body); _loading = false; _isLocal = false; });
    } catch (e) {
      // Fallback to Local History - Now more detailed
      final records = HistoryStore().records;
      final counts = <String, int>{
        'Anthracnose': 0,
        'Leaf_Spot': 0,
        'Dry_Leaf': 0,
        'Healthy': 0,
      };
      
      for (var r in records) {
        counts[r.label] = (counts[r.label] ?? 0) + 1;
      }
      
      final sorted = counts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      setState(() {
        _data = {
          'total_scans': records.length,
          'most_common': sorted.first.value > 0 ? sorted.first.key : 'None',
          'counts': counts,
        };
        _isLocal = true;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBg(child: Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.all(20), child: Row(children: [
          Text('nav_analytics'.tr(), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const Spacer(),
          IconButton(icon: const Icon(Icons.refresh, color: kCyan), onPressed: _fetch),
        ])),
        Expanded(child: _loading 
          ? const Center(child: CircularProgressIndicator()) 
          : _error != null 
            ? Center(child: Text('err_title'.tr(), style: const TextStyle(color: Colors.red)))
            : SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [
                 if (_isLocal)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: kOrange.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: kOrange.withOpacity(0.3))),
                        child: Row(children: [
                          const Icon(Icons.cloud_off, color: kOrange, size: 14),
                          const SizedBox(width: 8),
                          Text('viewing_local_stats'.tr(), style: const TextStyle(color: kOrange, fontSize: 11, fontWeight: FontWeight.bold)),
                        ]),
                      ),
                    ]),
                  ),
                // --- KPI CARDS ---
                Row(children: [
                  Expanded(child: _StatCard('Total Scans'.tr(), _data?['total_scans']?.toString() ?? '0', Icons.analytics_outlined, kCyan)),
                  const SizedBox(width: 16),
                  Expanded(child: _StatCard('Most Common'.tr(), _data?['most_common']?.toString().tr() ?? 'N/A', Icons.trending_up, kOrange)),
                ]),
                const SizedBox(height: 32),

                // --- VISUAL DISTRIBUTION ---
                _SectionHeader('Distribution Breakdown'.tr()),
                const SizedBox(height: 16),
                _DistributionChart(counts: Map<String, int>.from(_data?['counts'] ?? {})),
                const SizedBox(height: 32),

                // --- DISEASE BREAKDOWN LIST ---
                _SectionHeader('Detection History'.tr()),
                const SizedBox(height: 12),
                ... (DiseaseItem.all.map((d) => _DiseaseCountRow(
                  item: d, 
                  count: (_data?['counts']?[d.classLabel] ?? 0).toInt(),
                  total: (_data?['total_scans'] ?? 1).toInt(),
                ))),

                if (_isLocal)
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Center(child: Text('local_data_hint'.tr(), style: const TextStyle(color: kW40, fontSize: 11, fontStyle: FontStyle.italic))),
                  ),
              ]))),
      ])),
    ));
  }
}

class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const _StatCard(this.title, this.value, this.icon, this.color);
  @override
  Widget build(BuildContext context) => GCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      Icon(icon, color: color, size: 16),
      const SizedBox(width: 8),
      Text(title, style: const TextStyle(color: kW40, fontSize: 11, fontWeight: FontWeight.bold)),
    ]),
    const SizedBox(height: 12),
    Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
  ]));
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 3, height: 14, decoration: BoxDecoration(color: kCyan, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 10),
    Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
  ]);
}

class _DistributionChart extends StatelessWidget {
  final Map<String, int> counts;
  const _DistributionChart({required this.counts});
  @override
  Widget build(BuildContext context) {
    final total = counts.values.fold(0, (a, b) => a + b);
    if (total == 0) return const SizedBox();

    return Column(children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          height: 12,
          child: Row(children: DiseaseItem.all.map((d) {
            final flex = counts[d.classLabel] ?? 0;
            if (flex == 0) return const SizedBox();
            return Expanded(flex: flex, child: Container(color: d.color));
          }).toList()),
        ),
      ),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: DiseaseItem.all.map((d) {
        if ((counts[d.classLabel] ?? 0) == 0) return const SizedBox();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: d.color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(d.classLabel.tr(), style: const TextStyle(color: kW40, fontSize: 10)),
          ]),
        );
      }).toList()),
    ]);
  }
}

class _DiseaseCountRow extends StatelessWidget {
  final DiseaseItem item;
  final int count, total;
  const _DiseaseCountRow({required this.item, required this.count, required this.total});
  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (count / total) : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GCard(
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: item.color.withOpacity(0.12), shape: BoxShape.circle),
            child: Text(item.emoji, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.name.tr(), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(value: pct, backgroundColor: item.color.withOpacity(0.05), valueColor: AlwaysStoppedAnimation(item.color), minHeight: 4),
            ),
          ])),
          const SizedBox(width: 20),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(count.toString(), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            Text('${(pct * 100).toStringAsFixed(0)}%', style: const TextStyle(color: kW40, fontSize: 10)),
          ]),
        ]),
      ),
    );
  }
}

