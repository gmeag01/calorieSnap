import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'models/user_profile.dart';
import 'models/meal_record.dart';
import 'providers/app_provider.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive 초기화 (로컬 DB)
  await Hive.initFlutter();
  Hive.registerAdapter(UserProfileAdapter());
  Hive.registerAdapter(MealRecordAdapter());
  await Hive.openBox<UserProfile>('userProfile');
  await Hive.openBox<MealRecord>('mealRecords');

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const FoodAnalyzerApp(),
    ),
  );
}

class FoodAnalyzerApp extends StatelessWidget {
  const FoodAnalyzerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '영양 분석기',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        fontFamily: 'Pretendard', // pubspec에 폰트 추가 시 적용
        useMaterial3: true,
      ),
      home: const _AppRouter(),
    );
  }
}

/// 최초 실행 여부에 따라 온보딩 또는 홈 화면으로 라우팅
class _AppRouter extends StatelessWidget {
  const _AppRouter();

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<UserProfile>('userProfile');
    return box.isEmpty ? const OnboardingScreen() : const HomeScreen();
  }
}
