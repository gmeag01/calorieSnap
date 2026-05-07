# 📋 CalorieSnap 온디바이스 TFLite 통합 — 최종 정리

## 🎯 핵심 변경사항

### 1. Flutter 3개 파일 수정
| 파일 | 변경 내용 | 영향 |
|------|-----------|------|
| `pubspec.yaml` | `tflite_flutter` + `image` 추가 | 온디바이스 추론 가능 |
| `lib/data/food_database.dart` | 20개 클래스로 업데이트 | Colab 학습과 연동 |
| `lib/services/food_analysis_service.dart` | 더미 → TFLite 실제 추론 | **CenterCrop으로 비율 보존** |

### 2. Colab 학습 노트북
- **총 12개 섹션** — 설치부터 TFLite 변환까지 완전자동
- **INT8 양자화** — 모델 크기 ~3.5MB (fp32 13MB → int8 3.5MB)
- **2단계 학습** — 헤드 학습 + 전체 파인튜닝으로 정확도 최적화

---

## 🖼️ 이미지 전처리 개선 (중요!)

### 이전 (문제점)
```
원본 1920×1080
  ↓
강제 리사이즈 224×224 (stretch)
  ↓
이미지 찌그러짐 → 정확도 감소
```

### 개선됨 (현재)
```
원본 1920×1080
  ↓
CenterCrop 1080×1080 (정사각형, 비율 유지)
  ↓
리사이즈 224×224
  ↓
이미지 왜곡 없음 → 정확도 향상
```

**Flutter 코드:**
```dart
// Step 1: CenterCrop (비율 유지)
final w = decoded.width;
final h = decoded.height;
final cropSize = w < h ? w : h;
final offsetX = (w - cropSize) ~/ 2;
final offsetY = (h - cropSize) ~/ 2;
final cropped = img.copyCrop(decoded, x: offsetX, y: offsetY, 
                            width: cropSize, height: cropSize);

// Step 2: 224×224 리사이즈
final resized = img.copyResize(cropped, width: 224, height: 224);
```

---

## 📌 반드시 수행할 작업

### A. Colab 노트북 실행
1. Google Colab에서 `calorie_snap_train.ipynb` 열기
2. **⚠️ 섹션 5 "데이터 전처리 파이프라인"에서 CenterCrop 코드 적용**
   - 파일 `colab/PREPROCESSING_UPDATE.md` 참고
3. 나머지 섹션 실행 (학습 후 다운로드)

### B. 모델 파일 배치
Colab에서 다운로드한 2개 파일을 Flutter 프로젝트에 복사:
```
calorieSnap/assets/models/
  ├── mobilenet_v4_food.tflite  ← Colab 다운로드
  └── labels.json               ← Colab 다운로드
```

### C. Android 빌드 설정
`android/app/build.gradle.kts` (또는 `.gradle`) 추가:
```kotlin
aaptOptions {
    noCompress += listOf("tflite")  // TFLite 압축 방지
}
```

### D. Flutter 실행
```bash
cd calorieSnap
flutter pub get
flutter run
```

---

## 🔄 데이터 흐름 (최종)

```
┌─────────────────┐
│ 사진 촬영        │ image_picker.pickImage()
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────┐
│ CenterCrop + 리사이즈            │ 
│ • 1920×1080 → 1080×1080 자르기 │
│ • 1080×1080 → 224×224 리사이즈  │
│ • pixel / 255.0 → [0, 1] 정규화 │
└────────┬────────────────────────┘
         │
         ▼
┌──────────────────────────────────┐
│ TFLite 추론                       │ tflite_flutter
│ input: [1][224][224][3]         │ output: [1][20]
│ MobileNetV4 INT8 (3.5MB)        │ softmax 확률
└────────┬───────────────────────┘
         │
         ▼
┌──────────────────────────────────┐
│ argmax + 신뢰도 필터 (≥0.55)     │
└────────┬───────────────────────┘
         │ (< 0.55면 → "미등록")
         ▼
┌──────────────────────────────────┐
│ kLabelsList[index] → label       │ index 0~19 매핑
└────────┬───────────────────────┘
         │
         ▼
┌──────────────────────────────────┐
│ kFoodDatabase[label] → FoodEntry │ 영양정보 조회
└────────┬───────────────────────┘
         │
         ▼
┌──────────────────────────────────┐
│ FoodAnalysisResult → UI 반영     │ 프로그레스바 갱신
└──────────────────────────────────┘
```

---

## 🚀 최적화 팁

| 항목 | 설정 | 효과 |
|------|------|------|
| 추론 속도 | `InterpreterOptions()..threads = 4` | 4배 병렬 처리 |
| 모델 크기 | INT8 양자화 (Colab) | 13MB → 3.5MB |
| 정확도 | CenterCrop 전처리 | 이미지 왜곡 제거 |
| 빌드 | `noCompress += "tflite"` | 런타임 압축 해제 불필요 |

---

## 📦 파일 구조

```
calorieSnap/
├── assets/
│   └── models/
│       ├── mobilenet_v4_food.tflite  ← Colab 생성
│       └── labels.json
├── lib/
│   ├── data/
│   │   └── food_database.dart        ← 20개 클래스
│   ├── services/
│   │   └── food_analysis_service.dart ← TFLite 추론
│   ├── screens/ (기존)
│   ├── widgets/ (기존)
│   ├── providers/ (기존)
│   └── models/ (기존)
├── pubspec.yaml                      ← tflite_flutter 추가
└── android/app/build.gradle.kts      ← noCompress 추가
```

---

## ⚙️ Colab 체크리스트

- [ ] 런타임: T4 GPU 선택
- [ ] 섹션 1: pip install 실행
- [ ] 섹션 2: Google Drive 마운트
- [ ] **섹션 5: CenterCrop 코드 적용** ⚠️
- [ ] 섹션 6~8: 모델 구성 & 학습
- [ ] 섹션 10: TFLite 변환 & 검증
- [ ] 섹션 12: Drive 저장 → 다운로드

---

## 🐛 문제 해결

### "TFLite 모델을 찾을 수 없음" 오류
```
E: FileNotFoundError: assets/models/mobilenet_v4_food.tflite
```
**해결:** `pubspec.yaml`의 `flutter.assets` 섹션 확인 및 파일 경로 검증

### "신뢰도가 계속 낮음" (자주 "미등록" 반환)
1. Colab 학습 accuracy가 충분한지 확인 (최소 85%)
2. `_kThreshold` 값 낮춤 (0.55 → 0.45)
3. Colab 데이터 증강 재점검

### Android 빌드 오류
```
error: resource android:attr/lStar not found
```
**해결:** `build.gradle.kts`에서 compileSdkVersion ≥ 34 확인

---

## 📞 최종 체크

- ✅ 두 파일의 전처리 방식이 동일한가?
- ✅ `kLabelsList` 순서 = Colab `SELECTED_CLASSES` 순서인가?
- ✅ 모델 입력 shape [1][224][224][3]인가?
- ✅ `assets/models/` 폴더 생성 & 파일 복사 완료인가?

모든 항목이 체크되면 배포 준비 완료! 🎉
