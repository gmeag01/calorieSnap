import 'dart:io';
import 'dart:math';
import '../data/food_database.dart';

/// 음식 분석 결과 모델
class FoodAnalysisResult {
  final String foodName;
  final double calories;
  final double carbs;
  final double protein;
  final double fat;
  final bool isFound;

  const FoodAnalysisResult({
    required this.foodName,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.isFound,
  });

  /// 인식 실패용 팩토리
  factory FoodAnalysisResult.notFound() => const FoodAnalysisResult(
        foodName: '등록되지 않은 음식입니다.',
        calories: 0,
        carbs: 0,
        protein: 0,
        fat: 0,
        isFound: false,
      );
}

/// 음식 분석 서비스
///
/// ┌─────────────────────────────────────────────────────────┐
/// │  현재: 더미 모드                                          │
/// │  analyzeFood() 호출 시:                                  │
/// │    1. [ML 모델 자리] → 랜덤 label 반환 (10% 확률 미등록)   │
/// │    2. [DB 조회 자리] → kFoodDatabase에서 영양 정보 반환    │
/// ├─────────────────────────────────────────────────────────┤
/// │  실제 모델 교체 시 수정할 함수:                            │
/// │    _runMlModel() → TFLite(EfficientNet 등) 추론으로 교체  │
/// │    _lookupDb()   → Hive Box / SQLite 조회로 교체          │
/// └─────────────────────────────────────────────────────────┘
class FoodAnalysisService {
  /// 분석 진입점 — 외부에서 호출하는 유일한 메서드 (변경 불필요)
  static Future<FoodAnalysisResult> analyzeFood(File imageFile) async {
    // ── Step 1. ML 모델 추론 ──────────────────────────────────
    // TODO: imageFile을 전처리 후 TFLite / EfficientNet 모델에 입력,
    //       가장 높은 confidence의 label(String)을 반환하도록 교체
    final String? predictedLabel = await _runMlModel(imageFile);

    // ── Step 2. DB 조회 ───────────────────────────────────────
    // TODO: predictedLabel을 키로 Hive Box 또는 SQLite에서
    //       FoodEntry(영양 정보)를 조회하도록 교체
    if (predictedLabel == null) {
      return FoodAnalysisResult.notFound();
    }

    final FoodEntry? entry = _lookupDb(predictedLabel);
    if (entry == null) {
      return FoodAnalysisResult.notFound();
    }

    return FoodAnalysisResult(
      foodName: entry.name,
      calories: entry.calories,
      carbs: entry.carbs,
      protein: entry.protein,
      fat: entry.fat,
      isFound: true,
    );
  }

  // ──────────────────────────────────────────────────────────
  //  [더미] ML 모델 추론
  //  ▸ 교체 시 이 함수 내부만 수정
  // ──────────────────────────────────────────────────────────
  static Future<String?> _runMlModel(File imageFile) async {
    // 실제 모델 예시 (tflite_flutter 패키지):
    //
    //   final interpreter = await Interpreter.fromAsset('efficientnet.tflite');
    //   final input = await _preprocessImage(imageFile); // resize → normalize
    //   final output = List.filled(kFoodDatabase.length, 0.0)
    //                      .reshape([1, kFoodDatabase.length]);
    //   interpreter.run(input, output);
    //   final scores = output[0] as List<double>;
    //   final topIndex = scores.indexOf(scores.reduce(max));
    //   final confidence = scores[topIndex];
    //   if (confidence < 0.6) return null; // 신뢰도 임계값
    //   return kFoodDatabase.keys.elementAt(topIndex);

    // ── 더미: 네트워크 지연 시뮬레이션 (1.2초) ──
    await Future.delayed(const Duration(milliseconds: 1200));

    final rng = Random();

    // 10% 확률로 미등록 음식 시뮬레이션
    if (rng.nextDouble() < 0.1) return null;

    final keys = kFoodDatabase.keys.toList();
    return keys[rng.nextInt(keys.length)];
  }

  // ──────────────────────────────────────────────────────────
  //  [더미] DB 조회
  //  ▸ 교체 시 이 함수 내부만 수정
  // ──────────────────────────────────────────────────────────
  static FoodEntry? _lookupDb(String label) {
    // 실제 Hive 예시:
    //   final box = Hive.box<FoodEntry>('foodDb');
    //   return box.get(label);
    //
    // 실제 SQLite 예시:
    //   final db = await openDatabase('food.db');
    //   final rows = await db.query('foods',
    //       where: 'label = ?', whereArgs: [label]);
    //   if (rows.isEmpty) return null;
    //   return FoodEntry.fromMap(rows.first);

    return kFoodDatabase[label];
  }
}
