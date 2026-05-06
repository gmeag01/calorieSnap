import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/meal_record.dart';
import '../models/user_profile.dart';
import '../providers/app_provider.dart';
import '../services/food_analysis_service.dart';
import '../widgets/nutrition_progress_bar.dart';
import 'records_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool _analyzing = false;
  bool _sidebarOpen = false;
  final _picker = ImagePicker();

  late final AnimationController _sidebarAnim;
  late final Animation<double> _sidebarSlide;

  @override
  void initState() {
    super.initState();
    _sidebarAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _sidebarSlide = CurvedAnimation(
      parent: _sidebarAnim,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _sidebarAnim.dispose();
    super.dispose();
  }

  void _openSidebar() {
    setState(() => _sidebarOpen = true);
    _sidebarAnim.forward();
  }

  void _closeSidebar() {
    _sidebarAnim.reverse().then((_) {
      if (mounted) setState(() => _sidebarOpen = false);
    });
  }

  // ──────────────────────────────────────
  //  사진 촬영 & 분석
  // ──────────────────────────────────────
  Future<void> _takePhoto() async {
    final XFile? photo =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (photo == null) return;

    setState(() => _analyzing = true);

    try {
      final result =
          await FoodAnalysisService.analyzeFood(File(photo.path));

      if (!result.isFound) {
        _snack('등록되지 않은 음식입니다.');
        return;
      }

      final record = MealRecord(
        foodName: result.foodName,
        calories: result.calories,
        carbs: result.carbs,
        protein: result.protein,
        fat: result.fat,
        imagePath: photo.path,
        recordedAt: DateTime.now(),
      );

      if (!mounted) return;
      await context.read<AppProvider>().addMealRecord(record);
      _showResultSheet(result);
    } catch (e) {
      _snack('분석 중 오류가 발생했습니다.\n($e)');
    } finally {
      if (mounted) setState(() => _analyzing = false);
    }
  }

  void _showResultSheet(FoodAnalysisResult result) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Row(children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 24),
              const SizedBox(width: 8),
              Text(result.foodName,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 16),
            _resultRow('칼로리', '${result.calories.toStringAsFixed(0)} kcal',
                Colors.orange),
            _resultRow('탄수화물', '${result.carbs.toStringAsFixed(1)} g',
                Colors.blue),
            _resultRow('단백질', '${result.protein.toStringAsFixed(1)} g',
                Colors.purple),
            _resultRow(
                '지방', '${result.fat.toStringAsFixed(1)} g', Colors.red),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child:
                    const Text('확인', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultRow(String label, String value, Color color) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
                width: 12,
                height: 12,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 10),
            Text(label,
                style: TextStyle(fontSize: 14, color: Colors.grey[700])),
            const Spacer(),
            Text(value,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700)),
          ],
        ),
      );

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ──────────────────────────────────────
  //  신체 정보 수정 다이얼로그
  // ──────────────────────────────────────
  void _showBodyInfoDialog() {
    final provider = context.read<AppProvider>();
    final p = provider.userProfile;

    final heightCtrl =
        TextEditingController(text: p?.height.toStringAsFixed(1) ?? '');
    final weightCtrl =
        TextEditingController(text: p?.weight.toStringAsFixed(1) ?? '');
    final ageCtrl =
        TextEditingController(text: p?.age.toString() ?? '');
    String gender = p?.gender ?? 'male';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('신체 정보 수정',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _dlgField(heightCtrl, '키 (cm)', decimal: true),
              const SizedBox(height: 10),
              _dlgField(weightCtrl, '몸무게 (kg)', decimal: true),
              const SizedBox(height: 10),
              _dlgField(ageCtrl, '나이', decimal: false),
              const SizedBox(height: 14),
              Row(children: [
                const Text('성별',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: 16),
                _dlgGenderBtn(
                    '남성', 'male', gender,
                    () => setDlg(() => gender = 'male')),
                const SizedBox(width: 8),
                _dlgGenderBtn(
                    '여성', 'female', gender,
                    () => setDlg(() => gender = 'female')),
              ]),
            ]),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('취소')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white),
              onPressed: () async {
                final newProfile = UserProfile(
                  height: double.tryParse(heightCtrl.text) ?? p!.height,
                  weight: double.tryParse(weightCtrl.text) ?? p!.weight,
                  age: int.tryParse(ageCtrl.text) ?? p!.age,
                  gender: gender,
                );
                await provider.saveProfile(newProfile);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dlgField(TextEditingController ctrl, String label,
          {required bool decimal}) =>
      TextField(
        controller: ctrl,
        keyboardType: decimal
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      );

  Widget _dlgGenderBtn(
          String label, String value, String current, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: current == value ? Colors.green[600] : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(label,
              style: TextStyle(
                color:
                    current == value ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.w600,
              )),
        ),
      );

  // ──────────────────────────────────────
  //  빌드
  // ──────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
        backgroundColor: const Color(0xFFF4FAF4),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text('오늘의 영양',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black87)),
          actions: [
            IconButton(
              icon:
                  const Icon(Icons.menu_rounded, color: Colors.black87),
              onPressed: _openSidebar,
            ),
          ],
        ),
        body: Column(children: [
          // 영양소 프로그레스 바 영역
          Expanded(
            child: Consumer<AppProvider>(
              builder: (_, prov, __) {
                final profile = prov.userProfile;
                if (profile == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Column(children: [
                    // 날짜 및 요약
                    _dateHeader(prov),
                    const SizedBox(height: 16),
                    NutritionProgressBar(
                      label: '칼로리',
                      current: prov.totalCalories,
                      target: profile.dailyCalories,
                      unit: 'kcal',
                    ),
                    const SizedBox(height: 12),
                    NutritionProgressBar(
                      label: '탄수화물',
                      current: prov.totalCarbs,
                      target: profile.dailyCarbs,
                      unit: 'g',
                    ),
                    const SizedBox(height: 12),
                    NutritionProgressBar(
                      label: '단백질',
                      current: prov.totalProtein,
                      target: profile.dailyProtein,
                      unit: 'g',
                    ),
                    const SizedBox(height: 12),
                    NutritionProgressBar(
                      label: '지방',
                      current: prov.totalFat,
                      target: profile.dailyFat,
                      unit: 'g',
                    ),
                  ]),
                );
              },
            ),
          ),

          // 카메라 버튼
          Padding(
            padding: const EdgeInsets.only(bottom: 48, top: 8),
            child: Column(children: [
              Text('사진을 찍어 음식을 분석하세요',
                  style:
                      TextStyle(fontSize: 13, color: Colors.grey[500])),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _analyzing ? null : _takePhoto,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: _analyzing
                        ? Colors.grey[400]
                        : Colors.green[600],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.35),
                        blurRadius: 22,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: _analyzing
                      ? const Padding(
                          padding: EdgeInsets.all(22),
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 3),
                        )
                      : const Icon(Icons.camera_alt_rounded,
                          color: Colors.white, size: 34),
                ),
              ),
            ]),
          ),
        ]),
      ),

      // ── 사이드바 오버레이 ──
      if (_sidebarOpen)
        FadeTransition(
          opacity: _sidebarSlide,
          child: GestureDetector(
            onTap: _closeSidebar,
            child: Container(color: Colors.black45),
          ),
        ),
      if (_sidebarOpen)
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: SlideTransition(
            position: Tween<Offset>(
                    begin: const Offset(1, 0), end: Offset.zero)
                .animate(_sidebarSlide),
            child: _buildSidebar(),
          ),
        ),
    ]);
  }

  Widget _dateHeader(AppProvider prov) {
    final now = DateTime.now();
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final dayStr =
        '${now.month}월 ${now.day}일 (${weekdays[now.weekday - 1]})';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Row(children: [
        const Icon(Icons.calendar_today_rounded,
            size: 18, color: Colors.green),
        const SizedBox(width: 8),
        Text(dayStr,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14)),
        const Spacer(),
        Text('${prov.todayRecords.length}끼 기록됨',
            style: TextStyle(fontSize: 12, color: Colors.grey[500])),
      ]),
    );
  }

  Widget _buildSidebar() {
    return Material(
      child: Container(
        width: 270,
        color: Colors.white,
        child: SafeArea(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Row(children: [
              const Text('설정',
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _closeSidebar),
            ]),
          ),
          const Divider(height: 1),
          const SizedBox(height: 8),
          _sidebarTile(
            icon: Icons.person_outline_rounded,
            label: '신체 정보 수정',
            subtitle: 'Mifflin-St Jeor 재계산',
            onTap: () {
              _closeSidebar();
              Future.delayed(
                  const Duration(milliseconds: 300),
                  _showBodyInfoDialog);
            },
          ),
          _sidebarTile(
            icon: Icons.history_rounded,
            label: '오늘의 기록',
            subtitle: '분석한 음식 목록 보기',
            onTap: () {
              _closeSidebar();
              Future.delayed(
                const Duration(milliseconds: 300),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const RecordsScreen()),
                ),
              );
            },
          ),
        ]),
      ),
    ),
  );
  }

  Widget _sidebarTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) =>
      ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.green[700], size: 22),
        ),
        title: Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 15)),
        subtitle:
            Text(subtitle, style: TextStyle(color: Colors.grey[500])),
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      );
}
