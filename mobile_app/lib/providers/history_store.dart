import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/prediction_record.dart';

class HistoryStore extends ChangeNotifier {
  static final HistoryStore _i = HistoryStore._();
  factory HistoryStore() => _i;
  HistoryStore._();
  final List<PredictionRecord> _r = [];
  List<PredictionRecord> get records => _r.reversed.toList();

  Future<File> get _file async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/predictions_history.json');
  }

  Future<void> loadFromFile() async {
    try {
      final f = await _file;
      if (!f.existsSync()) return;
      final data = json.decode(await f.readAsString()) as List;
      _r.clear();
      _r.addAll(data.map((e) => PredictionRecord.fromMap(e as Map<String, dynamic>)));
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      final f = await _file;
      await f.writeAsString(json.encode(_r.map((e) => e.toJson()).toList()));
    } catch (_) {}
  }

  void add(PredictionRecord r) { _r.add(r); _save(); notifyListeners(); }
  void clear() { _r.clear(); _save(); notifyListeners(); }
}
