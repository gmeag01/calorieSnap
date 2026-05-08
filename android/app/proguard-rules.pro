# TensorFlow Lite 관련 클래스 보존
-keep class org.tensorflow.lite.** { *; }
-keep class org.tensorflow.lite.gpu.** { *; }
-keep interface org.tensorflow.lite.gpu.** { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegate { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory$Options { *; }

# Hive 관련 클래스 보존
-keep class com.example.** { *; }
-keep class hive.** { *; }

# Flutter 클래스 보존
-keep class io.flutter.** { *; }

# Google Play Core 라이브러리 보존 (Deferred components 지원)
-keep class com.google.android.play.core.** { *; }
-keep interface com.google.android.play.core.** { *; }

# 경고 억제
-dontwarn org.tensorflow.lite.**
-dontwarn com.google.android.play.core.**

# R8 최적화 비활성화 (선택적)
-optimizationpasses 1
