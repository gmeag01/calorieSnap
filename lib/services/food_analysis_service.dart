import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../data/food_database.dart';

const int    _kImgSize    = 224;
const double _kThreshold  = 0.55;
const int    _kNumClasses = 20;

// ─────────────────────────────────────────────────────────────
//  Top-level function required by compute() — background isolate에서 실행
//  (static method나 클로저는 isolate 경계를 넘을 때 불안정)
//
//  학습 전처리와 완전 일치:
//    bakeOrientation → CenterCrop → resize(linear) → [-1,1] 정규화
// ─────────────────────────────────────────────────────────────
Float32List? _buildInputTensor(Uint8List bytes) {
  img.Image? decoded = img.decodeImage(bytes);
  if (decoded == null) return null;

  // EXIF orientation 적용 — 카메라 촬영 사진의 회전 메타데이터 반영
  decoded = img.bakeOrientation(decoded);

  // CenterCrop — 비율 유지 정사각형
  final w        = decoded.width;
  final h        = decoded.height;
  final cropSize = w < h ? w : h;

  final cropped = img.copyCrop(
    decoded,
    x:      (w - cropSize) ~/ 2,
    y:      (h - cropSize) ~/ 2,
    width:  cropSize,
    height: cropSize,
  );

  // Resize 224×224 — linear = TF 기본 bilinear와 동일
  final resized = img.copyResize(
    cropped,
    width:         _kImgSize,
    height:        _kImgSize,
    interpolation: img.Interpolation.linear,
  );

  // Float32 평탄 버퍼 + [-1, 1] 정규화
  final buffer = Float32List(_kImgSize * _kImgSize * 3);
  var idx = 0;
  for (int y = 0; y < _kImgSize; y++) {
    for (int x = 0; x < _kImgSize; x++) {
      final pixel = resized.getPixel(x, y);
      buffer[idx++] = pixel.r / 127.5 - 1.0;
      buffer[idx++] = pixel.g / 127.5 - 1.0;
      buffer[idx++] = pixel.b / 127.5 - 1.0;
    }
  }
  return buffer;
}

// ─────────────────────────────────────────────────────────────
//  결과 모델
// ─────────────────────────────────────────────────────────────
class FoodAnalysisResult {
  final String foodName;
  final double calories;
  final double carbs;
  final double protein;
  final double fat;
  final bool   isFound;

  const FoodAnalysisResult({
    required this.foodName,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.isFound,
  });

  factory FoodAnalysisResult.notFound() => const FoodAnalysisResult(
        foodName: '등록되지 않은 음식입니다.',
        calories: 0,
        carbs: 0,
        protein: 0,
        fat: 0,
        isFound: false,
      );
}

// ─────────────────────────────────────────────────────────────
//  음식 분석 서비스 — 온디바이스 TFLite 추론
//
//  analyzeFood(imageFile)
//    ├─ readAsBytes()          : 파일 읽기 (async I/O)
//    ├─ compute(_buildInputTensor) : 전처리 → background isolate
//    ├─ interpreter.run()      : TFLite 추론 (메인 isolate)
//    ├─ argmax + threshold
//    └─ label → FoodEntry 조회
// ─────────────────────────────────────────────────────────────
class FoodAnalysisService {
  static Interpreter? _interpreter;

  static Future<Interpreter> _getInterpreter() async {
    if (_interpreter != null) return _interpreter!;
    _interpreter = await Interpreter.fromAsset(
      'assets/models/efficientnetv2b0_food.tflite',
      options: InterpreterOptions()..threads = 4,
    );
    return _interpreter!;
  }

  static Future<FoodAnalysisResult> analyzeFood(File imageFile) async {
    final Object? input = await _preprocess(imageFile);
    if (input == null) return FoodAnalysisResult.notFound();

    final interpreter = await _getInterpreter();

    final output = List.generate(1, (_) => List.filled(_kNumClasses, 0.0));
    interpreter.run(input, output);

    final scores     = output[0];
    final topIndex   = _argmax(scores);
    final confidence = scores[topIndex];

    if (confidence < _kThreshold) return FoodAnalysisResult.notFound();

    final label = kLabelsList[topIndex];
    final entry = _lookupDb(label);
    if (entry == null) return FoodAnalysisResult.notFound();

    return FoodAnalysisResult(
      foodName: entry.name,
      calories: entry.calories,
      carbs:    entry.carbs,
      protein:  entry.protein,
      fat:      entry.fat,
      isFound:  true,
    );
  }

  // readAsBytes()는 비동기 I/O → 메인 isolate에서 수행
  // 이후 CPU-intensive 전처리는 compute()로 분리
  static Future<Object?> _preprocess(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final Float32List? buffer = await compute(_buildInputTensor, bytes);
    if (buffer == null) return null;
    return buffer.reshape([1, _kImgSize, _kImgSize, 3]);
  }

  static int _argmax(List<double> scores) {
    int    best      = 0;
    double bestScore = scores[0];
    for (int i = 1; i < scores.length; i++) {
      if (scores[i] > bestScore) {
        bestScore = scores[i];
        best      = i;
      }
    }
    return best;
  }

  static FoodEntry? _lookupDb(String label) => kFoodDatabase[label];

  static void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
