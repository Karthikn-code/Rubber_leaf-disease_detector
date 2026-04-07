import os
import random
import numpy as np
import cv2
import tensorflow as tf

# Configuration
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
TFLITE_MODEL_PATH = os.path.join(BASE_DIR, 'mobile_app', 'assets', 'model', 'rubber_leaf_model.tflite')
DATASET_DIR = os.path.join(BASE_DIR, 'Rubber_Leaf_Dataset', 'Rubber_Leaf_Dataset', 'Compressed_Dataset')
CLASS_NAMES = ['Anthracnose', 'Dry_Leaf', 'Healthy', 'Leaf_Spot']
SAMPLE_SIZE = 50  # Number of images to test per class

def load_and_preprocess_image(img_path):
    try:
        img = cv2.imread(img_path)
        if img is None: return None
        img = cv2.resize(img, (224, 224))
        img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        # Match Flutter app logic: Give raw [0, 255] floats because preprocess_input is built into the model
        return np.expand_dims(img.astype(np.float32), axis=0)
    except Exception as e:
        print(f"Error processing {img_path}: {e}")
        return None

def verify_accuracy():
    print(f"--- Model Accuracy Verification (TFLite Backend) ---")
    
    if not os.path.exists(TFLITE_MODEL_PATH):
        print(f"ERROR: TFLite model not found!")
        return

    try:
        interpreter = tf.lite.Interpreter(model_path=TFLITE_MODEL_PATH)
        interpreter.allocate_tensors()
        input_details = interpreter.get_input_details()
        output_details = interpreter.get_output_details()
    except Exception as e:
        print(f"Error loading TFLite model: {e}")
        return

    results = {cls: {'correct': 0, 'total': 0} for cls in CLASS_NAMES}
    
    for class_name in CLASS_NAMES:
        class_dir = os.path.join(DATASET_DIR, class_name)
        if not os.path.exists(class_dir): continue
            
        all_images = [f for f in os.listdir(class_dir) if f.lower().endswith(('.jpg', '.jpeg', '.png'))]
        # Seed for consistent testing
        random.seed(42)
        sample = random.sample(all_images, min(SAMPLE_SIZE, len(all_images)))
        print(f"Testing {class_name} ({len(sample)} images)...")
        
        for i, img_name in enumerate(sample):
            img_path = os.path.join(class_dir, img_name)
            input_data = load_and_preprocess_image(img_path)
            
            if input_data is not None:
                interpreter.set_tensor(input_details[0]['index'], input_data)
                interpreter.invoke()
                output_data = interpreter.get_tensor(output_details[0]['index'])
                
                predicted_idx = np.argmax(output_data[0])
                predicted_class = CLASS_NAMES[predicted_idx]
                
                # Debug first scan of each class
                if i == 0:
                    print(f"  Debug [0]: True={class_name}, Pred={predicted_class}, Confidence={output_data[0][predicted_idx]:.4f}")

                results[class_name]['total'] += 1
                if predicted_class == class_name:
                    results[class_name]['correct'] += 1

    # Print Report
    print("\n" + "="*50)
    print(f"{'Class Name':<15} | {'Tested':<8} | {'Correct':<8} | {'Accuracy':<10}")
    print("-" * 50)
    t_c, t_s = 0, 0
    for cls, d in results.items():
        if d['total'] > 0:
            acc = (d['correct'] / d['total']) * 100
            print(f"{cls:<15} | {d['total']:<8} | {d['correct']:<8} | {acc:>8.2f}%")
            t_c += d['correct']; t_s += d['total']
    
    print("-" * 50)
    overall_accuracy = (t_c / t_s * 100) if t_s > 0 else 100.0
    print(f"{'OVERALL':<15} | {t_s:<8} | {t_c:<8} | {overall_accuracy:>8.2f}%")
    print("="*50)

if __name__ == "__main__":
    verify_accuracy()
