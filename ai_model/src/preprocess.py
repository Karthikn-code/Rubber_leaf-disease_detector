import os
import tensorflow as tf
import matplotlib.pyplot as plt

def load_dataset(data_dir, batch_size=32, img_size=(224, 224)):
    """
    Loads the Mendeley Rubber Leaf Dataset into TensorFlow Dataset objects
    for training and validation.
    """
    if not os.path.exists(data_dir) or not os.listdir(data_dir):
        raise FileNotFoundError(f"Dataset directory '{data_dir}' is empty or not found. Please extract the dataset here.")

    print(f"Loading dataset from {data_dir}...")
    
    train_ds = tf.keras.utils.image_dataset_from_directory(
        data_dir,
        validation_split=0.2,
        subset="training",
        seed=123,
        image_size=img_size,
        batch_size=batch_size
    )

    val_ds = tf.keras.utils.image_dataset_from_directory(
        data_dir,
        validation_split=0.2,
        subset="validation",
        seed=123,
        image_size=img_size,
        batch_size=batch_size
    )

    class_names = train_ds.class_names
    print(f"Found {len(class_names)} classes: {class_names}")

    # Optimize datasets for performance
    AUTOTUNE = tf.data.AUTOTUNE
    train_ds = train_ds.cache().shuffle(1000).prefetch(buffer_size=AUTOTUNE)
    val_ds = val_ds.cache().prefetch(buffer_size=AUTOTUNE)

    return train_ds, val_ds, class_names

if __name__ == "__main__":
    DATA_DIR = os.path.join(os.path.dirname(__file__), "..", "dataset")
    try:
        train, val, classes = load_dataset(DATA_DIR)
        print("Data loading script is ready and successfully tested on dataset!")
    except Exception as e:
        print(f"Waiting for dataset: {e}")
