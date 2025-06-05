# TensorFlow Lite keep rules
-keep class org.tensorflow.** { *; }
-dontwarn org.tensorflow.**

# If using GPU Delegate
-keep class org.tensorflow.lite.gpu.** { *; }
-dontwarn org.tensorflow.lite.gpu.**
