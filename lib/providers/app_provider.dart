import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../models/user_profile.dart';
import '../models/meal_record.dart';

class AppProvider extends ChangeNotifier {
  UserProfile? _userProfile;

  UserProfile? get userProfile => _userProfile;
  
  List<MealRecord> get todayRecords {
    final box = Hive.box<MealRecord>('mealRecords');
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return box.keys
        .map((key) => box.get(key))
        .whereType<MealRecord>()
        .where((r) => DateFormat('yyyy-MM-dd').format(r.recordedAt) == today)
        .toList()
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
  }

  AppProvider() {
    _loadProfile();
  }

  // ────────────────────────────────────────────
  //  로딩
  // ────────────────────────────────────────────
  void _loadProfile() {
    final box = Hive.box<UserProfile>('userProfile');
    if (box.isNotEmpty) {
      _userProfile = box.getAt(0);
    }
  }

  // ────────────────────────────────────────────
  //  프로필 저장 / 수정
  // ────────────────────────────────────────────
  Future<void> saveProfile(UserProfile profile) async {
    final box = Hive.box<UserProfile>('userProfile');
    await box.clear();
    await box.add(profile);
    _userProfile = profile;
    notifyListeners();
  }

  // ────────────────────────────────────────────
  //  식사 기록 추가 / 삭제
  // ────────────────────────────────────────────
  Future<void> addMealRecord(MealRecord record) async {
    final box = Hive.box<MealRecord>('mealRecords');
    await box.add(record);
    notifyListeners();
  }

  Future<void> deleteMealRecord(MealRecord record) async {
    final box = Hive.box<MealRecord>('mealRecords');
    // recordedAt과 foodName으로 해당 기록을 찾아 삭제
    for (var key in box.keys) {
      final r = box.get(key);
      if (r != null && 
          r.recordedAt == record.recordedAt && 
          r.foodName == record.foodName) {
        await box.delete(key);
        break;
      }
    }
    notifyListeners();
  }

  // ────────────────────────────────────────────
  //  오늘 섭취량 합계
  // ────────────────────────────────────────────
  double get totalCalories =>
      todayRecords.fold(0.0, (sum, r) => sum + r.calories);
  double get totalCarbs =>
      todayRecords.fold(0.0, (sum, r) => sum + r.carbs);
  double get totalProtein =>
      todayRecords.fold(0.0, (sum, r) => sum + r.protein);
  double get totalFat =>
      todayRecords.fold(0.0, (sum, r) => sum + r.fat);

  // ────────────────────────────────────────────
  //  초과 여부 (하나라도 초과하면 true)
  // ────────────────────────────────────────────
  bool get isAnyNutrientOver {
    if (_userProfile == null) return false;
    return totalCalories > _userProfile!.dailyCalories ||
        totalCarbs > _userProfile!.dailyCarbs ||
        totalProtein > _userProfile!.dailyProtein ||
        totalFat > _userProfile!.dailyFat;
  }
}
