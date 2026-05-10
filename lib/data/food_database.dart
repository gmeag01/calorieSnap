// 음식 영양 정보 데이터베이스
//
// ─────────────────────────────────────────────────────────────
//  ⚠️  kLabelsList 순서는 Colab 학습 시 SELECTED_CLASSES 순서와
//  반드시 일치해야 합니다.
//  모델 출력 인덱스 → label → FoodEntry 순으로 조회합니다.
//
//  Colab SELECTED_CLASSES = [
//    'pizza', 'hamburger', 'fried_rice', 'ramen', 'sushi',
//    'steak', 'donuts', 'ice_cream', 'chicken_wings',
//    'spaghetti_bolognese', 'spaghetti_carbonara', 'cup_cakes',
//    'french_toast', 'risotto', 'macaroni_and_cheese',
//    'grilled_salmon', 'bibimbap', 'miso_soup', 'tacos',
//    'chocolate_cake'
//  ]
// ─────────────────────────────────────────────────────────────

class FoodEntry {
  final String name;       // 한국어 표시명
  final double calories;   // kcal / 1인분
  final double carbs;      // 탄수화물 g
  final double protein;    // 단백질 g
  final double fat;        // 지방 g

  const FoodEntry({
    required this.name,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
  });
}

/// 모델 출력 인덱스 순서와 동일한 레이블 목록
/// index 0 = 'pizza', index 1 = 'hamburger', ...
const List<String> kLabelsList = [
  'pizza',               // 0
  'hamburger',           // 1
  'fried_rice',          // 2
  'ramen',               // 3
  'sushi',               // 4
  'steak',               // 5
  'donuts',              // 6
  'ice_cream',           // 7
  'chicken_wings',       // 8
  'spaghetti_bolognese', // 9
  'spaghetti_carbonara', // 10
  'cup_cakes',           // 11
  'french_toast',        // 12
  'risotto',             // 13
  'macaroni_and_cheese', // 14
  'grilled_salmon',      // 15
  'bibimbap',            // 16
  'miso_soup',           // 17
  'tacos',               // 18
  'chocolate_cake',      // 19
];

/// label → 영양 정보 매핑
/// 출처: USDA FoodData Central 및 식약처 식품영양성분 데이터 기준 1인분
const Map<String, FoodEntry> kFoodDatabase = {
  // ── 0 ────────────────────────────────────────
  'pizza': FoodEntry(
    name: '피자 (1조각)',
    calories: 285,
    carbs: 35.7,
    protein: 12.2,
    fat: 10.4,
  ),
  // ── 1 ────────────────────────────────────────
  'hamburger': FoodEntry(
    name: '햄버거',
    calories: 480,
    carbs: 40.0,
    protein: 26.0,
    fat: 24.0,
  ),
  // ── 2 ────────────────────────────────────────
  'fried_rice': FoodEntry(
    name: '볶음밥',
    calories: 450,
    carbs: 65.0,
    protein: 14.0,
    fat: 14.0,
  ),
  // ── 3 ────────────────────────────────────────
  'ramen': FoodEntry(
    name: '라면',
    calories: 510,
    carbs: 68.0,
    protein: 18.0,
    fat: 18.0,
  ),
  // ── 4 ────────────────────────────────────────
  'sushi': FoodEntry(
    name: '스시 (6피스)',
    calories: 310,
    carbs: 50.0,
    protein: 18.0,
    fat: 4.0,
  ),
  // ── 5 ────────────────────────────────────────
  'steak': FoodEntry(
    name: '스테이크',
    calories: 480,
    carbs: 0.0,
    protein: 52.0,
    fat: 28.0,
  ),
  // ── 6 ────────────────────────────────────────
  'donuts': FoodEntry(
    name: '도넛',
    calories: 195,
    carbs: 22.0,
    protein: 2.5,
    fat: 11.0,
  ),
  // ── 7 ────────────────────────────────────────
  'ice_cream': FoodEntry(
    name: '아이스크림 (1스쿱)',
    calories: 207,
    carbs: 24.0,
    protein: 3.5,
    fat: 11.0,
  ),
  // ── 8 ────────────────────────────────────────
  'chicken_wings': FoodEntry(
    name: '치킨 윙 (6개)',
    calories: 490,
    carbs: 0.0,
    protein: 46.0,
    fat: 32.0,
  ),
  // ── 9 ────────────────────────────────────────
  'spaghetti_bolognese': FoodEntry(
    name: '스파게티 볼로네제',
    calories: 520,
    carbs: 62.0,
    protein: 28.0,
    fat: 16.0,
  ),
  // ── 10 ───────────────────────────────────────
  'spaghetti_carbonara': FoodEntry(
    name: '스파게티 카르보나라',
    calories: 580,
    carbs: 60.0,
    protein: 24.0,
    fat: 26.0,
  ),
  // ── 11 ───────────────────────────────────────
  'cup_cakes': FoodEntry(
    name: '컵케이크',
    calories: 305,
    carbs: 40.0,
    protein: 3.0,
    fat: 15.0,
  ),
  // ── 12 ───────────────────────────────────────
  'french_toast': FoodEntry(
    name: '프렌치 토스트 (2장)',
    calories: 380,
    carbs: 44.0,
    protein: 12.0,
    fat: 16.0,
  ),
  // ── 13 ───────────────────────────────────────
  'risotto': FoodEntry(
    name: '리조또',
    calories: 420,
    carbs: 56.0,
    protein: 12.0,
    fat: 14.0,
  ),
  // ── 14 ───────────────────────────────────────
  'macaroni_and_cheese': FoodEntry(
    name: '맥앤치즈',
    calories: 490,
    carbs: 56.0,
    protein: 18.0,
    fat: 20.0,
  ),
  // ── 15 ───────────────────────────────────────
  'grilled_salmon': FoodEntry(
    name: '연어 구이',
    calories: 350,
    carbs: 0.0,
    protein: 42.0,
    fat: 18.0,
  ),
  // ── 16 ───────────────────────────────────────
  'bibimbap': FoodEntry(
    name: '비빔밥',
    calories: 560,
    carbs: 88.0,
    protein: 18.0,
    fat: 12.0,
  ),
  // ── 17 ───────────────────────────────────────
  'miso_soup': FoodEntry(
    name: '미소국',
    calories: 84,
    carbs: 8.0,
    protein: 6.0,
    fat: 3.0,
  ),
  // ── 18 ───────────────────────────────────────
  'tacos': FoodEntry(
    name: '타코 (2개)',
    calories: 370,
    carbs: 36.0,
    protein: 20.0,
    fat: 16.0,
  ),
  // ── 19 ───────────────────────────────────────
  'chocolate_cake': FoodEntry(
    name: '초코 케이크 (1조각)',
    calories: 370,
    carbs: 52.0,
    protein: 5.0,
    fat: 16.0,
  ),
};
