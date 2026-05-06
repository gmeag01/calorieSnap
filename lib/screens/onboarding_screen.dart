import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../providers/app_provider.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  String _gender = 'male';
  bool _loading = false;

  @override
  void dispose() {
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final profile = UserProfile(
      height: double.parse(_heightCtrl.text),
      weight: double.parse(_weightCtrl.text),
      age: int.parse(_ageCtrl.text),
      gender: _gender,
    );

    await context.read<AppProvider>().saveProfile(profile);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF4),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더
                const Text('안녕하세요! 👋',
                    style:
                        TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  '맞춤 영양 관리를 위해\n신체 정보를 입력해주세요.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600],
                      height: 1.5),
                ),
                const SizedBox(height: 10),
                // Mifflin-St Jeor 설명
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.green[700], size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Mifflin-St Jeor 공식으로 일일 필요 영양소를 계산합니다.',
                          style: TextStyle(
                              fontSize: 12, color: Colors.green[800]),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                _label('키 (cm)'),
                _field(_heightCtrl, '예: 170', decimal: true,
                    validator: _numValidator),
                const SizedBox(height: 16),

                _label('몸무게 (kg)'),
                _field(_weightCtrl, '예: 65', decimal: true,
                    validator: _numValidator),
                const SizedBox(height: 16),

                _label('나이'),
                _field(_ageCtrl, '예: 25', decimal: false,
                    validator: _intValidator),
                const SizedBox(height: 16),

                _label('성별'),
                const SizedBox(height: 8),
                Row(children: [
                  _genderBtn('남성', 'male'),
                  const SizedBox(width: 12),
                  _genderBtn('여성', 'female'),
                ]),

                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('시작하기',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600)),
      );

  Widget _field(
    TextEditingController ctrl,
    String hint, {
    required bool decimal,
    required String? Function(String?) validator,
  }) =>
      TextFormField(
        controller: ctrl,
        keyboardType: decimal
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.number,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.green[400]!, width: 2),
          ),
        ),
      );

  Widget _genderBtn(String label, String value) {
    final selected = _gender == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _gender = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? Colors.green[600] : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? Colors.green[600]! : Colors.grey[300]!,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.grey[700],
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  String? _numValidator(String? v) {
    if (v == null || v.isEmpty) return '값을 입력해주세요';
    if (double.tryParse(v) == null) return '올바른 숫자를 입력해주세요';
    if (double.parse(v) <= 0) return '0보다 큰 값을 입력해주세요';
    return null;
  }

  String? _intValidator(String? v) {
    if (v == null || v.isEmpty) return '값을 입력해주세요';
    if (int.tryParse(v) == null) return '정수를 입력해주세요';
    if (int.parse(v) <= 0) return '0보다 큰 값을 입력해주세요';
    return null;
  }
}
