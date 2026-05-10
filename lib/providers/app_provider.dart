import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../models/user_profile.dart';
import '../models/meal_record.dart';

class AppProvider extends ChangeNotifier {
  // DateFormat 인스턴스 재사용 — 매 호출마다 생성하면 불필요한 객체 생성
  static final _dateFmt = DateFormat('yyyy-MM-dd');

  UserProfile? _userProfile;

  // todayRecords는 addMealRecord / deleteMealRecord 시 무효화
  // 렌더 사이클마다 box scan이 반복되는 것을 방지
  List<MealRecord>? _todayCache;

  UserProfile? get userProfile => _userProfile;

  List<MealRecord> get todayRecords => _todayCache ??= _buildTodayRecords();

  List<MealRecord> _buildTodayRecords() {
    final today = _dateFmt.format(DateTime.now());
    return Hive.box<MealRecord>('mealRecords').values
        .where((r) => _dateFmt.format(r.recordedAt) == today)
        .toList()
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
  }

  AppProvider() {
    _loadProfile();
  }

  void _loadProfile() {
    final box = Hive.box<UserProfile>('userProfile');
    if (box.isNotEmpty) _userProfile = box.getAt(0);
  }

  Future<void> saveProfile(UserProfile profile) async {
    final box = Hive.box<UserProfile>('userProfile');
    await box.clear();
    await box.add(profile);
    _userProfile = profile;
    notifyListeners();
  }

  Future<void> addMealRecord(MealRecord record) async {
    await Hive.box<MealRecord>('mealRecords').add(record);
    _todayCache = null;
    notifyListeners();
  }

  Future<void> deleteMealRecord(MealRecord record) async {
    final box = Hive.box<MealRecord>('mealRecords');
    for (final key in box.keys) {
      final r = box.get(key);
      if (r != null &&
          r.recordedAt == record.recordedAt &&
          r.foodName == record.foodName) {
        await box.delete(key);
        break;
      }
    }
    _todayCache = null;
    notifyListeners();
  }

  double get totalCalories => todayRecords.fold(0.0, (s, r) => s + r.calories);
  double get totalCarbs    => todayRecords.fold(0.0, (s, r) => s + r.carbs);
  double get totalProtein  => todayRecords.fold(0.0, (s, r) => s + r.protein);
  double get totalFat      => todayRecords.fold(0.0, (s, r) => s + r.fat);

  bool get isAnyNutrientOver {
    if (_userProfile == null) return false;
    return totalCalories > _userProfile!.dailyCalories ||
        totalCarbs    > _userProfile!.dailyCarbs    ||
        totalProtein  > _userProfile!.dailyProtein  ||
        totalFat      > _userProfile!.dailyFat;
  }
}
