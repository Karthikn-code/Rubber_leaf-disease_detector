import 'package:camera/camera.dart';
import 'dart:developer';

class TfliteService {
  Future<void> loadModel() async {
    log("TFLite Model Load Stubbed (Web).");
  }

  void dispose() {
    // Stub
  }

  Future<Map<String, dynamic>?> predictFile(dynamic file) async {
    log("TFLite file prediction stubbed (Web). Using Online API instead.");
    return null;
  }

  Future<Map<String, dynamic>?> predictFuture(CameraImage image) async {
    log("TFLite prediction stubbed (Web). Offline scanning not supported in browser.");
    return null;
  }
}
