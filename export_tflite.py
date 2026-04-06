"""
TFLite Model Export Script
Converts the trained .keras model to TensorFlow Lite format for offline inference.
"""

import os

# Suppress TF noise before importing
os.environ['TF_CPP_MIN_LOG_LEVEL']       = '3'
os.environ['TF_ENABLE_ONEDNN_OPTS']      = '0'
os.environ['ABSL_OVERRIDE_MIN_LOG_LEVEL'] = '2'

import logging
logging.getLogger('tensorflow').setLevel(logging.ERROR)

import tensorflow as tf  # type: ignore[import]
tf.get_logger().setLevel('ERROR')

# Paths
BASE_DIR          = os.path.dirname(os.path.abspath(__file__))
KERAS_MODEL_PATH  = os.path.join(BASE_DIR, 'ai_model', 'saved_models', 'best_model.h5')
TFLITE_DIR        = os.path.join(BASE_DIR, 'mobile_app', 'assets', 'model')
TFLITE_PATH       = os.path.join(TFLITE_DIR, 'rubber_leaf_model.tflite')
TFLITE_BACKUP     = os.path.join(BASE_DIR, 'backend', 'model', 'rubber_leaf_model.tflite')

# Ensure output directories exist
os.makedirs(TFLITE_DIR, exist_ok=True)

print(f"📂 Loading model from: {KERAS_MODEL_PATH}")
if not os.path.exists(KERAS_MODEL_PATH):
    print("❌ Model not found! Make sure best_model.keras exists in backend/model/")
    exit(1)

model = tf.keras.models.load_model(KERAS_MODEL_PATH, compile=False)
print(f"✅ Model loaded — Input: {model.input_shape}, Output: {model.output_shape}")

# Convert to TFLite with dynamic range quantization (smaller file, faster inference)
print("\n🔄 Converting to TFLite (dynamic range quantization)...")
converter = tf.lite.TFLiteConverter.from_keras_model(model)
converter.optimizations = [tf.lite.Optimize.DEFAULT]  # dynamic range quantization

tflite_model = converter.convert()

# Save to Flutter assets and backend/model
with open(TFLITE_PATH, 'wb') as f:
    f.write(tflite_model)

with open(TFLITE_BACKUP, 'wb') as f:
    f.write(tflite_model)

size_kb = os.path.getsize(TFLITE_PATH) / 1024
print(f"\n✅ TFLite model saved!")
print(f"   Flutter assets : {TFLITE_PATH}")
print(f"   Backup         : {TFLITE_BACKUP}")
print(f"   Size           : {size_kb:.1f} KB ({size_kb/1024:.2f} MB)")
print(f"\n🚀 Ready for offline Android/iOS deployment!")
