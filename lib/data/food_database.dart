// 음식 영양 정보 데이터베이스
//
// ─────────────────────────────────────────────────────────────
//  kLabelsList 순서는 Food-101 tfds 알파벳 정렬 인덱스와 일치
//  (assets/models/labels.json 과 동일)
//  모델 출력 인덱스 → label → FoodEntry 순으로 조회
// ─────────────────────────────────────────────────────────────

class FoodEntry {
  final String name;          // 한국어 표시명
  final double calories;      // kcal / servingAmount 기준
  final double carbs;         // 탄수화물 g
  final double protein;       // 단백질 g
  final double fat;           // 지방 g
  final String servingUnit;   // 단위: 'g' | '조각' | '개' | '피스' | '스쿱' | '장'
  final double servingAmount; // 위 영양값이 해당하는 기준 수량
  final double minAmount;     // 슬라이더 최솟값
  final double maxAmount;     // 슬라이더 최댓값

  const FoodEntry({
    required this.name,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.servingUnit,
    required this.servingAmount,
    required this.minAmount,
    required this.maxAmount,
  });

  bool get isGramBased => servingUnit == 'g';
}

/// 모델 출력 인덱스 순서와 동일한 레이블 목록 (Food-101 tfds 알파벳 정렬)
const List<String> kLabelsList = [
  'apple_pie',               // 0
  'baby_back_ribs',          // 1
  'baklava',                 // 2
  'beef_carpaccio',          // 3
  'beef_tartare',            // 4
  'beet_salad',              // 5
  'beignets',                // 6
  'bibimbap',                // 7
  'bread_pudding',           // 8
  'breakfast_burrito',       // 9
  'bruschetta',              // 10
  'caesar_salad',            // 11
  'cannoli',                 // 12
  'caprese_salad',           // 13
  'carrot_cake',             // 14
  'ceviche',                 // 15
  'cheesecake',              // 16
  'cheese_plate',            // 17
  'chicken_curry',           // 18
  'chicken_quesadilla',      // 19
  'chicken_wings',           // 20
  'chocolate_cake',          // 21
  'chocolate_mousse',        // 22
  'churros',                 // 23
  'clam_chowder',            // 24
  'club_sandwich',           // 25
  'crab_cakes',              // 26
  'creme_brulee',            // 27
  'croque_madame',           // 28
  'cup_cakes',               // 29
  'deviled_eggs',            // 30
  'donuts',                  // 31
  'dumplings',               // 32
  'edamame',                 // 33
  'eggs_benedict',           // 34
  'escargots',               // 35
  'falafel',                 // 36
  'filet_mignon',            // 37
  'fish_and_chips',          // 38
  'foie_gras',               // 39
  'french_fries',            // 40
  'french_onion_soup',       // 41
  'french_toast',            // 42
  'fried_calamari',          // 43
  'fried_rice',              // 44
  'frozen_yogurt',           // 45
  'garlic_bread',            // 46
  'gnocchi',                 // 47
  'greek_salad',             // 48
  'grilled_cheese_sandwich', // 49
  'grilled_salmon',          // 50
  'guacamole',               // 51
  'gyoza',                   // 52
  'hamburger',               // 53
  'hot_and_sour_soup',       // 54
  'hot_dog',                 // 55
  'huevos_rancheros',        // 56
  'hummus',                  // 57
  'ice_cream',               // 58
  'lasagna',                 // 59
  'lobster_bisque',          // 60
  'lobster_roll_sandwich',   // 61
  'macaroni_and_cheese',     // 62
  'macarons',                // 63
  'miso_soup',               // 64
  'mussels',                 // 65
  'nachos',                  // 66
  'omelette',                // 67
  'onion_rings',             // 68
  'oysters',                 // 69
  'pad_thai',                // 70
  'paella',                  // 71
  'pancakes',                // 72
  'panna_cotta',             // 73
  'peking_duck',             // 74
  'pho',                     // 75
  'pizza',                   // 76
  'pork_chop',               // 77
  'poutine',                 // 78
  'prime_rib',               // 79
  'pulled_pork_sandwich',    // 80
  'ramen',                   // 81
  'ravioli',                 // 82
  'red_velvet_cake',         // 83
  'risotto',                 // 84
  'samosa',                  // 85
  'sashimi',                 // 86
  'scallops',                // 87
  'seaweed_salad',           // 88
  'shrimp_and_grits',        // 89
  'spaghetti_bolognese',     // 90
  'spaghetti_carbonara',     // 91
  'spring_rolls',            // 92
  'steak',                   // 93
  'strawberry_shortcake',    // 94
  'sushi',                   // 95
  'tacos',                   // 96
  'takoyaki',                // 97
  'tiramisu',                // 98
  'tuna_tartare',            // 99
  'waffles',                 // 100
];

/// label → 영양 정보 매핑
/// 출처: USDA FoodData Central 및 식약처 식품영양성분 데이터 기준 1인분
const Map<String, FoodEntry> kFoodDatabase = {
  // ── 0 ────────────────────────────────────────
  'apple_pie': FoodEntry(
    name: '애플 파이',
    calories: 296,
    carbs: 43.0,
    protein: 2.8,
    fat: 14.0,
    servingUnit: '조각',
    servingAmount: 1,
    minAmount: 1,
    maxAmount: 8,
  ),
  // ── 1 ────────────────────────────────────────
  'baby_back_ribs': FoodEntry(
    name: '베이비 백 립',
    calories: 810,
    carbs: 0.0,
    protein: 60.0,
    fat: 63.0,
    servingUnit: 'g',
    servingAmount: 300,
    minAmount: 100,
    maxAmount: 600,
  ),
  // ── 2 ────────────────────────────────────────
  'baklava': FoodEntry(
    name: '바클라바',
    calories: 430,
    carbs: 63.0,
    protein: 6.0,
    fat: 19.0,
    servingUnit: '개',
    servingAmount: 1,
    minAmount: 1,
    maxAmount: 8,
  ),
  // ── 3 ────────────────────────────────────────
  'beef_carpaccio': FoodEntry(
    name: '비프 카르파초',
    calories: 130,
    carbs: 0.0,
    protein: 22.0,
    fat: 4.5,
    servingUnit: 'g',
    servingAmount: 85,
    minAmount: 50,
    maxAmount: 300,
  ),
  // ── 4 ────────────────────────────────────────
  'beef_tartare': FoodEntry(
    name: '비프 타르타르',
    calories: 220,
    carbs: 4.0,
    protein: 28.0,
    fat: 10.0,
    servingUnit: 'g',
    servingAmount: 150,
    minAmount: 50,
    maxAmount: 400,
  ),
  // ── 5 ────────────────────────────────────────
  'beet_salad': FoodEntry(
    name: '비트 샐러드',
    calories: 130,
    carbs: 22.0,
    protein: 4.0,
    fat: 3.0,
    servingUnit: 'g',
    servingAmount: 200,
    minAmount: 100,
    maxAmount: 500,
  ),
  // ── 6 ────────────────────────────────────────
  'beignets': FoodEntry(
    name: '베녜',
    calories: 240,
    carbs: 30.0,
    protein: 4.0,
    fat: 12.0,
    servingUnit: '개',
    servingAmount: 3,
    minAmount: 1,
    maxAmount: 15,
  ),
  // ── 7 ────────────────────────────────────────
  'bibimbap': FoodEntry(
    name: '비빔밥',
    calories: 560,
    carbs: 88.0,
    protein: 18.0,
    fat: 12.0,
    servingUnit: 'g',
    servingAmount: 450,
    minAmount: 200,
    maxAmount: 800,
  ),
  // ── 8 ────────────────────────────────────────
  'bread_pudding': FoodEntry(
    name: '브레드 푸딩',
    calories: 340,
    carbs: 52.0,
    protein: 9.0,
    fat: 11.0,
    servingUnit: 'g',
    servingAmount: 150,
    minAmount: 100,
    maxAmount: 400,
  ),
  // ── 9 ────────────────────────────────────────
  'breakfast_burrito': FoodEntry(
    name: '아침 부리토',
    calories: 350,
    carbs: 38.0,
    protein: 20.0,
    fat: 13.0,
    servingUnit: '개',
    servingAmount: 1,
    minAmount: 1,
    maxAmount: 4,
  ),
  // ── 10 ───────────────────────────────────────
  'bruschetta': FoodEntry(
    name: '브루스케타',
    calories: 160,
    carbs: 24.0,
    protein: 5.0,
    fat: 5.0,
    servingUnit: '개',
    servingAmount: 2,
    minAmount: 1,
    maxAmount: 12,
  ),
  // ── 11 ───────────────────────────────────────
  'caesar_salad': FoodEntry(
    name: '시저 샐러드',
    calories: 250,
    carbs: 14.0,
    protein: 8.0,
    fat: 19.0,
    servingUnit: 'g',
    servingAmount: 200,
    minAmount: 100,
    maxAmount: 500,
  ),
  // ── 12 ───────────────────────────────────────
  'cannoli': FoodEntry(
    name: '카놀리',
    calories: 220,
    carbs: 26.0,
    protein: 6.0,
    fat: 10.0,
    servingUnit: '개',
    servingAmount: 1,
    minAmount: 1,
    maxAmount: 6,
  ),
  // ── 13 ───────────────────────────────────────
  'caprese_salad': FoodEntry(
    name: '카프레제 샐러드',
    calories: 230,
    carbs: 6.0,
    protein: 15.0,
    fat: 17.0,
    servingUnit: 'g',
    servingAmount: 200,
    minAmount: 100,
    maxAmount: 500,
  ),
  // ── 14 ───────────────────────────────────────
  'carrot_cake': FoodEntry(
    name: '당근 케이크',
    calories: 350,
    carbs: 45.0,
    protein: 4.0,
    fat: 18.0,
    servingUnit: '조각',
    servingAmount: 1,
    minAmount: 1,
    maxAmount: 8,
  ),
  // ── 15 ───────────────────────────────────────
  'ceviche': FoodEntry(
    name: '세비체',
    calories: 120,
    carbs: 8.0,
    protein: 20.0,
    fat: 2.0,
    servingUnit: 'g',
    servingAmount: 150,
    minAmount: 50,
    maxAmount: 400,
  ),
  // ── 16 ───────────────────────────────────────
  'cheesecake': FoodEntry(
    name: '치즈케이크',
    calories: 400,
    carbs: 36.0,
    protein: 7.0,
    fat: 26.0,
    servingUnit: '조각',
    servingAmount: 1,
    minAmount: 1,
    maxAmount: 8,
  ),
  // ── 17 ───────────────────────────────────────
  'cheese_plate': FoodEntry(
    name: '치즈 플레이트',
    calories: 400,
    carbs: 4.0,
    protein: 24.0,
    fat: 33.0,
    servingUnit: 'g',
    servingAmount: 100,
    minAmount: 50,
    maxAmount: 300,
  ),
  // ── 18 ───────────────────────────────────────
  'chicken_curry': FoodEntry(
    name: '치킨 카레',
    calories: 450,
    carbs: 30.0,
    protein: 35.0,
    fat: 20.0,
    servingUnit: 'g',
    servingAmount: 300,
    minAmount: 100,
    maxAmount: 600,
  ),
  // ── 19 ───────────────────────────────────────
  'chicken_quesadilla': FoodEntry(
    name: '치킨 퀘사디아',
    calories: 520,
    carbs: 40.0,
    protein: 32.0,
    fat: 24.0,
    servingUnit: '개',
    servingAmount: 1,
    minAmount: 1,
    maxAmount: 4,
  ),
  // ── 20 ───────────────────────────────────────
  'chicken_wings': FoodEntry(
    name: '치킨 윙',
    calories: 490,
    carbs: 0.0,
    protein: 46.0,
    fat: 32.0,
    servingUnit: '개',
    servingAmount: 6,
    minAmount: 1,
    maxAmount: 24,
  ),
  // ── 21 ───────────────────────────────────────
  'chocolate_cake': FoodEntry(
    name: '초코 케이크',
    calories: 370,
    carbs: 52.0,
    protein: 5.0,
    fat: 16.0,
    servingUnit: '조각',
    servingAmount: 1,
    minAmount: 1,
    maxAmount: 8,
  ),
  // ── 22 ───────────────────────────────────────
  'chocolate_mousse': FoodEntry(
    name: '초콜릿 무스',
    calories: 290,
    carbs: 24.0,
    protein: 6.0,
    fat: 19.0,
    servingUnit: 'g',
    servingAmount: 120,
    minAmount: 50,
    maxAmount: 300,
  ),
  // ── 23 ───────────────────────────────────────
  'churros': FoodEntry(
    name: '추로스',
    calories: 310,
    carbs: 48.0,
    protein: 5.0,
    fat: 11.0,
    servingUnit: '개',
    servingAmount: 3,
    minAmount: 1,
    maxAmount: 12,
  ),
  // ── 24 ───────────────────────────────────────
  'clam_chowder': FoodEntry(
    name: '클램 차우더',
    calories: 190,
    carbs: 20.0,
    protein: 9.0,
    fat: 8.0,
    servingUnit: 'g',
    servingAmount: 240,
    minAmount: 100,
    maxAmount: 600,
  ),
  // ── 25 ───────────────────────────────────────
  'club_sandwich': FoodEntry(
    name: '클럽 샌드위치',
    calories: 540,
    carbs: 45.0,
    protein: 32.0,
    fat: 24.0,
    servingUnit: '개',
    servingAmount: 1,
    minAmount: 1,
    maxAmount: 4,
  ),
  // ── 26 ───────────────────────────────────────
  'crab_cakes': FoodEntry(
    name: '크랩 케이크',
    calories: 200,
    carbs: 14.0,
    protein: 14.0,
    fat: 10.0,
    servingUnit: '개',
    servingAmount: 2,
    minAmount: 1,
    maxAmount: 8,
  ),
  // ── 27 ───────────────────────────────────────
  'creme_brulee': FoodEntry(
    name: '크렘 브륄레',
    calories: 320,
    carbs: 28.0,
    protein: 5.0,
    fat: 21.0,
    servingUnit: 'g',
    servingAmount: 150,
    minAmount: 50,
    maxAmount: 300,
  ),
  // ── 28 ───────────────────────────────────────
  'croque_madame': FoodEntry(
    name: '크로크 마담',
    calories: 560,
    carbs: 36.0,
    protein: 28.0,
    fat: 34.0,
    servingUnit: '개',
    servingAmount: 1,
    minAmount: 1,
    maxAmount: 4,
  ),
  // ── 29 ───────────────────────────────────────
  'cup_cakes': FoodEntry(
    name: '컵케이크',
    calories: 305,
    carbs: 40.0,
    protein: 3.0,
    fat: 15.0,
    servingUnit: '개',
    servingAmount: 1,
    minAmount: 1,
    maxAmount: 10,
  ),
  // ── 30 ───────────────────────────────────────
  'deviled_eggs': FoodEntry(
    name: '데빌드 에그',
    calories: 130,
    carbs: 1.0,
    protein: 8.0,
    fat: 10.0,
    servingUnit: '개',
    servingAmount: 2,
    minAmount: 1,
    maxAmount: 12,
  ),
  // ── 31 ───────────────────────────────────────
  'donuts': FoodEntry(
    name: '도넛',
    calories: 195,
    carbs: 22.0,
    protein: 2.5,
    fat: 11.0,
    servingUnit: '개',
    servingAmount: 1,
    minAmount: 1,
    maxAmount: 10,
  ),
  // ── 32 ───────────────────────────────────────
  'dumplings': FoodEntry(
    name: '만두',
    calories: 280,
    carbs: 36.0,
    protein: 14.0,
    fat: 8.0,
    servingUnit: '개',
    servingAmount: 6,
    minAmount: 1,
    maxAmount: 24,
  ),
  // ── 33 ───────────────────────────────────────
  'edamame': FoodEntry(
    name: '에다마메',
    calories: 121,
    carbs: 9.0,
    protein: 11.0,
    fat: 5.0,
    servingUnit: 'g',
    servingAmount: 100,
    minAmount: 50,
    maxAmount: 400,
  ),
  // ── 34 ───────────────────────────────────────
  'eggs_benedict': FoodEntry(
    name: '에그 베네딕트',
    calories: 520,
    carbs: 28.0,
    protein: 24.0,
    fat: 34.0,
    servingUnit: '개',
    servingAmount: 2,
    minAmount: 1,
    maxAmount: 6,
  ),
  // ── 35 ───────────────────────────────────────
  'escargots': FoodEntry(
    name: '에스카르고',
    calories: 140,
    carbs: 4.0,
    protein: 16.0,
    fat: 7.0,
    servingUnit: '개',
    servingAmount: 6,
    minAmount: 1,
    maxAmount: 18,
  ),
  // ── 36 ───────────────────────────────────────
  'falafel': FoodEntry(
    name: '팔라펠',
    calories: 330,
    carbs: 32.0,
    protein: 13.0,
    fat: 18.0,
    servingUnit: '개',
    servingAmount: 4,
    minAmount: 1,
    maxAmount: 16,
  ),
  // ── 37 ───────────────────────────────────────
  'filet_mignon': FoodEntry(
    name: '필레 미뇽',
    calories: 500,
    carbs: 0.0,
    protein: 52.0,
    fat: 32.0,
    servingUnit: 'g',
    servingAmount: 200,
    minAmount: 100,
    maxAmount: 500,
  ),
  // ── 38 ───────────────────────────────────────
  'fish_and_chips': FoodEntry(
    name: '피시 앤 칩스',
    calories: 800,
    carbs: 80.0,
    protein: 35.0,
    fat: 38.0,
    servingUnit: 'g',
    servingAmount: 400,
    minAmount: 200,
    maxAmount: 800,
  ),
  // ── 39 ───────────────────────────────────────
  'foie_gras': FoodEntry(
    name: '푸아그라',
    calories: 210,
    carbs: 4.0,
    protein: 8.0,
    fat: 18.0,
    servingUnit: 'g',
    servingAmount: 60,
    minAmount: 30,
    maxAmount: 200,
  ),
  // ── 40 ───────────────────────────────────────
  'french_fries': FoodEntry(
    name: '감자튀김',
    calories: 430,
    carbs: 56.0,
    protein: 5.0,
    fat: 20.0,
    servingUnit: 'g',
    servingAmount: 150,
    minAmount: 50,
    maxAmount: 500,
  ),
  // ── 41 ───────────────────────────────────────
  'french_onion_soup': FoodEntry(
    name: '프렌치 어니언 수프',
    calories: 240,
    carbs: 30.0,
    protein: 12.0,
    fat: 8.0,
    servingUnit: 'g',
    servingAmount: 300,
    minAmount: 100,
    maxAmount: 600,
  ),
  // ── 42 ───────────────────────────────────────
  'french_toast': FoodEntry(
    name: '프렌치 토스트',
    calories: 380,
    carbs: 44.0,
    protein: 12.0,
    fat: 16.0,
    servingUnit: '장',
    servingAmount: 2,
    minAmount: 1,
    maxAmount: 10,
  ),
  // ── 43 ───────────────────────────────────────
  'fried_calamari': FoodEntry(
    name: '프라이드 칼라마리',
    calories: 380,
    carbs: 36.0,
    protein: 22.0,
    fat: 16.0,
    servingUnit: 'g',
    servingAmount: 150,
    minAmount: 50,
    maxAmount: 400,
  ),
  // ── 44 ───────────────────────────────────────
  'fried_rice': FoodEntry(
    name: '볶음밥',
    calories: 450,
    carbs: 65.0,
    protein: 14.0,
    fat: 14.0,
    servingUnit: 'g',
    servingAmount: 250,
    minAmount: 100,
    maxAmount: 600,
  ),
  // ── 45 ───────────────────────────────────────
  'frozen_yogurt': FoodEntry(
    name: '프로즌 요거트',
    calories: 130,
    carbs: 24.0,
    protein: 4.0,
    fat: 2.0,
    servingUnit: '스쿱',
    servingAmount: 1,
    minAmount: 1,
    maxAmount: 5,
  ),
  // ── 46 ───────────────────────────────────────
  'garlic_bread': FoodEntry(
    name: '마늘빵',
    calories: 180,
    carbs: 24.0,
    protein: 4.0,
    fat: 8.0,
    servingUnit: '조각',
    servingAmount: 2,
    minAmount: 1,
    maxAmount: 8,
  ),
  // ── 47 ───────────────────────────────────────
  'gnocchi': FoodEntry(
    name: '뇨키',
    calories: 320,
    carbs: 56.0,
    protein: 8.0,
    fat: 7.0,
    servingUnit: 'g',
    servingAmount: 200,
    minAmount: 100,
    maxAmount: 500,
  ),
  // ── 48 ───────────────────────────────────────
  'greek_salad': FoodEntry(
    name: '그릭 샐러드',
    calories: 180,
    carbs: 14.0,
    protein: 6.0,
    fat: 12.0,
    servingUnit: 'g',
    servingAmount: 200,
    minAmount: 100,
    maxAmount: 500,
  ),
  // ── 49 ───────────────────────────────────────
  'grilled_cheese_sandwich': FoodEntry(
    name: '그릴드 치즈 샌드위치',
    calories: 450,
    carbs: 36.0,
    protein: 18.0,
    fat: 26.0,
    servingUnit: '개',
    servingAmount: 1,
    minAmount: 1,
    maxAmount: 4,
  ),
  // ── 50 ───────────────────────────────────────
  'grilled_salmon': FoodEntry(
    name: '연어 구이',
    calories: 350,
    carbs: 0.0,
    protein: 42.0,
    fat: 18.0,
    servingUnit: 'g',
    servingAmount: 200,
    minAmount: 50,
    maxAmount: 500,
  ),
  // ── 51 ───────────────────────────────────────
  'guacamole': FoodEntry(
    name: '과카몰레',
    calories: 160,
    carbs: 9.0,
    protein: 2.0,
    fat: 15.0,
    servingUnit: 'g',
    servingAmount: 100,
    minAmount: 50,
    maxAmount: 300,
  ),
  // ── 52 ───────────────────────────────────────
  'gyoza': FoodEntry(
    name: '교자',
    calories: 260,
    carbs: 28.0,
    protein: 12.0,
    fat: 10.0,
    servingUnit: '개',
    servingAmount: 6,
    minAmount: 1,
    maxAmount: 24,
  ),
  // ── 53 ───────────────────────────────────────
  'hamburger': FoodEntry(
    name: '햄버거',
    calories: 480,
    carbs: 40.0,
    protein: 26.0,
    fat: 24.0,
    servingUnit: '개',
    servingAmount: 1,
    minAmount: 1,
    maxAmount: 5,
  ),
  // ── 54 ───────────────────────────────────────
  'hot_and_sour_soup': FoodEntry(
    name: '산라탕',
    calories: 120,
    carbs: 16.0,
    protein: 8.0,
    fat: 3.0,
    servingUnit: 'g',
    servingAmount: 300,
    minAmount: 100,
    maxAmount: 600,
  ),
  // ── 55 ───────────────────────────────────────
  'hot_dog': FoodEntry(
    name: '핫도그',
    calories: 280,
    carbs: 24.0,
    protein: 12.0,
    fat: 16.0,
    servingUnit: '개',
    servingAmount: 1,
    minAmount: 1,
    maxAmount: 5,
  ),
  // ── 56 ───────────────────────────────────────
  'huevos_rancheros': FoodEntry(
    name: '우에보스 란체로스',
    calories: 430,
    carbs: 38.0,
    protein: 22.0,
    fat: 20.0,
    servingUnit: 'g',
    servingAmount: 300,
    minAmount: 150,
    maxAmount: 600,
  ),
  // ── 57 ───────────────────────────────────────
  'hummus': FoodEntry(
    name: '후무스',
    calories: 177,
    carbs: 20.0,
    protein: 8.0,
    fat: 9.0,
    servingUnit: 'g',
    servingAmount: 100,
    minAmount: 50,
    maxAmount: 300,
  ),
  // ── 58 ───────────────────────────────────────
  'ice_cream': FoodEntry(
    name: '아이스크림',
    calories: 207,
    carbs: 24.0,
    protein: 3.5,
    fat: 11.0,
    servingUnit: '스쿱',
    servingAmount: 1,
    minAmount: 1,
    maxAmount: 5,
  ),
  // ── 59 ───────────────────────────────────────
  'lasagna': FoodEntry(
    name: '라자냐',
    calories: 600,
    carbs: 56.0,
    protein: 32.0,
    fat: 26.0,
    servingUnit: 'g',
    servingAmount: 350,
    minAmount: 150,
    maxAmount: 700,
  ),
  // ── 60 ───────────────────────────────────────
  'lobster_bisque': FoodEntry(
    name: '랍스터 비스크',
    calories: 220,
    carbs: 16.0,
    protein: 14.0,
    fat: 12.0,
    servingUnit: 'g',
    servingAmount: 240,
    minAmount: 100,
    maxAmount: 500,
  ),
  // ── 61 ───────────────────────────────────────
  'lobster_roll_sandwich': FoodEntry(
    name: '랍스터 롤 샌드위치',
    calories: 480,
    carbs: 36.0,
    protein: 32.0,
    fat: 22.0,
    servingUnit: '개',
    servingAmount: 1,
    minAmount: 1,
    maxAmount: 3,
  ),
  // ── 62 ───────────────────────────────────────
  'macaroni_and_cheese': FoodEntry(
    name: '맥앤치즈',
    calories: 490,
    carbs: 56.0,
    protein: 18.0,
    fat: 20.0,
    servingUnit: 'g',
    servingAmount: 250,
    minAmount: 100,
    maxAmount: 600,
  ),
  // ── 63 ───────────────────────────────────────
  'macarons': FoodEntry(
    name: '마카롱',
    calories: 75,
    carbs: 12.0,
    protein: 1.5,
    fat: 2.5,
    servingUnit: '개',
    servingAmount: 2,
    minAmount: 1,
    maxAmount: 12,
  ),
  // ── 64 ───────────────────────────────────────
  'miso_soup': FoodEntry(
    name: '미소국',
    calories: 84,
    carbs: 8.0,
    protein: 6.0,
    fat: 3.0,
    servingUnit: 'g',
    servingAmount: 200,
    minAmount: 100,
    maxAmount: 500,
  ),
  // ── 65 ───────────────────────────────────────
  'mussels': FoodEntry(
    name: '홍합찜',
    calories: 200,
    carbs: 10.0,
    protein: 26.0,
    fat: 5.0,
    servingUnit: 'g',
    servingAmount: 200,
    minAmount: 100,
    maxAmount: 500,
  ),
  // ── 66 ───────────────────────────────────────
  'nachos': FoodEntry(
    name: '나초',
    calories: 540,
    carbs: 60.0,
    protein: 18.0,
    fat: 28.0,
    servingUnit: 'g',
    servingAmount: 200,
    minAmount: 100,
    maxAmount: 500,
  ),
  // ── 67 ───────────────────────────────────────
  'omelette': FoodEntry(
    name: '오믈렛',
    calories: 220,
    carbs: 2.0,
    protein: 16.0,
    fat: 16.0,
    servingUnit: '개',
    servingAmount: 1,
    minAmount: 1,
    maxAmount: 4,
  ),
  // ── 68 ───────────────────────────────────────
  'onion_rings': FoodEntry(
    name: '어니언 링',
    calories: 380,
    carbs: 42.0,
    protein: 5.0,
    fat: 21.0,
    servingUnit: 'g',
    servingAmount: 100,
    minAmount: 50,
    maxAmount: 400,
  ),
  // ── 69 ───────────────────────────────────────
  'oysters': FoodEntry(
    name: '굴',
    calories: 100,
    carbs: 6.0,
    protein: 14.0,
    fat: 3.0,
    servingUnit: '개',
    servingAmount: 6,
    minAmount: 1,
    maxAmount: 24,
  ),
  // ── 70 ───────────────────────────────────────
  'pad_thai': FoodEntry(
    name: '팟타이',
    calories: 490,
    carbs: 60.0,
    protein: 22.0,
    fat: 18.0,
    servingUnit: 'g',
    servingAmount: 300,
    minAmount: 100,
    maxAmount: 600,
  ),
  // ── 71 ───────────────────────────────────────
  'paella': FoodEntry(
    name: '파에야',
    calories: 520,
    carbs: 60.0,
    protein: 30.0,
    fat: 16.0,
    servingUnit: 'g',
    servingAmount: 350,
    minAmount: 150,
    maxAmount: 700,
  ),
  // ── 72 ───────────────────────────────────────
  'pancakes': FoodEntry(
    name: '팬케이크',
    calories: 350,
    carbs: 52.0,
    protein: 10.0,
    fat: 10.0,
    servingUnit: '개',
    servingAmount: 3,
    minAmount: 1,
    maxAmount: 12,
  ),
  // ── 73 ───────────────────────────────────────
  'panna_cotta': FoodEntry(
    name: '판나코타',
    calories: 230,
    carbs: 24.0,
    protein: 5.0,
    fat: 14.0,
    servingUnit: 'g',
    servingAmount: 150,
    minAmount: 50,
    maxAmount: 400,
  ),
  // ── 74 ───────────────────────────────────────
  'peking_duck': FoodEntry(
    name: '베이징 덕',
    calories: 580,
    carbs: 12.0,
    protein: 44.0,
    fat: 40.0,
    servingUnit: 'g',
    servingAmount: 200,
    minAmount: 100,
    maxAmount: 500,
  ),
  // ── 75 ───────────────────────────────────────
  'pho': FoodEntry(
    name: '쌀국수(포)',
    calories: 440,
    carbs: 60.0,
    protein: 28.0,
    fat: 10.0,
    servingUnit: 'g',
    servingAmount: 500,
    minAmount: 250,
    maxAmount: 800,
  ),
  // ── 76 ───────────────────────────────────────
  'pizza': FoodEntry(
    name: '피자',
    calories: 285,
    carbs: 35.7,
    protein: 12.2,
    fat: 10.4,
    servingUnit: '조각',
    servingAmount: 1,
    minAmount: 1,
    maxAmount: 10,
  ),
  // ── 77 ───────────────────────────────────────
  'pork_chop': FoodEntry(
    name: '포크 찹',
    calories: 440,
    carbs: 0.0,
    protein: 44.0,
    fat: 28.0,
    servingUnit: 'g',
    servingAmount: 200,
    minAmount: 100,
    maxAmount: 500,
  ),
  // ── 78 ───────────────────────────────────────
  'poutine': FoodEntry(
    name: '푸틴',
    calories: 740,
    carbs: 70.0,
    protein: 22.0,
    fat: 42.0,
    servingUnit: 'g',
    servingAmount: 300,
    minAmount: 150,
    maxAmount: 600,
  ),
  // ── 79 ───────────────────────────────────────
  'prime_rib': FoodEntry(
    name: '프라임 립',
    calories: 620,
    carbs: 0.0,
    protein: 48.0,
    fat: 46.0,
    servingUnit: 'g',
    servingAmount: 200,
    minAmount: 100,
    maxAmount: 500,
  ),
  // ── 80 ───────────────────────────────────────
  'pulled_pork_sandwich': FoodEntry(
    name: '풀드 포크 샌드위치',
    calories: 580,
    carbs: 44.0,
    protein: 38.0,
    fat: 22.0,
    servingUnit: '개',
    servingAmount: 1,
    minAmount: 1,
    maxAmount: 3,
  ),
  // ── 81 ───────────────────────────────────────
  'ramen': FoodEntry(
    name: '라면',
    calories: 510,
    carbs: 68.0,
    protein: 18.0,
    fat: 18.0,
    servingUnit: '개',
    servingAmount: 1,
    minAmount: 1,
    maxAmount: 3,
  ),
  // ── 82 ───────────────────────────────────────
  'ravioli': FoodEntry(
    name: '라비올리',
    calories: 380,
    carbs: 48.0,
    protein: 16.0,
    fat: 14.0,
    servingUnit: 'g',
    servingAmount: 200,
    minAmount: 100,
    maxAmount: 500,
  ),
  // ── 83 ───────────────────────────────────────
  'red_velvet_cake': FoodEntry(
    name: '레드 벨벳 케이크',
    calories: 370,
    carbs: 50.0,
    protein: 4.5,
    fat: 17.0,
    servingUnit: '조각',
    servingAmount: 1,
    minAmount: 1,
    maxAmount: 8,
  ),
  // ── 84 ───────────────────────────────────────
  'risotto': FoodEntry(
    name: '리조또',
    calories: 420,
    carbs: 56.0,
    protein: 12.0,
    fat: 14.0,
    servingUnit: 'g',
    servingAmount: 280,
    minAmount: 100,
    maxAmount: 600,
  ),
  // ── 85 ───────────────────────────────────────
  'samosa': FoodEntry(
    name: '사모사',
    calories: 260,
    carbs: 32.0,
    protein: 5.0,
    fat: 13.0,
    servingUnit: '개',
    servingAmount: 2,
    minAmount: 1,
    maxAmount: 10,
  ),
  // ── 86 ───────────────────────────────────────
  'sashimi': FoodEntry(
    name: '사시미',
    calories: 180,
    carbs: 0.0,
    protein: 32.0,
    fat: 5.0,
    servingUnit: '피스',
    servingAmount: 6,
    minAmount: 1,
    maxAmount: 24,
  ),
  // ── 87 ───────────────────────────────────────
  'scallops': FoodEntry(
    name: '가리비',
    calories: 150,
    carbs: 4.0,
    protein: 26.0,
    fat: 3.0,
    servingUnit: '개',
    servingAmount: 4,
    minAmount: 1,
    maxAmount: 16,
  ),
  // ── 88 ───────────────────────────────────────
  'seaweed_salad': FoodEntry(
    name: '해초 샐러드',
    calories: 70,
    carbs: 10.0,
    protein: 2.0,
    fat: 3.0,
    servingUnit: 'g',
    servingAmount: 100,
    minAmount: 50,
    maxAmount: 300,
  ),
  // ── 89 ───────────────────────────────────────
  'shrimp_and_grits': FoodEntry(
    name: '새우 그릿츠',
    calories: 480,
    carbs: 44.0,
    protein: 26.0,
    fat: 20.0,
    servingUnit: 'g',
    servingAmount: 300,
    minAmount: 150,
    maxAmount: 600,
  ),
  // ── 90 ───────────────────────────────────────
  'spaghetti_bolognese': FoodEntry(
    name: '스파게티 볼로네제',
    calories: 520,
    carbs: 62.0,
    protein: 28.0,
    fat: 16.0,
    servingUnit: 'g',
    servingAmount: 300,
    minAmount: 100,
    maxAmount: 600,
  ),
  // ── 91 ───────────────────────────────────────
  'spaghetti_carbonara': FoodEntry(
    name: '스파게티 카르보나라',
    calories: 580,
    carbs: 60.0,
    protein: 24.0,
    fat: 26.0,
    servingUnit: 'g',
    servingAmount: 300,
    minAmount: 100,
    maxAmount: 600,
  ),
  // ── 92 ───────────────────────────────────────
  'spring_rolls': FoodEntry(
    name: '스프링 롤',
    calories: 90,
    carbs: 12.0,
    protein: 3.0,
    fat: 4.0,
    servingUnit: '개',
    servingAmount: 3,
    minAmount: 1,
    maxAmount: 12,
  ),
  // ── 93 ───────────────────────────────────────
  'steak': FoodEntry(
    name: '스테이크',
    calories: 480,
    carbs: 0.0,
    protein: 52.0,
    fat: 28.0,
    servingUnit: 'g',
    servingAmount: 200,
    minAmount: 100,
    maxAmount: 500,
  ),
  // ── 94 ───────────────────────────────────────
  'strawberry_shortcake': FoodEntry(
    name: '딸기 쇼트케이크',
    calories: 320,
    carbs: 44.0,
    protein: 5.0,
    fat: 14.0,
    servingUnit: '조각',
    servingAmount: 1,
    minAmount: 1,
    maxAmount: 8,
  ),
  // ── 95 ───────────────────────────────────────
  'sushi': FoodEntry(
    name: '스시',
    calories: 310,
    carbs: 50.0,
    protein: 18.0,
    fat: 4.0,
    servingUnit: '피스',
    servingAmount: 6,
    minAmount: 1,
    maxAmount: 24,
  ),
  // ── 96 ───────────────────────────────────────
  'tacos': FoodEntry(
    name: '타코',
    calories: 370,
    carbs: 36.0,
    protein: 20.0,
    fat: 16.0,
    servingUnit: '개',
    servingAmount: 2,
    minAmount: 1,
    maxAmount: 10,
  ),
  // ── 97 ───────────────────────────────────────
  'takoyaki': FoodEntry(
    name: '타코야키',
    calories: 280,
    carbs: 28.0,
    protein: 12.0,
    fat: 14.0,
    servingUnit: '개',
    servingAmount: 6,
    minAmount: 1,
    maxAmount: 24,
  ),
  // ── 98 ───────────────────────────────────────
  'tiramisu': FoodEntry(
    name: '티라미수',
    calories: 340,
    carbs: 36.0,
    protein: 7.0,
    fat: 18.0,
    servingUnit: 'g',
    servingAmount: 150,
    minAmount: 50,
    maxAmount: 400,
  ),
  // ── 99 ───────────────────────────────────────
  'tuna_tartare': FoodEntry(
    name: '참치 타르타르',
    calories: 220,
    carbs: 6.0,
    protein: 30.0,
    fat: 8.0,
    servingUnit: 'g',
    servingAmount: 150,
    minAmount: 50,
    maxAmount: 400,
  ),
  // ── 100 ──────────────────────────────────────
  'waffles': FoodEntry(
    name: '와플',
    calories: 290,
    carbs: 40.0,
    protein: 8.0,
    fat: 12.0,
    servingUnit: '개',
    servingAmount: 1,
    minAmount: 1,
    maxAmount: 5,
  ),
};
