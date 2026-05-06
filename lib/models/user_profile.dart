import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 0)
class UserProfile extends HiveObject {
  @HiveField(0)
  double height; // cm

  @HiveField(1)
  double weight; // kg

  @HiveField(2)
  int age;

  @HiveField(3)
  String gender; // 'male' or 'female'

  UserProfile({
    required this.height,
    required this.weight,
    required this.age,
    required this.gender,
  });

  /// Mifflin-St Jeor 공식으로 BMR 계산
  double get bmr {
    if (gender == 'male') {
      return (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      return (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }
  }

  /// TDEE (좌식 기준 x1.2)
  double get tdee => bmr * 1.2;

  /// 하루 필요 칼로리
  double get dailyCalories => tdee;

  /// 탄수화물 (총 칼로리의 50%, 1g = 4kcal)
  double get dailyCarbs => (tdee * 0.50) / 4;

  /// 단백질 (총 칼로리의 25%, 1g = 4kcal)
  double get dailyProtein => (tdee * 0.25) / 4;

  /// 지방 (총 칼로리의 25%, 1g = 9kcal)
  double get dailyFat => (tdee * 0.25) / 9;
}
