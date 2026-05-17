import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/meal_record.dart';
import '../providers/app_provider.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _displayMonth;
  static final _dateFmt = DateFormat('yyyy-MM-dd');
  static const _weekLabels = ['일', '월', '화', '수', '목', '금', '토'];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayMonth = DateTime(now.year, now.month);
  }

  void _prevMonth() => setState(() {
        _displayMonth =
            DateTime(_displayMonth.year, _displayMonth.month - 1);
      });

  void _nextMonth() => setState(() {
        _displayMonth =
            DateTime(_displayMonth.year, _displayMonth.month + 1);
      });

  List<DateTime?> _buildDayCells() {
    final firstDay =
        DateTime(_displayMonth.year, _displayMonth.month, 1);
    final lastDay =
        DateTime(_displayMonth.year, _displayMonth.month + 1, 0);
    final blanks = firstDay.weekday == 7 ? 0 : firstDay.weekday;

    final cells = <DateTime?>[];
    for (int i = 0; i < blanks; i++) { cells.add(null); }
    for (int d = 1; d <= lastDay.day; d++) {
      cells.add(DateTime(_displayMonth.year, _displayMonth.month, d));
    }
    return cells;
  }

  void _showDayDetail(BuildContext context, AppProvider prov, DateTime date) {
    final dateLabel =
        '${date.month}월 ${date.day}일 (${_weekLabels[date.weekday % 7]})';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _DayDetailSheet(
        prov: prov,
        date: date,
        dateLabel: dateLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text('캘린더',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black87)),
      ),
      body: Consumer<AppProvider>(
        builder: (_, prov, __) {
          final cells = _buildDayCells();
          final recordDates = prov.allRecordDates;

          return Column(children: [
            // 월 헤더
            Container(
              color: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  onPressed: _prevMonth,
                ),
                Expanded(
                  child: Text(
                    '${_displayMonth.year}년 ${_displayMonth.month}월',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded),
                  onPressed: _nextMonth,
                ),
              ]),
            ),

            // 요일 헤더
            Container(
              color: Colors.white,
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: _weekLabels.map((w) {
                  final isSun = w == '일';
                  final isSat = w == '토';
                  return Expanded(
                    child: Text(
                      w,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSun
                            ? Colors.red[400]
                            : isSat
                                ? Colors.blue[400]
                                : Colors.grey[600],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const Divider(height: 1),

            // 날짜 그리드
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 0.85,
                ),
                itemCount: cells.length,
                itemBuilder: (_, i) {
                  final date = cells[i];
                  if (date == null) return const SizedBox.shrink();

                  final dateStr = _dateFmt.format(date);
                  final hasRecord = recordDates.contains(dateStr);
                  final isOver =
                      hasRecord && prov.isOverTargetForDate(date);
                  final isToday =
                      _dateFmt.format(DateTime.now()) == dateStr;

                  final dotColor =
                      isOver ? Colors.red : Colors.green;
                  final isSunday = date.weekday == 7;
                  final isSaturday = date.weekday == 6;

                  return GestureDetector(
                    onTap: hasRecord
                        ? () => _showDayDetail(context, prov, date)
                        : null,
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      decoration: isToday
                          ? BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Colors.green[400]!, width: 1.5),
                            )
                          : null,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${date.day}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isToday
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSunday
                                  ? Colors.red[400]
                                  : isSaturday
                                      ? Colors.blue[400]
                                      : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 3),
                          hasRecord
                              ? Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: dotColor,
                                    shape: BoxShape.circle,
                                  ),
                                )
                              : const SizedBox(height: 6),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // 범례
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _legend(Colors.green, '기준치 이내'),
                  const SizedBox(width: 20),
                  _legend(Colors.red, '기준치 초과'),
                ],
              ),
            ),
          ]);
        },
      ),
    );
  }

  Widget _legend(Color color, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 8,
              height: 8,
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      );
}

// ──────────────────────────────────────────────────────────────
//  날짜 상세 시트 — AppProvider 변경 시 자동 갱신
// ──────────────────────────────────────────────────────────────
class _DayDetailSheet extends StatefulWidget {
  final AppProvider prov;
  final DateTime date;
  final String dateLabel;

  const _DayDetailSheet({
    required this.prov,
    required this.date,
    required this.dateLabel,
  });

  @override
  State<_DayDetailSheet> createState() => _DayDetailSheetState();
}

class _DayDetailSheetState extends State<_DayDetailSheet> {
  @override
  void initState() {
    super.initState();
    widget.prov.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.prov.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  // ── 삭제 확인 다이얼로그 ──
  Future<void> _deleteRecord(MealRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('기록 삭제',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content:
            Text('"${record.foodName}" 기록을 삭제하시겠습니까?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('취소')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await widget.prov.deleteMealRecord(record);
    }
  }

  // ── 수정 시트 표시 ──
  void _editRecord(MealRecord record) {
    if (record.amount == null || record.unit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('양 정보가 없는 기록은 수정할 수 없습니다.')),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _EditAmountSheet(
        record: record,
        prov: widget.prov,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final records = widget.prov.recordsForDate(widget.date);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (_, scrollCtrl) => Column(
        children: [
          // 핸들 + 날짜 헤더
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Column(children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 14),
              Row(children: [
                const Icon(Icons.calendar_today_rounded,
                    size: 18, color: Colors.green),
                const SizedBox(width: 8),
                Text(widget.dateLabel,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('${records.length}개',
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey[500])),
              ]),
              const SizedBox(height: 8),
              const Divider(),
            ]),
          ),

          // 기록 목록
          Expanded(
            child: records.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.no_food_rounded,
                            size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text('이 날의 기록이 없습니다.',
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500])),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: scrollCtrl,
                    padding:
                        const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: records.length,
                    itemBuilder: (_, i) => _DayRecordTile(
                      record: records[i],
                      onDelete: () => _deleteRecord(records[i]),
                      onEdit: () => _editRecord(records[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
//  날짜별 기록 타일 (수정 / 삭제 버튼 포함)
// ──────────────────────────────────────────────────────────────
class _DayRecordTile extends StatelessWidget {
  final MealRecord record;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _DayRecordTile({
    required this.record,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final amountStr = (record.amount != null && record.unit != null)
        ? '${record.amount!.toInt()} ${record.unit}'
        : null;
    final canEdit = record.amount != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단: 음식명 + 양 뱃지 + 버튼
          Padding(
            padding:
                const EdgeInsets.fromLTRB(14, 10, 6, 4),
            child: Row(children: [
              Expanded(
                child: Text(record.foodName,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              if (amountStr != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Colors.green[200]!, width: 1),
                  ),
                  child: Text(amountStr,
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600)),
                ),
              ],
              // 수정 버튼
              IconButton(
                icon: Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color:
                      canEdit ? Colors.blue[400] : Colors.grey[300],
                ),
                tooltip: canEdit ? '수정' : '양 정보 없음',
                onPressed: canEdit ? onEdit : null,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.all(6),
              ),
              // 삭제 버튼
              IconButton(
                icon: Icon(Icons.delete_outline_rounded,
                    size: 18, color: Colors.red[300]),
                tooltip: '삭제',
                onPressed: onDelete,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.all(6),
              ),
            ]),
          ),

          // 하단: 영양 정보
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
            child: Row(children: [
              _macroChip(
                  '${record.calories.toStringAsFixed(0)} kcal',
                  Colors.orange),
              const SizedBox(width: 8),
              _macroChip(
                  '탄 ${record.carbs.toStringAsFixed(1)}g',
                  Colors.blue),
              const SizedBox(width: 8),
              _macroChip(
                  '단 ${record.protein.toStringAsFixed(1)}g',
                  Colors.purple),
              const SizedBox(width: 8),
              _macroChip(
                  '지 ${record.fat.toStringAsFixed(1)}g', Colors.red),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _macroChip(String text, Color color) => Text(
        text,
        style: TextStyle(
            fontSize: 11, color: color, fontWeight: FontWeight.w600),
      );
}

// ──────────────────────────────────────────────────────────────
//  양 수정 시트
// ──────────────────────────────────────────────────────────────
class _EditAmountSheet extends StatefulWidget {
  final MealRecord record;
  final AppProvider prov;

  const _EditAmountSheet({required this.record, required this.prov});

  @override
  State<_EditAmountSheet> createState() => _EditAmountSheetState();
}

class _EditAmountSheetState extends State<_EditAmountSheet> {
  late TextEditingController _ctrl;
  late double _newAmount;
  bool _saving = false;

  // 1단위당 영양값 (기존 amount 기준 역산)
  late final double _perUnitCal;
  late final double _perUnitCarbs;
  late final double _perUnitProtein;
  late final double _perUnitFat;

  double get _cal     => _perUnitCal     * _newAmount;
  double get _carbs   => _perUnitCarbs   * _newAmount;
  double get _protein => _perUnitProtein * _newAmount;
  double get _fat     => _perUnitFat     * _newAmount;

  @override
  void initState() {
    super.initState();
    final r = widget.record;
    _newAmount = r.amount!;
    _perUnitCal     = r.calories / r.amount!;
    _perUnitCarbs   = r.carbs    / r.amount!;
    _perUnitProtein = r.protein  / r.amount!;
    _perUnitFat     = r.fat      / r.amount!;
    _ctrl = TextEditingController(text: r.amount!.toInt().toString());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onAmountChanged(String v) {
    final parsed = double.tryParse(v);
    if (parsed != null && parsed > 0) {
      setState(() => _newAmount = parsed);
    }
  }

  Future<void> _save() async {
    if (_saving || _newAmount <= 0) return;
    setState(() => _saving = true);

    final old = widget.record;
    final updated = MealRecord(
      foodName:   old.foodName,
      calories:   _cal,
      carbs:      _carbs,
      protein:    _protein,
      fat:        _fat,
      imagePath:  old.imagePath,
      recordedAt: old.recordedAt,
      amount:     _newAmount,
      unit:       old.unit,
    );

    await widget.prov.updateMealRecord(old, updated);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final unit = widget.record.unit ?? '';

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

          // 제목
          Row(children: [
            const Icon(Icons.edit_outlined,
                color: Colors.blue, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.record.foodName,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ]),
          const SizedBox(height: 20),

          // 양 입력 필드
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
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 10),
                    isDense: true,
                  ),
                  onChanged: _onAmountChanged,
                  onSubmitted: _onAmountChanged,
                ),
              ),
              const SizedBox(width: 8),
              Text(unit,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600])),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),

          // 스케일된 영양 정보
          _row('칼로리', '${_cal.toStringAsFixed(0)} kcal',
              Colors.orange),
          _row('탄수화물', '${_carbs.toStringAsFixed(1)} g',
              Colors.blue),
          _row('단백질', '${_protein.toStringAsFixed(1)} g',
              Colors.purple),
          _row('지방', '${_fat.toStringAsFixed(1)} g', Colors.red),
          const SizedBox(height: 20),

          // 저장 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('저장하기',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, Color color) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          Container(
              width: 10,
              height: 10,
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle)),
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
