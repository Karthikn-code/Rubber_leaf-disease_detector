import os
import argparse
import numpy as np
import tensorflow as tf
from tensorflow.keras import layers, models, regularizers
from tensorflow.keras.applications import MobileNetV2
from sklearn.utils.class_weight import compute_class_weight
import matplotlib.pyplot as plt

# Import load_dataset from preprocess.py
from preprocess import load_dataset

def build_data_augmentation():
    """Creates a robust data augmentation pipeline applied directly on the GPU."""
    return tf.keras.Sequential([
        layers.RandomFlip("horizontal_and_vertical"),
        layers.RandomRotation(0.2),
        layers.RandomZoom(0.15),
        layers.RandomContrast(0.1)
    ], name='data_augmentation')

def build_advanced_model(num_classes, img_size=(224, 224)):
    """Builds a highly optimized CNN model using MobileNetV2 as a feature extractor."""
    inputs = tf.keras.Input(shape=img_size + (3,))
    
    # 1. Advanced Data Augmentation
    x = build_data_augmentation()(inputs)
    
    # 2. Native MobileNet preprocessing
    x = tf.keras.applications.mobilenet_v2.preprocess_input(x)
    
    # 3. Base Model (Frozen initially)
    base_model = MobileNetV2(input_shape=img_size + (3,), include_top=False, weights='imagenet')
    base_model.trainable = False
    x = base_model(x, training=False) # Ensure batchnorm layers run in inference mode
    
    # 4. Pro-level Classification Head
    x = layers.GlobalAveragePooling2D()(x)
    x = layers.BatchNormalization()(x)
    
    # MLP block with Swish activation and aggressive dropout to prevent overfitting
    x = layers.Dense(512, activation='swish', kernel_regularizer=regularizers.l2(1e-4))(x)
    x = layers.BatchNormalization()(x)
    x = layers.Dropout(0.4)(x)
    
    outputs = layers.Dense(num_classes, activation='softmax')(x)
    
    model = tf.keras.Model(inputs, outputs)
    
    # Stage 1: Warmup phase learning rate
    optimizer = tf.keras.optimizers.Adam(learning_rate=0.001)
    model.compile(optimizer=optimizer,
                  loss=tf.keras.losses.SparseCategoricalCrossentropy(),
                  metrics=['accuracy'])
                  
    return model, base_model

def get_class_weights(train_ds):
    """Computes rigorous class weights to handle imbalanced agricultural datasets."""
    print("Calculating class weights for imbalanced distributions...")
    y_train = np.concatenate([y for x, y in train_ds], axis=0)
    classes = np.unique(y_train)
    weights = compute_class_weight('balanced', classes=classes, y=y_train)
    class_weight_dict = dict(zip(classes, weights))
    print(f"Computed Class Weights: {class_weight_dict}")
    return class_weight_dict

def main():
    parser = argparse.ArgumentParser(description="Pro-Level ML Pipeline")
    parser.add_argument('--data_dir', type=str, required=True, help='Path to dataset directory')
    parser.add_argument('--epochs', type=int, default=20, help='Total epochs (Stage 1 + Stage 2)')
    parser.add_argument('--batch_size', type=int, default=32, help='Batch size')
    parser.add_argument('--model_dir', type=str, default='../saved_models', help='Path to save the model')
    
    args = parser.parse_args()
    os.makedirs(args.model_dir, exist_ok=True)
    best_model_path = os.path.join(args.model_dir, 'best_model.h5') # Save as highly compatible .h5 for Flask
    
    print("Loading dataset...")
    # Caching datasets in memory for lightning fast I/O
    train_ds, val_ds, class_names = load_dataset(args.data_dir, batch_size=args.batch_size)
    num_classes = len(class_names)
    
    # Compute robust class weights
    class_weights = get_class_weights(train_ds)
    
    print(f"Building Advanced Model Architecture for {num_classes} classes...")
    model, base_model = build_advanced_model(num_classes)
    
    # ─── STAGE 1: WARMUP TRAINING ───
    print("\n" + "="*50)
    print("STAGE 1: Training Classification Head (Warmup)")
    print("="*50)
    
    stage1_epochs = args.epochs // 2
    callbacks_s1 = [
        tf.keras.callbacks.EarlyStopping(patience=4, restore_best_weights=True),
        tf.keras.callbacks.ModelCheckpoint(best_model_path, save_best_only=True)
    ]
    
    history1 = model.fit(
        train_ds,
        validation_data=val_ds,
        epochs=stage1_epochs,
        class_weight=class_weights,
        callbacks=callbacks_s1
    )
    
    # ─── STAGE 2: FINE-TUNING ───
    print("\n" + "="*50)
    print("STAGE 2: Fine-Tuning base MobileNetV2 layers")
    print("="*50)
    
    # Unfreeze the top 30 layers of the base model
    base_model.trainable = True
    for layer in base_model.layers[:-30]:
        layer.trainable = False
        
    # Recompile with a very low learning rate and Cosine Decay
    lr_schedule = tf.keras.optimizers.schedules.CosineDecay(initial_learning_rate=1e-5, decay_steps=1000)
    model.compile(optimizer=tf.keras.optimizers.Adam(learning_rate=lr_schedule),
                  loss=tf.keras.losses.SparseCategoricalCrossentropy(),
                  metrics=['accuracy'])
                  
    callbacks_s2 = [
        tf.keras.callbacks.EarlyStopping(patience=4, restore_best_weights=True),
        tf.keras.callbacks.ModelCheckpoint(best_model_path, save_best_only=True)
    ]
    
    history2 = model.fit(
        train_ds,
        validation_data=val_ds,
        epochs=args.epochs - stage1_epochs,
        class_weight=class_weights,
        callbacks=callbacks_s2
    )
    
    print(f"\nTraining fully completed! Pro Model saved to {best_model_path}")
    
    # Plot combined history
    plt.figure(figsize=(12, 4))
    
    acc = history1.history['accuracy'] + history2.history['accuracy']
    val_acc = history1.history['val_accuracy'] + history2.history['val_accuracy']
    loss = history1.history['loss'] + history2.history['loss']
    val_loss = history1.history['val_loss'] + history2.history['val_loss']
    
    plt.subplot(1, 2, 1)
    plt.plot(acc, label='Training Accuracy')
    plt.plot(val_acc, label='Validation Accuracy')
    plt.axvline(x=len(history1.history['accuracy'])-1, color='red', linestyle='--', label='Fine-Tuning Starts')
    plt.legend()
    plt.title('Advanced Accuracy')
    
    plt.subplot(1, 2, 2)
    plt.plot(loss, label='Training Loss')
    plt.plot(val_loss, label='Validation Loss')
    plt.axvline(x=len(history1.history['loss'])-1, color='red', linestyle='--', label='Fine-Tuning Starts')
    plt.legend()
    plt.title('Advanced Loss')
    
    plot_path = os.path.join(args.model_dir, 'training_history.png')
    plt.savefig(plot_path)
    print(f"Training history visualization saved to {plot_path}")

if __name__ == '__main__':
    main()
