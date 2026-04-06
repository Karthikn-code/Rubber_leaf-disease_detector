import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import '../widgets/common_widgets.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});
  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _fetch(); }

  Future<void> _fetch() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await http.get(Uri.parse('$kApiBaseUrl/analytics')).timeout(const Duration(seconds: 8));
      setState(() { _data = json.decode(res.body); _loading = false; });
    } catch (e) {
      setState(() { _error = 'Cannot reach server.'; _loading = false; });
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
                _Stat('Total Scans'.tr(), _data?['total_scans']?.toString() ?? '0'),
                const SizedBox(height: 20),
                _Stat('Most Common'.tr(), _data?['most_common']?.toString() ?? 'N/A'),
              ]))),
      ])),
    ));
  }
}

class _Stat extends StatelessWidget {
  final String t, v;
  const _Stat(this.t, this.v);
  @override
  Widget build(BuildContext context) => GCard(child: Column(children: [
    Text(t, style: const TextStyle(color: kW40, fontSize: 13)),
    const SizedBox(height: 8),
    Text(v, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
  ]));
}
