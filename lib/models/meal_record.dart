import 'package:hive/hive.dart';

part 'meal_record.g.dart';

@HiveType(typeId: 1)
class MealRecord {
  @HiveField(0)
  String foodName;

  @HiveField(1)
  double calories;

  @HiveField(2)
  double carbs;

  @HiveField(3)
  double protein;

  @HiveField(4)
  double fat;

  @HiveField(5)
  String imagePath;

  @HiveField(6)
  DateTime recordedAt;

  MealRecord({
    required this.foodName,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.imagePath,
    required this.recordedAt,
  });
}
