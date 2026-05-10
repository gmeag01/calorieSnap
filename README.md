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

**인식 가능한 음식 20가지:**

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

---

## 아키텍처

```
┌──────────────────────────────────────────────────────────────┐
│                        UI Layer                              │
├─────────────────┬──────────────────┬─────────────────────────┤
│ OnboardingScreen│   HomeScreen     │     RecordsScreen       │
│  (신체정보 입력) │ (영양추적 + 촬영) │   (오늘 식사 기록)       │
└─────────────────┴──────────────────┴─────────────────────────┘
                              │
                     AppProvider (Provider)
                    ┌──────────────────┐
                    │  UserProfile     │  ← 신체정보 & 영양 목표
                    │  List<MealRecord>│  ← 오늘 식사 캐시
                    └──────────────────┘
                       │            │
          ┌────────────┘            └────────────────┐
          ▼                                          ▼
  Hive Local DB                          FoodAnalysisService
  ┌──────────────┐                       ┌──────────────────────┐
  │ UserProfile  │                       │ CenterCrop + Resize   │
  │ MealRecord   │                       │ EfficientNetV2B0      │
  └──────────────┘                       │ Confidence Filter     │
                                         │ FoodDatabase Lookup   │
                                         └──────────────────────┘
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

### 모델 재학습 (선택)

`assets/models/calorie_snap_final.ipynb`를 Google Colab (T4 GPU)에서 실행하면 모델을 직접 학습할 수 있습니다. 학습 후 생성된 `.tflite`와 `labels.json` 파일을 `assets/models/`에 교체하세요.

---

## 문제 해결

| 증상 | 해결 방법 |
|------|----------|
| TFLite 모델 로드 실패 | `pubspec.yaml`의 `assets` 경로 확인 |
| Android 빌드 오류 | `compileSdkVersion ≥ 34`, `aaptOptions { noCompress += "tflite" }` 확인 |
| 신뢰도가 낮아 음식 미인식 | 음식이 화면 중앙에 위치하도록 촬영, 또는 Colab에서 재학습 |

---

## License

This project is open source.
