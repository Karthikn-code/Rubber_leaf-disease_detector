import tensorflow as tf
import os

model_path = os.path.join('ai_model', 'saved_models', 'best_model.h5')

try:
    print("Loading model without custom objects...")
    model = tf.keras.models.load_model(model_path, compile=False)
    print("Success!")
except Exception as e:
    import traceback
    traceback.print_exc()

try:
    print("\nLoading model with safe_mode=False...")
    model = tf.keras.models.load_model(model_path, compile=False, safe_mode=False)
    print("Success!")
except Exception as e:
    import traceback
    traceback.print_exc()
