import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:developer';

class TfliteService {
  Interpreter? _interpreter;
  final List<String> _labels = ['Anthracnose', 'Dry_Leaf', 'Healthy', 'Leaf_Spot'];

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model/rubber_leaf_model.tflite');
      log("TFLite Model Loaded Successfully. Shape: ${_interpreter?.getInputTensor(0).shape}");
    } catch (e) {
      log("Error loading TFLite Model: $e");
    }
  }

  void dispose() {
    _interpreter?.close();
  }

  Future<Map<String, dynamic>?> predictFuture(CameraImage image) async {
    if (_interpreter == null) return null;
    
    img.Image? convertedImg = _convertCameraImage(image);
    if (convertedImg == null) return null;

    img.Image resizedImage = img.copyResize(convertedImg, width: 224, height: 224);

    var input = List.generate(
      1, (i) => List.generate(
        224, (y) => List.generate(
          224, (x) {
            final pixel = resizedImage.getPixel(x, y);
            return [pixel.r.toDouble(), pixel.g.toDouble(), pixel.b.toDouble()];
          }
        )
      )
    );

    var output = List.filled(1, List.filled(4, 0.0));

    try {
      _interpreter!.run(input, output);
    } catch (e) {
       log("Inference Error: $e");
       return null;
    }

    final scores = output[0];
    int maxIdx = 0;
    double maxScore = 0.0;
    for (int i=0; i<scores.length; i++) {
       if (scores[i] > maxScore) {
          maxScore = scores[i];
          maxIdx = i;
       }
    }

    return {
      'label': _labels[maxIdx],
      'confidence': maxScore,
    };
  }

  img.Image? _convertCameraImage(CameraImage image) {
    try {
      if (image.format.group == ImageFormatGroup.yuv420) {
        return _convertYUV420(image);
      } else if (image.format.group == ImageFormatGroup.bgra8888) {
        return _convertBGRA8888(image);
      }
    } catch (e) {
      log("Error converting camera image: $e");
    }
    return null;
  }

  img.Image _convertYUV420(CameraImage image) {
    var img2 = img.Image(width: image.width, height: image.height);
    Plane planeY = image.planes[0];
    Plane planeU = image.planes[1];
    Plane planeV = image.planes[2];

    final int uvRowStride = planeU.bytesPerRow;
    final int uvPixelStride = planeU.bytesPerPixel!;
    
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final int uvIndex = uvPixelStride * (x / 2).floor() + uvRowStride * (y / 2).floor();
        final int index = y * planeY.bytesPerRow + x;

        final yp = planeY.bytes[index];
        final up = planeU.bytes[uvIndex];
        final vp = planeV.bytes[uvIndex];

        int r = (yp + vp * 1436 / 1024 - 179).round();
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91).round();
        int b = (yp + up * 1814 / 1024 - 227).round();

        img2.setPixelRgb(x, y, r.clamp(0, 255), g.clamp(0, 255), b.clamp(0, 255));
      }
    }
    return img2;
  }

  img.Image _convertBGRA8888(CameraImage image) {
    return img.Image.fromBytes(width: image.width, height: image.height, bytes: image.planes[0].bytes.buffer, format: img.Format.uint8, numChannels: 4, order: img.ChannelOrder.bgra);
  }
}
