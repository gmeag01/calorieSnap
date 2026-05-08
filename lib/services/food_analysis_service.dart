import 'dart:io';
// import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../data/food_database.dart';

// ─────────────────────────────────────────────────────────────
//  상수
// ─────────────────────────────────────────────────────────────
const int    _kImgSize    = 224;   // MobileNetV3 입력 크기
const double _kThreshold  = 0.55;  // 이 미만이면 미등록 음식 처리
const int    _kNumClasses = 20;

// ─────────────────────────────────────────────────────────────
//  결과 모델 (변경 없음 — 외부 인터페이스 유지)
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
//  흐름:
//    analyzeFood(imageFile)
//      ├─ _getInterpreter()   : 인터프리터 lazy 초기화 (앱 내 1회)
//      ├─ _preprocess()       : 이미지 → Float32 텐서 [1,224,224,3]
//      ├─ interpreter.run()   : 모델 추론 → softmax 확률 [1,20]
//      ├─ argmax + threshold  : 최고 확률 클래스 선택
//      └─ _lookupDb()         : label → FoodEntry 조회
// ─────────────────────────────────────────────────────────────
class FoodAnalysisService {
  // ── 인터프리터 싱글톤 ──────────────────────────────────────
  static Interpreter? _interpreter;

  static Future<Interpreter> _getInterpreter() async {
    if (_interpreter != null) return _interpreter!;

    // assets/models/mobilenetv3_food.tflite 로드
    // (pubspec.yaml의 flutter.assets에 선언 필요)
    _interpreter = await Interpreter.fromAsset(
      'assets/models/efficientnetv2b0_food.tflite',
      options: InterpreterOptions()..threads = 4, // 멀티스레드 추론
    );
    return _interpreter!;
  }

  // ─────────────────────────────────────────────────────────
  //  공개 진입점 — 외부에서 호출하는 유일한 메서드
  // ─────────────────────────────────────────────────────────
  static Future<FoodAnalysisResult> analyzeFood(File imageFile) async {
    // 1. 이미지 전처리
    final input = await _preprocess(imageFile);
    if (input == null) return FoodAnalysisResult.notFound();

    // 2. TFLite 추론
    final interpreter = await _getInterpreter();

    // 출력 버퍼: [1][20] float32
    final output = List.generate(
      1, (_) => List.filled(_kNumClasses, 0.0),
    );

    interpreter.run(input, output);

    // 3. argmax + 신뢰도 필터
    final scores     = output[0];
    final topIndex   = _argmax(scores);
    final confidence = scores[topIndex];

    if (confidence < _kThreshold) {
      return FoodAnalysisResult.notFound();
    }

    // 4. 인덱스 → label → DB 조회
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

  // ─────────────────────────────────────────────────────────
  //  이미지 전처리 (Aspect Ratio 보존)
  //
  //  개선: CenterCrop으로 비율 유지
  //    1. 정사각형 영역으로 센터 크롭 (비율 유지)
  //    2. 224×224 리사이즈
  //    3. float32 / 255.0 → [0.0, 1.0] 정규화
  //    4. shape: [1][224][224][3]
  //
  //  예시 (원본 1920×1080):
  //    → 1080×1080 정사각형 자르기 (중앙)
  //    → 224×224 리사이즈
  // ─────────────────────────────────────────────────────────
  static Future<List<List<List<List<double>>>>?> _preprocess(
      File imageFile) async {
    final bytes   = await imageFile.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return null;

    // Step 1: CenterCrop — 비율 유지하며 정사각형 자르기
    final w       = decoded.width;
    final h       = decoded.height;
    final cropSize = w < h ? w : h;  // min(width, height)

    final offsetX = (w - cropSize) ~/ 2;
    final offsetY = (h - cropSize) ~/ 2;

    final cropped = img.copyCrop(
      decoded,
      x:      offsetX,
      y:      offsetY,
      width:  cropSize,
      height: cropSize,
    );

    // Step 2: 224×224 리사이즈
    final resized = img.copyResize(
      cropped,
      width:         _kImgSize,
      height:        _kImgSize,
      interpolation: img.Interpolation.cubic,
    );

    // Step 3: [1][H][W][C] Float 텐서 생성 + 정규화
    return List.generate(
      1, (_) => List.generate(
        _kImgSize, (y) => List.generate(
          _kImgSize, (x) {
            final pixel = resized.getPixel(x, y);
            return [
              pixel.r / 127.5 - 1.0, // R
              pixel.g / 127.5 - 1.0, // G
              pixel.b / 127.5 - 1.0, // B
            ];
          },
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  argmax 헬퍼
  // ─────────────────────────────────────────────────────────
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

  // ─────────────────────────────────────────────────────────
  //  DB 조회 — label → FoodEntry
  // ─────────────────────────────────────────────────────────
  static FoodEntry? _lookupDb(String label) => kFoodDatabase[label];

  // ─────────────────────────────────────────────────────────
  //  인터프리터 해제 (앱 종료 시 호출 권장)
  // ─────────────────────────────────────────────────────────
  static void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
