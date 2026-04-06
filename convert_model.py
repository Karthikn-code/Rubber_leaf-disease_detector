import tensorflow as tf
import os

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
h5_path = os.path.join(BASE_DIR, 'backend', 'model', 'best_model.h5')
keras_path = os.path.join(BASE_DIR, 'backend', 'model', 'best_model.keras')

if os.path.exists(h5_path):
    print(f"Loading {h5_path}...")
    model = tf.keras.models.load_model(h5_path, compile=False)
    print(f"Saving to {keras_path}...")
    model.save(keras_path)
    print("Conversion complete!")
else:
    print(f"File not found: {h5_path}")
