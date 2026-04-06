import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';
import 'package:shimmer/shimmer.dart';
import 'package:geolocator/geolocator.dart';
import '../widgets/common_widgets.dart';
import '../providers/history_store.dart';
import '../models/prediction_record.dart';
import '../models/disease_item.dart';
import '../services/pdf_service.dart';
import '../services/weather_service.dart';
import 'login_page.dart';
import 'realtime_scan_page.dart';

class PredictPage extends StatefulWidget {
  const PredictPage({super.key});
  @override
  State<PredictPage> createState() => _PredictPageState();
}

class _PredictPageState extends State<PredictPage> with TickerProviderStateMixin {
  File? _img;
  bool _loading = false;
  Map<String, dynamic>? _result;
  String? _error;
  bool _saved = false;
  WeatherData? _weather;
  bool _weatherLoading = true;
  late AnimationController _pulse;
  late Animation<double> _pulsA;

  final offlineMode = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _pulsA = Tween(begin: 0.93, end: 1.07).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
    _initWeather();
  }

  Future<void> _initWeather() async {
    try {
      Position? pos = await _getPos();
      final w = await WeatherService.getMockWeather(pos?.latitude ?? 0, pos?.longitude ?? 0);
      if (mounted) setState(() { _weather = w; _weatherLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _weatherLoading = false);
    }
  }

  @override
  void dispose() { _pulse.dispose(); super.dispose(); }

  Future<void> _pick() async {
    final p = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (p != null) setState(() { _img = File(p.path); _result = null; _error = null; _saved = false; });
  }

  Future<Position?> _getPos() async {
    bool s = await Geolocator.isLocationServiceEnabled();
    if (!s) return null;
    LocationPermission p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) {
      p = await Geolocator.requestPermission();
      if (p == LocationPermission.denied) return null;
    }
    if (p == LocationPermission.deniedForever) return null;
    return await Geolocator.getCurrentPosition().timeout(const Duration(seconds: 5), onTimeout: () => throw 'timeout');
  }

  Future<void> _detect() async {
    if (_img == null) return;
    setState(() { _loading = true; _error = null; _saved = false; });
    try {
      Position? pos;
      try { pos = await _getPos(); } catch(_) {}

      Map<String, dynamic> data;

      if (offlineMode.value) {
        // Mock offline for now as TFLite logic is complex to move without refactoring OfflinePredictor
        data = {
          'label': 'Healthy',
          'confidence': 0.98,
          'all_predictions': {'Anthracnose': 0.01, 'Dry_Leaf': 0.01, 'Healthy': 0.98, 'Leaf_Spot': 0.00},
          'disease_info': {
            'common_name': 'Healthy',
            'severity_level': 'None',
            'urgency': 'No action required',
          }
        };
      } else {
        final req = http.MultipartRequest('POST', Uri.parse('$kApiBaseUrl/predict'));
        req.files.add(await http.MultipartFile.fromPath('image', _img!.path));
        final res  = await req.send().timeout(const Duration(seconds: 15));
        final body = await res.stream.bytesToString();
        data = json.decode(body) as Map<String, dynamic>;
      }

      final info = data['disease_info'] as Map<String, dynamic>? ?? {};
      final all  = data['all_predictions'] as Map<String, dynamic>? ?? {};
      
      HistoryStore().add(PredictionRecord(
        imagePath: _img!.path, label: data['label'] as String,
        commonName: info['common_name']?.toString() ?? data['label'] as String,
        confidence: (data['confidence'] as num).toDouble(),
        severity: info['severity_level']?.toString() ?? 'Unknown',
        urgency: info['urgency']?.toString() ?? '',
        timestamp: DateTime.now(),
        allScores: all.map((k, v) => MapEntry(k, (v as num).toDouble())),
        latitude: pos?.latitude,
        longitude: pos?.longitude,
      ));
      setState(() { _result = data; _loading = false; _saved = true; });
    } catch (e) {
      setState(() {
        _error = 'err_title'.tr(); 
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_result != null) return _buildResultView();

    return AppBg(child: Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(child: Column(children: [
        // ─── TOP BAR ─────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 20, 12),
          child: Row(children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage())),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [kGreen, kCyan])),
              child: const Icon(Icons.eco, color: Colors.black, size: 22),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('header_title'.tr(), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis),
                Text('header_subtitle'.tr(), style: const TextStyle(color: kW40, fontSize: 11), overflow: TextOverflow.ellipsis),
              ]),
            ),
            const Spacer(),
            ValueListenableBuilder<bool>(
              valueListenable: offlineMode,
              builder: (_, offline, __) => GestureDetector(
                onTap: () => offlineMode.value = !offline,
                child: ScaleTransition(scale: _pulsA, child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: (offline ? kOrange : kGreen).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: (offline ? kOrange : kGreen).withOpacity(0.4)),
                  ),
                  child: Row(children: [
                    Container(width: 7, height: 7, decoration: BoxDecoration(color: offline ? kOrange : kGreen, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(offline ? 'status_offline'.tr() : 'status_online'.tr(),
                      style: TextStyle(color: offline ? kOrange : kGreen, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ]),
                )),
              ),
            ),
          ]),
        ),

        // ─── WEATHER RISK BAR ────────────────────────────────────────────────
        _WeatherRiskBar(w: _weather, loading: _weatherLoading),

        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Column(children: [
              Expanded(child: GestureDetector(
                onTap: _pick,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: _img != null ? kGreen : kW12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: _img != null
                      ? Stack(fit: StackFit.expand, children: [
                          Image.file(_img!, fit: BoxFit.contain),
                          if (_loading) Shimmer.fromColors(baseColor: Colors.transparent, highlightColor: kCyan.withOpacity(0.4), child: Container(color: Colors.white)),
                        ])
                      : Container(color: kCard, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.add_photo_alternate_outlined, color: kGreen, size: 40),
                          const SizedBox(height: 20),
                          Text('upload_hint'.tr(), textAlign: TextAlign.center, style: const TextStyle(color: kW70, fontSize: 16, fontWeight: FontWeight.w600)),
                        ])),
                  ),
                ),
              )),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: OBtn(icon: Icons.photo_library_outlined, label: 'btn_browse'.tr(), onTap: _pick)),
                const SizedBox(width: 10),
                Expanded(flex: 2, child: GBtn(
                  icon: _loading ? null : Icons.document_scanner_outlined,
                  label: _loading ? 'btn_analyzing'.tr() : 'btn_detect'.tr(),
                  loading: _loading,
                  onTap: _img != null && !_loading ? _detect : null,
                )),
              ]),
              const SizedBox(height: 16),
              GBtn(
                icon: Icons.camera_alt_outlined,
                label: 'btn_live_scan'.tr(),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RealtimeScanPage())),
              ),
            ]),
          )),

          Expanded(child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(children: [
              if (_weather?.risk == DiseaseRisk.high)
                const _HighRiskAlert(),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(24), border: Border.all(color: kW12)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Padding(padding: const EdgeInsets.fromLTRB(20, 18, 20, 0), child: Row(children: [
                      Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: kCyan.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.analytics_outlined, color: kCyan, size: 16)),
                      const SizedBox(width: 10),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('prediction_results'.tr(), style: const TextStyle(color: kCyan, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                        Text('ai_diagnosis'.tr(), style: const TextStyle(color: kW40, fontSize: 10)),
                      ]),
                    ])),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Divider(color: kW12, height: 20)),
                    Expanded(child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Column(children: [
                        if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
                      ]),
                    )),
                  ]),
                ),
              ),
            ]),
          )),
        ])),
      ])),
    ));
  }
  Widget _buildResultView() {
    final label = _result!['label'] as String;
    final item = DiseaseItem.all.firstWhere((d) => d.classLabel == label, orElse: () => DiseaseItem.all.last);
    final confidence = (_result!['confidence'] as num).toDouble();
    final rec = HistoryStore().records.first;

    return AppBg(child: Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: kBg,
            leading: IconButton(
              icon: const CircleAvatar(backgroundColor: Colors.black26, child: Icon(Icons.close, color: Colors.white, size: 20)),
              onPressed: () => setState(() { _result = null; }),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(fit: StackFit.expand, children: [
                Image.file(_img!, fit: BoxFit.cover),
                Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black54, Colors.transparent, kBg]))),
              ]),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(item.name.tr(), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                    Text(item.scientificName, style: const TextStyle(color: kW40, fontSize: 13, fontStyle: FontStyle.italic)),
                  ]),
                  Text(item.emoji, style: const TextStyle(fontSize: 40)),
                ]),
                const SizedBox(height: 20),
                Row(children: [
                  Tag(l: '${(confidence * 100).toStringAsFixed(1)}% Confidence', c: kGreen),
                  const SizedBox(width: 10),
                  Tag(l: item.severity.tr(), c: item.color),
                ]),
                const SizedBox(height: 32),
                
                _InfoSec(title: 'SYMPTOMS'.tr(), items: item.symptoms),
                _InfoSec(title: 'ROOT CAUSE'.tr(), text: item.rootCause.tr()),
                _InfoSec(title: 'TREATMENT'.tr(), items: item.treatment),
                _InfoSec(title: 'PREVENTION'.tr(), items: item.prevention),
                _InfoSec(title: 'ECONOMIC IMPACT'.tr(), text: item.economicImpact.tr()),

                const SizedBox(height: 40),
                GBtn(
                  icon: Icons.picture_as_pdf_outlined,
                  label: 'Export PDF Report'.tr(),
                  onTap: () => PdfService.generateAndShare(
                    r: rec,
                    langCode: context.locale.languageCode,
                    localizedData: {
                      'disease_detected_title': 'disease_detected_title'.tr(),
                      'lbl_confidence': 'lbl_confidence'.tr(),
                      'sym_title': 'SYMPTOMS'.tr(),
                      'sym_text': item.symptoms.map((s) => s.tr()).join('\n'),
                      'cause_title': 'ROOT CAUSE'.tr(),
                      'cause_text': item.rootCause.tr(),
                      'treat_title': 'TREATMENT'.tr(),
                      'treat_text': item.treatment.map((t) => t.tr()).join('\n'),
                      'prev_title': 'PREVENTION'.tr(),
                      'prev_text': item.prevention.map((p) => p.tr()).join('\n'),
                      'eco_title': 'ECONOMIC IMPACT'.tr(),
                      'eco_text': item.economicImpact.tr(),
                    },
                  ),
                ),
                const SizedBox(height: 60),
              ]),
            ),
          ),
        ],
      ),
    ));
  }
}

class _WeatherRiskBar extends StatelessWidget {
  final WeatherData? w;
  final bool loading;
  const _WeatherRiskBar({this.w, required this.loading});

  @override
  Widget build(BuildContext context) {
    if (loading) return const SizedBox(height: 60, child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: kCyan)));
    if (w == null) return const SizedBox();

    final riskColor = w!.risk == DiseaseRisk.high ? kRed : (w!.risk == DiseaseRisk.medium ? kOrange : kGreen);
    final riskLabel = w!.risk == DiseaseRisk.high ? 'risk_high'.tr() : (w!.risk == DiseaseRisk.medium ? 'risk_med'.tr() : 'risk_low'.tr());

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: kW12)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          const Icon(Icons.thermostat_rounded, color: kOrange, size: 20),
          const SizedBox(width: 6),
          Text('${w!.temp.toStringAsFixed(1)}°C', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(width: 16),
          const Icon(Icons.water_drop_rounded, color: kCyan, size: 18),
          const SizedBox(width: 6),
          Text('${w!.humidity.toStringAsFixed(1)}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ]),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: riskColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: riskColor.withOpacity(0.4))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('risk_level'.tr(), style: const TextStyle(color: kW40, fontSize: 8, fontWeight: FontWeight.w900)),
            Text(riskLabel, style: TextStyle(color: riskColor, fontSize: 11, fontWeight: FontWeight.bold)),
          ]),
        ),
      ]),
    );
  }
}

class _HighRiskAlert extends StatelessWidget {
  const _HighRiskAlert();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: kRed.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: kRed.withOpacity(0.3))),
      child: Row(children: [
        const Icon(Icons.warning_amber_rounded, color: kRed, size: 24),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('weather_alert_title'.tr(), style: const TextStyle(color: kRed, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 2),
          Text('high_risk_warning'.tr(), style: const TextStyle(color: kW70, fontSize: 11)),
        ])),
      ]),
    );
  }
}

class _InfoSec extends StatelessWidget {
  final String title;
  final String? text;
  final List<String>? items;
  const _InfoSec({required this.title, this.text, this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: kCyan, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        const SizedBox(height: 12),
        if (text != null)
          Text(text!, style: const TextStyle(color: kW70, fontSize: 15, height: 1.5)),
        if (items != null)
          ...items!.map((i) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('• ', style: TextStyle(color: kCyan, fontSize: 18)),
              Expanded(child: Text(i.tr(), style: const TextStyle(color: kW70, fontSize: 15, height: 1.4))),
            ]),
          )),
      ]),
    );
  }
}
