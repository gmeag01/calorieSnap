import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../data/food_database.dart';
import '../models/meal_record.dart';
import '../models/user_profile.dart';
import '../providers/app_provider.dart';
import '../services/food_analysis_service.dart';
import '../widgets/nutrition_progress_bar.dart';
import 'records_screen.dart';
import 'calendar_screen.dart';

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
  //  이미지 소스 선택 다이얼로그
  // ──────────────────────────────────────
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            const Text(
              '이미지 선택',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _imageSourceButton(
                    icon: Icons.camera_alt_rounded,
                    label: '카메라',
                    onTap: () {
                      Navigator.pop(ctx);
                      _takePhoto();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _imageSourceButton(
                    icon: Icons.image_rounded,
                    label: '갤러리',
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickFromGallery();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _imageSourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green[200]!, width: 1.5),
          ),
          child: Column(
            children: [
              Icon(icon, size: 32, color: Colors.green[600]),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
        ),
      );

  // ──────────────────────────────────────
  //  사진 촬영
  // ──────────────────────────────────────
  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1080,
      maxHeight: 1080,
    );
    if (photo == null) return;
    await _analyzePhoto(File(photo.path));
  }

  // ──────────────────────────────────────
  //  갤러리에서 사진 선택
  // ──────────────────────────────────────
  Future<void> _pickFromGallery() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1080,
      maxHeight: 1080,
    );
    if (photo == null) return;
    await _analyzePhoto(File(photo.path));
  }

  // ──────────────────────────────────────
  //  사진 분석 (저장은 양 조절 시트에서)
  // ──────────────────────────────────────
  Future<void> _analyzePhoto(File imageFile) async {
    setState(() => _analyzing = true);

    try {
      final result = await FoodAnalysisService.analyzeFood(imageFile);

      if (!mounted) return;

      if (!result.isFound) {
        _snack('등록되지 않은 음식입니다.');
        return;
      }

      final entry = kFoodDatabase[result.label];
      if (entry == null) {
        _snack('음식 정보를 찾을 수 없습니다.');
        return;
      }

      _showQuantitySheet(result, entry, imageFile);
    } catch (e) {
      if (!mounted) return;
      _snack('분석 중 오류가 발생했습니다.\n($e)');
    } finally {
      if (mounted) setState(() => _analyzing = false);
    }
  }

  // ──────────────────────────────────────
  //  양 조절 시트
  // ──────────────────────────────────────
  void _showQuantitySheet(
      FoodAnalysisResult result, FoodEntry entry, File imageFile) {
    final provider = context.read<AppProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => _QuantitySheet(
        result: result,
        entry: entry,
        imageFile: imageFile,
        provider: provider,
        onAdded: () {
          if (mounted) {
            _snack('${result.foodName} 기록이 추가되었습니다.');
          }
        },
      ),
    );
  }

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
                onTap: _analyzing ? null : _showImageSourceDialog,
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
                        color: Colors.green.withValues(alpha: 0.35),
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
              color: Colors.black.withValues(alpha: 0.04),
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
              final nav = Navigator.of(context);
              _closeSidebar();
              Future.delayed(
                const Duration(milliseconds: 300),
                () => nav.push(
                  MaterialPageRoute(builder: (_) => const RecordsScreen()),
                ),
              );
            },
          ),
          _sidebarTile(
            icon: Icons.calendar_month_rounded,
            label: '캘린더',
            subtitle: '날짜별 식사 기록 확인',
            onTap: () {
              final nav = Navigator.of(context);
              _closeSidebar();
              Future.delayed(
                const Duration(milliseconds: 300),
                () => nav.push(
                  MaterialPageRoute(builder: (_) => const CalendarScreen()),
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

// ──────────────────────────────────────────────────────────────
//  양 조절 시트 (StatefulWidget)
// ──────────────────────────────────────────────────────────────
class _QuantitySheet extends StatefulWidget {
  final FoodAnalysisResult result;
  final FoodEntry entry;
  final File imageFile;
  final AppProvider provider;
  final VoidCallback onAdded;

  const _QuantitySheet({
    required this.result,
    required this.entry,
    required this.imageFile,
    required this.provider,
    required this.onAdded,
  });

  @override
  State<_QuantitySheet> createState() => _QuantitySheetState();
}

class _QuantitySheetState extends State<_QuantitySheet> {
  late double _amount;
  late TextEditingController _ctrl;
  bool _saving = false;
  Key _rulerKey = UniqueKey();

  FoodEntry get _entry => widget.entry;
  FoodAnalysisResult get _result => widget.result;

  double get _scale => _amount / _entry.servingAmount;
  double get _cal     => _result.calories * _scale;
  double get _carbs   => _result.carbs    * _scale;
  double get _protein => _result.protein  * _scale;
  double get _fat     => _result.fat      * _scale;

  @override
  void initState() {
    super.initState();
    _amount = _entry.servingAmount;
    _ctrl = TextEditingController(text: _formatAmount(_amount));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _formatAmount(double v) =>
      _entry.isGramBased ? v.toInt().toString() : v.toInt().toString();

  void _onRulerChanged(double v) {
    setState(() {
      _amount = v;
      _ctrl.text = v.toInt().toString();
    });
  }

  void _onTextSubmitted(String v) {
    final parsed = double.tryParse(v);
    if (parsed == null) return;
    final clamped =
        parsed.clamp(_entry.minAmount, double.infinity).roundToDouble();
    setState(() {
      _amount = clamped;
      _ctrl.text = clamped.toInt().toString();
      _rulerKey = UniqueKey(); // 룰러를 새 값으로 재초기화
    });
  }

  Future<void> _addRecord() async {
    if (_saving) return;
    setState(() => _saving = true);

    final record = MealRecord(
      foodName:   _result.foodName,
      calories:   _cal,
      carbs:      _carbs,
      protein:    _protein,
      fat:        _fat,
      imagePath:  widget.imageFile.path,
      recordedAt: DateTime.now(),
      amount:     _amount,
      unit:       _entry.servingUnit,
    );

    await widget.provider.addMealRecord(record);
    if (!mounted) return;
    Navigator.pop(context);
    widget.onAdded();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 32 + viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 핸들
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),

          // 음식명
          Row(children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _result.foodName,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ]),
          const SizedBox(height: 20),

          // 양 표시 + 입력 필드
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              SizedBox(
                width: 96,
                child: TextField(
                  controller: _ctrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 36, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onSubmitted: _onTextSubmitted,
                  onEditingComplete: () => _onTextSubmitted(_ctrl.text),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                _entry.servingUnit,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // 무한 드럼 룰러
          _DrumRuler(
            key: _rulerKey,
            initialAmount: _amount,
            minAmount: _entry.minAmount,
            isGramBased: _entry.isGramBased,
            unit: _entry.servingUnit,
            onChanged: _onRulerChanged,
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),

          // 스케일된 영양 정보
          _nutritionRow('칼로리', '${_cal.toStringAsFixed(0)} kcal',
              Colors.orange),
          _nutritionRow('탄수화물', '${_carbs.toStringAsFixed(1)} g',
              Colors.blue),
          _nutritionRow('단백질', '${_protein.toStringAsFixed(1)} g',
              Colors.purple),
          _nutritionRow('지방', '${_fat.toStringAsFixed(1)} g',
              Colors.red),
          const SizedBox(height: 20),

          // 기록 추가 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _addRecord,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('기록에 추가',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _nutritionRow(String label, String value, Color color) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(fontSize: 13, color: Colors.grey[700])),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700)),
        ]),
      );
}

// ──────────────────────────────────────────────────────────────
//  무한 드럼 룰러 위젯
// ──────────────────────────────────────────────────────────────
class _DrumRuler extends StatefulWidget {
  final double initialAmount;
  final double minAmount;
  final bool isGramBased;
  final String unit;
  final ValueChanged<double> onChanged;

  const _DrumRuler({
    super.key,
    required this.initialAmount,
    required this.minAmount,
    required this.isGramBased,
    required this.unit,
    required this.onChanged,
  });

  @override
  State<_DrumRuler> createState() => _DrumRulerState();
}

class _DrumRulerState extends State<_DrumRuler>
    with SingleTickerProviderStateMixin {
  late double _pos; // pos / _ppu = 현재 수량 (소수 포함)
  late AnimationController _animCtrl;
  Animation<double>? _posAnim;
  int _lastNotified = -1;

  // g 기반: 1픽셀당 0.2g → 5픽셀에 1g (촘촘한 눈금 가시성 확보)
  // 조각 기반: 1픽셀당 1/40개 → 40픽셀에 1개
  double get _ppu => widget.isGramBased ? 5.0 : 40.0;
  double get _minPos => widget.minAmount * _ppu;

  double get _currentAmount =>
      (_pos / _ppu).clamp(widget.minAmount, double.infinity);
  int get _roundedAmount => _currentAmount.round();

  @override
  void initState() {
    super.initState();
    _pos = widget.initialAmount * _ppu;
    _lastNotified = widget.initialAmount.round();
    _animCtrl = AnimationController(vsync: this)
      ..addListener(_onAnimTick);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _onAnimTick() {
    setState(() {
      _pos = (_posAnim!.value).clamp(_minPos, double.infinity);
    });
    _maybeNotify();
  }

  void _maybeNotify() {
    final ra = _roundedAmount;
    if (ra != _lastNotified) {
      _lastNotified = ra;
      HapticFeedback.selectionClick();
      widget.onChanged(ra.toDouble());
    }
  }

  void _onDragStart(DragStartDetails _) => _animCtrl.stop();

  void _onDragUpdate(DragUpdateDetails d) {
    setState(() {
      _pos = (_pos + d.delta.dx).clamp(_minPos, double.infinity);
    });
    _maybeNotify();
  }

  void _onDragEnd(DragEndDetails d) {
    final vel = d.velocity.pixelsPerSecond.dx;
    // 관성: 속도에 비례한 종착점을 계산한 뒤 가장 가까운 정수로 스냅
    final projected = (_pos + vel * 0.15).clamp(_minPos, double.infinity);
    final snapped = (projected / _ppu).round() * _ppu;
    _animateTo(snapped,
        ms: vel.abs() > 300 ? 480 : 180,
        curve: vel.abs() > 300 ? Curves.decelerate : Curves.easeOut);
  }

  void _animateTo(double target, {required int ms, required Curve curve}) {
    _posAnim = Tween<double>(begin: _pos, end: target).animate(
        CurvedAnimation(parent: _animCtrl, curve: curve));
    _animCtrl.duration = Duration(milliseconds: ms);
    _animCtrl.reset();
    _animCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: ClipRect(
        child: SizedBox(
          height: 72,
          width: double.infinity,
          child: CustomPaint(
            painter: _RulerPainter(
              pos: _pos,
              ppu: _ppu,
              isGramBased: widget.isGramBased,
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
//  드럼 룰러 페인터 — 코사인 곡률로 회전하는 듯한 눈금 표현
// ──────────────────────────────────────────────────────────────
class _RulerPainter extends CustomPainter {
  final double pos;
  final double ppu;
  final bool isGramBased;

  const _RulerPainter({
    required this.pos,
    required this.ppu,
    required this.isGramBased,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final midY = size.height * 0.46;
    final currentAmt = pos / ppu;

    // 눈금 간격: g → 매 1g마다 (minor), 10g마다 (major)
    //           조각 → 매 1개마다 (major)
    final majorEvery = isGramBased ? 10 : 1;
    final visR = (centerX / ppu).ceil() + 2;
    final first = (currentAmt - visR).floor();
    final last = (currentAmt + visR).ceil();

    final tickPaint = Paint()..strokeCap = StrokeCap.round;

    for (int u = first; u <= last; u++) {
      if (u < 0) continue;
      final x = centerX + (u - currentAmt) * ppu;
      if (x < -4 || x > size.width + 4) continue;

      // 중앙으로부터의 거리 비율 (0=중앙, 1=끝)
      final t = ((x - centerX) / centerX).abs().clamp(0.0, 1.0);
      // 코사인 커브: 중앙 1.0, 끝 0.0 → 드럼이 회전하는 느낌
      final curve = math.cos(t * math.pi / 2);

      final isMajor = u % majorEvery == 0;
      final maxH = isMajor ? 19.0 : 9.0;
      final h = maxH * curve;
      final alpha = (curve * 0.85 + 0.15).clamp(0.0, 1.0);

      tickPaint
        ..color = (isMajor ? Colors.grey[700] : Colors.grey[400])!
            .withValues(alpha: alpha)
        ..strokeWidth = isMajor ? 2.0 : 1.2;

      canvas.drawLine(Offset(x, midY - h), Offset(x, midY + h), tickPaint);

      // 주요 눈금 숫자 레이블
      if (isMajor && curve > 0.35) {
        final tp = TextPainter(
          text: TextSpan(
            text: '$u',
            style: TextStyle(
              fontSize: 10.5 * curve,
              color: Colors.grey[600]!.withValues(alpha: alpha),
              fontWeight: FontWeight.w500,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x - tp.width / 2, midY + h + 3));
      }
    }

    // 중앙 포인터 (녹색 막대)
    final ptrRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: Offset(centerX, midY), width: 5.0, height: 48.0),
      const Radius.circular(2),
    );
    canvas.drawRRect(ptrRect, Paint()..color = Colors.green[600]!);
  }

  @override
  bool shouldRepaint(_RulerPainter old) => old.pos != pos;
}
