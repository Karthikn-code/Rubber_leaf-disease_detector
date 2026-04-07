import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../services/tflite_service.dart';
import '../widgets/common_widgets.dart';
import '../providers/history_store.dart';
import '../models/prediction_record.dart';
import '../models/disease_item.dart';

class RealtimeScanPage extends StatefulWidget {
  const RealtimeScanPage({Key? key}) : super(key: key);

  @override
  State<RealtimeScanPage> createState() => _RealtimeScanPageState();
}

class _RealtimeScanPageState extends State<RealtimeScanPage> {
  CameraController? _cameraController;
  final TfliteService _tfliteService = TfliteService();
  bool _isProcessing = false;
  String _predictedLabel = "Scanning...";
  double _confidence = 0.0;
  String? _errorMessage;

  int _consecutiveHighConfidenceCount = 0;
  final int _lockThreshold = 8;
  bool _didLock = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _tfliteService.loadModel();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) setState(() => _errorMessage = "No cameras found. Please connect a webcam.");
        return;
      }
      
      _cameraController = CameraController(
        cameras.firstWhere((cam) => cam.lensDirection == CameraLensDirection.back, orElse: () => cameras.first),
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      
      if (!mounted) return;
      setState(() {});

      _cameraController!.startImageStream((CameraImage image) async {
        if (_isProcessing || _didLock) return; // Drop frame if processing or locked
        _isProcessing = true;

        final result = await _tfliteService.predictFuture(image);
        
        if (result != null && mounted && !_didLock) {
          final label = result['label'];
          final conf = result['confidence'];

          // Auto-Lock Logic: Ignore 'Healthy' because we want to lock onto diseases
          if (conf > 0.88 && label != 'Healthy') {
             _consecutiveHighConfidenceCount++;
          } else {
             _consecutiveHighConfidenceCount = 0;
          }

          if (_consecutiveHighConfidenceCount >= _lockThreshold) {
             _didLock = true;
             await _lockAndSaveResult(label, conf);
          }

          if (mounted && !_didLock) {
            setState(() {
              _predictedLabel = label;
              _confidence = conf;
            });
          }
        }
        _isProcessing = false;
      });
    } catch (e) {
      debugPrint("Camera Error: $e");
      if (mounted) setState(() => _errorMessage = "Camera Error: Missing camera support on this platform.");
    }
  }

  Future<void> _lockAndSaveResult(String label, double confidence) async {
    if (mounted) setState(() { _errorMessage = "Disease Locked! Syncing to Server..."; });
    
    // Stop camera temporarily
    try { await _cameraController?.stopImageStream(); } catch(_) {}
    XFile? pic;
    try { pic = await _cameraController?.takePicture(); } catch(_) {}

    // 1. Sync Analytics to Flask Backend
    try {
      final reqBody = jsonEncode({'label': label, 'confidence': confidence});
      await http.post(
           Uri.parse('$kApiBaseUrl/log_prediction'), 
           headers: {'Content-Type': 'application/json'},
           body: reqBody
      ).timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint("Backend Sync Error: $e");
    }

    // 2. Save offline record
    final item = DiseaseItem.all.firstWhere((d) => d.classLabel == label, orElse: () => DiseaseItem.all.last);
    Position? pos;
    try { pos = await Geolocator.getCurrentPosition(timeLimit: const Duration(seconds: 2)); } catch(_) {}

    HistoryStore().add(PredictionRecord(
      imagePath: pic?.path ?? "", 
      label: label,
      commonName: label,
      confidence: confidence,
      severity: item.severity,
      urgency: "",
      timestamp: DateTime.now(),
      allScores: {label: confidence},
      latitude: pos?.latitude,
      longitude: pos?.longitude,
    ));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Diagnostic result saved & analytics synced successfully!"),
      backgroundColor: Colors.green,
    ));
    Navigator.pop(context); // Return to Predict Page
  }

  @override
  void dispose() {
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    _tfliteService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent, fontSize: 16),
            ),
          ),
        ),
      );
    }

    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.greenAccent)),
      );
    }

    // Determine the border color based on disease detection
    Color borderColor = Colors.white30;
    if (_confidence > 0.7) {
      borderColor = _predictedLabel == 'Healthy' ? Colors.green : Colors.redAccent;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Live Scan").tr(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Camera Preview Full Screen
          Positioned.fill(
            child: CameraPreview(_cameraController!),
          ),
          
          // Scanner Overlay overlay
          Positioned.fill(
             child: CustomPaint(
                painter: ScannerOverlayPainter(),
             ),
          ),

          // Prediction Results
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderColor, width: 2),
                boxShadow: [
                  BoxShadow(color: borderColor.withOpacity(0.3), blurRadius: 12)
                ]
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _predictedLabel.tr(),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Confidence: ${(_confidence * 100).toStringAsFixed(1)}%",
                    style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    // Cut out a rounded rectangle in the center
    final scanArea = Rect.fromCenter(center: Offset(size.width/2, size.height/2), width: size.width * 0.8, height: size.width * 0.8);
    
    final path1 = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final path2 = Path()..addRRect(RRect.fromRectAndRadius(scanArea, const Radius.circular(24)));
    
    canvas.drawPath(Path.combine(PathOperation.difference, path1, path2), paint);
    
    // Draw edges for the scan area
    final edgePaint = Paint()
      ..color = Colors.white54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawRRect(RRect.fromRectAndRadius(scanArea, const Radius.circular(24)), edgePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
