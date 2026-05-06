/// 더미 음식 데이터베이스
///
/// 실제 서비스에서는 이 파일을 아래로 교체합니다:
///   - ML 모델 → EfficientNet 등으로 음식 클래스 분류 (label index 반환)
///   - DB 조회  → Hive Box 또는 SQLite에서 label에 맞는 영양 정보 조회
///
/// 현재는 랜덤 반환으로 UI 테스트에 사용합니다.

class FoodEntry {
  final String name;
  final double calories; // kcal (1인분)
  final double carbs; // g
  final double protein; // g
  final double fat; // g

  const FoodEntry({
    required this.name,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
  });
}

/// label(String) → FoodEntry 매핑
///
/// ML 모델이 분류한 label을 키로 사용합니다.
/// label 이름은 모델 학습 시 사용한 클래스명과 일치시켜야 합니다.
const Map<String, FoodEntry> kFoodDatabase = {
  'bibimbap': FoodEntry(
    name: '비빔밥',
    calories: 560,
    carbs: 88.0,
    protein: 18.0,
    fat: 12.0,
  ),
  'kimchi_jjigae': FoodEntry(
    name: '김치찌개',
    calories: 310,
    carbs: 12.0,
    protein: 22.0,
    fat: 18.0,
  ),
  'doenjang_jjigae': FoodEntry(
    name: '된장찌개',
    calories: 270,
    carbs: 14.0,
    protein: 20.0,
    fat: 14.0,
  ),
  'bulgogi': FoodEntry(
    name: '불고기',
    calories: 420,
    carbs: 18.0,
    protein: 38.0,
    fat: 22.0,
  ),
  'samgyeopsal': FoodEntry(
    name: '삼겹살',
    calories: 660,
    carbs: 2.0,
    protein: 30.0,
    fat: 58.0,
  ),
  'japchae': FoodEntry(
    name: '잡채',
    calories: 390,
    carbs: 56.0,
    protein: 14.0,
    fat: 12.0,
  ),
  'tteokbokki': FoodEntry(
    name: '떡볶이',
    calories: 440,
    carbs: 82.0,
    protein: 10.0,
    fat: 8.0,
  ),
  'ramyeon': FoodEntry(
    name: '라면',
    calories: 500,
    carbs: 72.0,
    protein: 10.0,
    fat: 18.0,
  ),
  'gimbap': FoodEntry(
    name: '김밥',
    calories: 480,
    carbs: 76.0,
    protein: 16.0,
    fat: 12.0,
  ),
  'sundae': FoodEntry(
    name: '순대',
    calories: 380,
    carbs: 32.0,
    protein: 20.0,
    fat: 18.0,
  ),
  'fried_chicken': FoodEntry(
    name: '치킨',
    calories: 720,
    carbs: 36.0,
    protein: 48.0,
    fat: 42.0,
  ),
  'pizza': FoodEntry(
    name: '피자 (1조각)',
    calories: 290,
    carbs: 34.0,
    protein: 14.0,
    fat: 11.0,
  ),
  'hamburger': FoodEntry(
    name: '햄버거',
    calories: 480,
    carbs: 42.0,
    protein: 26.0,
    fat: 22.0,
  ),
  'rice': FoodEntry(
    name: '흰쌀밥',
    calories: 300,
    carbs: 66.0,
    protein: 6.0,
    fat: 0.6,
  ),
  'seolleongtang': FoodEntry(
    name: '설렁탕',
    calories: 340,
    carbs: 24.0,
    protein: 28.0,
    fat: 14.0,
  ),
};
