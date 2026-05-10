import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/meal_record.dart';
import '../providers/app_provider.dart';

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          '오늘의 기록',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
      body: Consumer<AppProvider>(
        builder: (ctx, prov, _) {
          final records = prov.todayRecords;

          if (records.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.no_food_rounded, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    '아직 기록이 없습니다.',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '카메라 버튼을 눌러 음식을 분석해보세요!',
                    style:
                        TextStyle(fontSize: 13, color: Colors.grey[400]),
                  ),
                ],
              ),
            );
          }

          // 총합 요약 헤더 + 목록
          return Column(children: [
            _SummaryCard(prov: prov),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: records.length,
                itemBuilder: (ctx, i) => _MealCard(
                  record: records[i], 
                  index: i,
                  onDelete: () => prov.deleteMealRecord(records[i]),
                ),
              ),
            ),
          ]);
        },
      ),
    );
  }
}

// ──────────────────────────────────────────
//  오늘 합계 요약 카드
// ──────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final AppProvider prov;
  const _SummaryCard({required this.prov});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[600],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _stat('칼로리',
              '${prov.totalCalories.toStringAsFixed(0)} kcal'),
          _stat('탄수화물',
              '${prov.totalCarbs.toStringAsFixed(1)} g'),
          _stat('단백질',
              '${prov.totalProtein.toStringAsFixed(1)} g'),
          _stat('지방', '${prov.totalFat.toStringAsFixed(1)} g'),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) => Column(children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13)),
      ]);
}

// ──────────────────────────────────────────
//  개별 식사 카드
// ──────────────────────────────────────────
class _MealCard extends StatelessWidget {
  final MealRecord record;
  final int index;
  final VoidCallback onDelete;
  const _MealCard({
    required this.record, 
    required this.index,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      // recordedAt + foodName 기반 stable key — 인덱스 기반 key는
      // 삭제 후 리스트가 shift되면 엉뚱한 아이템에 애니메이션 적용됨
      key: Key('${record.recordedAt.millisecondsSinceEpoch}_${record.foodName}'),
      direction: DismissDirection.endToStart,
      resizeDuration: const Duration(milliseconds: 200),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_forever_rounded,
            color: Colors.white, size: 28),
      ),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(children: [
          // 음식 이미지
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16)),
            child: SizedBox(
              width: 88,
              height: 88,
              child: _buildImage(),
            ),
          ),

          // 정보
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(record.foodName,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(
                      '${record.calories.toStringAsFixed(0)} kcal',
                      style: TextStyle(
                          color: Colors.orange[600],
                          fontWeight: FontWeight.w700,
                          fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '탄 ${record.carbs.toStringAsFixed(1)}g  '
                      '단 ${record.protein.toStringAsFixed(1)}g  '
                      '지 ${record.fat.toStringAsFixed(1)}g',
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey[500]),
                    ),
                  ]),
            ),
          ),

          // 삭제 버튼
          IconButton(
            icon: Icon(Icons.delete_outline_rounded,
                color: Colors.grey[400], size: 22),
            onPressed: () async {
              if (await _confirmDelete(context) == true) {
                onDelete();
              }
            },
          ),
        ]),
      ),
    );
  }

  Widget _buildImage() {
    final file = File(record.imagePath);
    if (file.existsSync()) {
      return Image.file(file, fit: BoxFit.cover);
    }
    return Container(
      color: Colors.grey[100],
      child: Icon(Icons.fastfood_rounded,
          color: Colors.grey[400], size: 36),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text('기록 삭제',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text(
              '"${record.foodName}" 기록을 삭제하시겠습니까?\n프로그레스 바 수치도 함께 조정됩니다.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('취소')),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('삭제',
                  style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
}
