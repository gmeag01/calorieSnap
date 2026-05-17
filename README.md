# CalorieSnap

온디바이스 AI로 음식 사진을 분석하고 일일 영양소 섭취량을 추적하는 Flutter 앱입니다. 인터넷 연결 없이 완전 오프라인으로 작동합니다.

---

## 주요 기능

- **음식 자동 인식** — 카메라 또는 갤러리 사진으로 20가지 음식을 온디바이스 TFLite 모델이 분석
- **영양소 추적** — 칼로리, 탄수화물, 단백질, 지방을 목표 대비 실시간 시각화
- **개인 맞춤 목표** — 키, 몸무게, 나이, 성별로 Mifflin-St Jeor 공식에 따른 일일 권장량 자동 계산
- **식사 기록** — 오늘의 식사 내역 조회 및 삭제 (Hive 로컬 DB 저장)
- **완전 오프라인** — 모든 추론과 저장이 디바이스 내에서 처리

---

## 기술 스택

| 레이어 | 기술 | 버전 |
|--------|------|------|
| UI Framework | Flutter (Material 3) | 3.x |
| 상태 관리 | Provider | 6.1.2 |
| 로컬 저장소 | Hive + Hive Flutter | 2.2.3 / 1.1.0 |
| 이미지 입력 | image_picker | 1.0.7 |
| ML 추론 | tflite_flutter | 0.11.0 |
| 이미지 전처리 | image | 4.1.7 |
| 날짜 처리 | intl | 0.19.0 |

---

## ML 모델

| 항목 | 내용 |
|------|------|
| 아키텍처 | EfficientNetV2B0 |
| 입력 크기 | 224 × 224 × 3 |
| 양자화 | INT8 |
| 모델 크기 | ~3.5MB |
| 클래스 수 | 20 |
| 신뢰도 임계값 | 0.55 |
| 스레드 수 | 4 |

**이미지 전처리 파이프라인:**
```
원본 이미지 → EXIF 회전 보정 → CenterCrop (정사각형) → 리사이즈 224×224 → 정규화 [-1, 1]
```

**인식 가능한 음식 예시:**

| # | 영문 | 한국어 | 칼로리(1인분) |
|---|------|--------|--------------|
| 0 | pizza | 피자 (1조각) | 285 kcal |
| 1 | hamburger | 햄버거 | 480 kcal |
| 2 | fried_rice | 볶음밥 | 450 kcal |
| 3 | ramen | 라면 | 510 kcal |
| 4 | sushi | 스시 (6피스) | 310 kcal |
| 5 | steak | 스테이크 | 480 kcal |
| 6 | donuts | 도넛 | 195 kcal |
| 7 | ice_cream | 아이스크림 (1스쿱) | 207 kcal |
| 8 | chicken_wings | 치킨 윙 (6개) | 490 kcal |
| 9 | spaghetti_bolognese | 스파게티 볼로네제 | 520 kcal |
| 10 | spaghetti_carbonara | 스파게티 카르보나라 | 580 kcal |
| 11 | cup_cakes | 컵케이크 | 305 kcal |
| 12 | french_toast | 프렌치 토스트 (2장) | 380 kcal |
| 13 | risotto | 리조또 | 420 kcal |
| 14 | macaroni_and_cheese | 맥앤치즈 | 490 kcal |
| 15 | grilled_salmon | 연어 구이 | 350 kcal |
| 16 | bibimbap | 비빔밥 | 560 kcal |
| 17 | miso_soup | 미소국 | 84 kcal |
| 18 | tacos | 타코 (2개) | 370 kcal |
| 19 | chocolate_cake | 초코 케이크 (1조각) | 370 kcal |

                        .
                        .
                        .

---

## 아키텍처

```
┌──────────────────────────────────────────────────────────────┐
│                        UI Layer                              │
├──────────────┬──────────────────┬────────────┬──────────────┤
│ Onboarding   │   HomeScreen     │ Records    │  Calendar    │
│ (신체정보)   │ (영양추적 + 촬영) │ (오늘기록) │  (날짜보기)   │
└──────────────┴──────────────────┴────────────┴──────────────┘
                              │
                     AppProvider (Provider)
                    ┌──────────────────────┐
                    │  UserProfile         │  ← 신체정보 & 영양 목표
                    │  List<MealRecord>    │  ← 캐시 (오늘만)
                    │  recordsForDate()    │  ← 날짜별 조회
                    │  allRecordDates      │  ← 캘린더 마킹용
                    └──────────────────────┘
                       │                 │
          ┌────────────┘                 └────────────────┐
          ▼                                              ▼
  Hive Local Database                    FoodAnalysisService
  ┌──────────────────┐                  ┌─────────────────────┐
  │ userProfile Box  │                  │ _buildInputTensor   │
  │ mealRecords Box  │◄─────────────────│ - EXIF 회전        │
  │ (영구 저장)       │                  │ - CenterCrop       │
  └──────────────────┘                  │ - Resize 224×224   │
                                         │ - 정규화 [-1,1]    │
                                         │                    │
                                         │ EfficientNetV2B0   │
                                         │ (TFLite INT8)      │
                                         │                    │
                                         │ FoodDatabase       │
                                         │ Lookup & Return    │
                                         └─────────────────────┘
```

---

## 프로젝트 구조

```
lib/
├── main.dart                           # 앱 진입점
├── models/
│   ├── meal_record.dart               # 음식 기록 모델 (@HiveType)
│   ├── meal_record.g.dart             # Hive 생성 코드
│   ├── user_profile.dart              # 사용자 프로필 모델 (@HiveType)
│   └── user_profile.g.dart            # Hive 생성 코드
├── providers/
│   └── app_provider.dart              # 상태 관리 (Provider)
├── screens/
│   ├── onboarding_screen.dart         # 신체정보 입력
│   ├── home_screen.dart               # 메인 화면 (촬영 + 영양추적)
│   ├── records_screen.dart            # 오늘의 기록 목록
│   └── calendar_screen.dart           # 캘린더 (날짜별 기록)
├── services/
│   └── food_analysis_service.dart     # TFLite 추론 서비스
├── widgets/
│   └── nutrition_progress_bar.dart    # 영양 진행률 바
└── data/
    └── food_database.dart             # 음식 영양정보 데이터베이스

assets/
├── models/
│   ├── efficientnetv2b0_food.tflite  # TFLite 모델 (~3.5MB)
│   ├── labels.json                   # 클래스 레이블
│   └── calorie_snap_food101_full.ipynb # 모델 학습 노트북
```

---

## 주요 파일 설명

### Models (`lib/models/`)
- **MealRecord**: 음식 기록 (음식명, 영양정보, 사진 경로, 타임스탐프)
- **UserProfile**: 사용자 신체정보 (키, 몸무게, 나이, 성별, 일일 영양 목표)
- 모두 `@HiveType` 어노테이션으로 로컬 DB 저장 지원

### Providers (`lib/providers/`)
- **AppProvider**: 단일 상태 관리 클래스
  - 신체정보 저장/로드
  - 오늘 기록 캐시 (`_todayCache`)
  - 날짜별 기록 조회 (`recordsForDate()`)
  - 영양 목표 대비 현황 계산

### Screens (`lib/screens/`)
1. **OnboardingScreen**: 신체정보 입력 (앱 시작 시 또는 설정에서)
2. **HomeScreen**: 
   - 실시간 영양소 진행률 표시
   - 카메라/갤러리로 음식 촬영
   - 사이드바 메뉴
3. **RecordsScreen**: 오늘의 기록 목록 (삭제 기능)
4. **CalendarScreen**: 
   - 월 단위 캘린더 보기
   - 기록이 있는 날 마킹 (초과 시 빨강)
   - 날짜 클릭 시 상세 기록 조회

### Services (`lib/services/`)
- **FoodAnalysisService**:
  - 이미지 전처리 (EXIF 회전, CenterCrop, 리사이즈)
  - TFLite 추론 실행
  - 신뢰도 임계값 필터링
  - 음식 데이터베이스 조회

---

## 데이터 저장

### Hive 로컬 데이터베이스
```dart
// 두 개의 Box 사용
Hive.box<UserProfile>('userProfile')    // 사용자 프로필 (1개)
Hive.box<MealRecord>('mealRecords')     // 모든 식사 기록 (영구 저장)
```

### 저장 용량 추정
- **하루 3개 기록**: 약 5-7 KB/주
- **1년 누적**: 약 270-400 KB
- **이미지**: 경로만 저장 (실제 파일은 카메라/갤러리에서 관리)

---

## 캘린더 기능

- **월 단위 보기**: 이전/다음 월 네비게이션
- **기록 마킹**: 
  - 🟢 초록 점: 기준치 이내
  - 🔴 빨강 점: 기준치 초과
- **날짜 상세**: 클릭 시 모달에서 그날의 모든 기록 표시
- **기록 관리**: 상세 보기에서 수정/삭제 가능

⚠️ **주의**: 데이터는 계속 누적되므로 수동 삭제가 필요하면 구현 검토 필요

---

## 아키텍처

```
┌──────────────────────────────────────────────────────────────┐
│                        UI Layer                              │
├──────────────┬──────────────────┬────────────┬──────────────┤
│ Onboarding   │   HomeScreen     │ Records    │  Calendar    │
│ (신체정보)   │ (영양추적 + 촬영) │ (오늘기록) │  (날짜보기)   │
└──────────────┴──────────────────┴────────────┴──────────────┘
                              │
                     AppProvider (Provider)
                    ┌──────────────────────┐
                    │  UserProfile         │  ← 신체정보 & 영양 목표
                    │  List<MealRecord>    │  ← 캐시 (오늘만)
                    │  recordsForDate()    │  ← 날짜별 조회
                    │  allRecordDates      │  ← 캘린더 마킹용
                    └──────────────────────┘
                       │                 │
          ┌────────────┘                 └────────────────┐
          ▼                                              ▼
  Hive Local Database                    FoodAnalysisService
  ┌──────────────────┐                  ┌─────────────────────┐
  │ userProfile Box  │                  │ _buildInputTensor   │
  │ mealRecords Box  │◄─────────────────│ - EXIF 회전        │
  │ (영구 저장)       │                  │ - CenterCrop       │
  └──────────────────┘                  │ - Resize 224×224   │
                                         │ - 정규화 [-1,1]    │
                                         │                    │
                                         │ EfficientNetV2B0   │
                                         │ (TFLite INT8)      │
                                         │                    │
                                         │ FoodDatabase       │
                                         │ Lookup & Return    │
                                         └─────────────────────┘
```

---

## 프로젝트 구조

```
lib/
├── main.dart                      # 앱 진입점, Hive 초기화, 라우팅
├── models/
│   ├── user_profile.dart          # 신체정보 모델 (BMR/TDEE 계산 포함)
│   ├── user_profile.g.dart        # Hive 어댑터 (자동 생성)
│   ├── meal_record.dart           # 식사 기록 모델
│   └── meal_record.g.dart         # Hive 어댑터 (자동 생성)
├── providers/
│   └── app_provider.dart          # 전역 상태 관리 (ChangeNotifier)
├── screens/
│   ├── onboarding_screen.dart     # 최초 실행 시 신체정보 입력
│   ├── home_screen.dart           # 메인 화면 (영양소 현황 + 촬영)
│   └── records_screen.dart        # 오늘 식사 기록 목록 및 삭제
├── services/
│   └── food_analysis_service.dart # TFLite 추론 서비스
├── widgets/
│   └── nutrition_progress_bar.dart# 영양소 진행률 바 위젯
└── data/
    └── food_database.dart         # 20가지 음식 영양 정보 DB

assets/
└── models/
    ├── efficientnetv2b0_food.tflite  # 학습된 TFLite 모델
    ├── labels.json                    # 음식 클래스 레이블
    └── calorie_snap_final.ipynb       # Google Colab 학습 노트북
```

---

## 설치 및 실행

### 요구 사항

- Flutter SDK 3.x 이상
- Android SDK (compileSdkVersion 34 이상) 또는 Xcode

### 설치

```bash
git clone https://github.com/gmeag01/calorieSnap.git
cd CalorieSnap_flutter
flutter pub get
flutter run
```

## License

This project is open source.
