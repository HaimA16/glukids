import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/child.dart';
import '../services/auth_service.dart';
import '../repositories/child_repository.dart';
import '../repositories/firebase_child_repository.dart';
import '../widgets/app_text_field.dart';
import '../widgets/primary_button.dart';
import '../core/snackbar_helper.dart';

final childRepositoryProvider = Provider<ChildRepository>((ref) {
  return FirebaseChildRepository();
});

class AddChildScreen extends ConsumerStatefulWidget {
  const AddChildScreen({super.key});

  @override
  ConsumerState<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends ConsumerState<AddChildScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _gradeController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  final _glucoseMinController = TextEditingController(text: '80');
  final _glucoseMaxController = TextEditingController(text: '180');
  final _instructionsController = TextEditingController();
  
  // Insulin calculator parameters (optional)
  final _insulinToCarbRatioController = TextEditingController();
  final _correctionFactorController = TextEditingController();
  final _targetMinController = TextEditingController();
  final _targetMaxController = TextEditingController();
  
  bool _isLoading = false;
  bool _showInsulinParams = false;

  @override
  void dispose() {
    _nameController.dispose();
    _gradeController.dispose();
    _parentPhoneController.dispose();
    _glucoseMinController.dispose();
    _glucoseMaxController.dispose();
    _instructionsController.dispose();
    _insulinToCarbRatioController.dispose();
    _correctionFactorController.dispose();
    _targetMinController.dispose();
    _targetMaxController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authService = ref.read(authServiceProvider);
    final currentUser = authService.currentUser;
    if (currentUser == null) {
      showErrorSnackBar(context, 'יש להתחבר תחילה');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final glucoseMin = double.parse(_glucoseMinController.text.trim());
      final glucoseMax = double.parse(_glucoseMaxController.text.trim());

      if (glucoseMin >= glucoseMax) {
        throw Exception('הטווח המינימלי חייב להיות קטן מהמקסימלי');
      }

      final child = ChildModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        assistantUid: currentUser.uid,
        name: _nameController.text.trim(),
        grade: _gradeController.text.trim(),
        parentPhone: _parentPhoneController.text.trim(),
        glucoseMin: glucoseMin,
        glucoseMax: glucoseMax,
        instructions: _instructionsController.text.trim(),
        insulinToCarbRatio: _insulinToCarbRatioController.text.trim().isEmpty
            ? null
            : double.tryParse(_insulinToCarbRatioController.text.trim()),
        correctionFactor: _correctionFactorController.text.trim().isEmpty
            ? null
            : double.tryParse(_correctionFactorController.text.trim()),
        targetMin: _targetMinController.text.trim().isEmpty
            ? null
            : double.tryParse(_targetMinController.text.trim()),
        targetMax: _targetMaxController.text.trim().isEmpty
            ? null
            : double.tryParse(_targetMaxController.text.trim()),
      );

      final repository = ref.read(childRepositoryProvider);
      await repository.addChild(child);

      if (mounted) {
        showSuccessSnackBar(context, 'הילד נשמר בהצלחה');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, 'שגיאה: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: const Text(
            'הוספת ילד סוכרתי',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          centerTitle: true,
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              const SizedBox(height: 20),
              Card(
                elevation: 0,
                color: const Color(0xFF2196F3).withOpacity(0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: const Color(0xFF2196F3),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'מלא את כל הפרטים על הילד',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              AppTextField(
                controller: _nameController,
                label: 'שם הילד',
              ),
              const SizedBox(height: 20),
              AppTextField(
                controller: _gradeController,
                label: 'כיתה',
              ),
              const SizedBox(height: 20),
              AppTextField(
                controller: _parentPhoneController,
                label: 'טלפון הורה',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              AppTextField(
                controller: _glucoseMinController,
                label: 'טווח מינימלי',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              AppTextField(
                controller: _glucoseMaxController,
                label: 'טווח מקסימלי',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              AppTextField(
                controller: _instructionsController,
                label: 'הוראות לטיפול',
                maxLines: 5,
              ),
              const SizedBox(height: 32),
              
              // Insulin parameters section (optional)
              Card(
                elevation: 0,
                color: Colors.grey.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          _showInsulinParams = !_showInsulinParams;
                        });
                      },
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calculate_rounded,
                              color: const Color(0xFF2196F3),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'פרמטרי מחשבון אינסולין (אופציונלי)',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                            ),
                            Icon(
                              _showInsulinParams
                                  ? Icons.expand_less_rounded
                                  : Icons.expand_more_rounded,
                              color: Colors.grey.shade600,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_showInsulinParams) ...[
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'הגדרות אלו נדרשות לשימוש במחשבון אינסולין. ניתן להוסיף אותן מאוחר יותר.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 20),
                            AppTextField(
                              controller: _insulinToCarbRatioController,
                              label: 'יחס אינסולין-פחמימות (יחידות ל-10g)',
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: _correctionFactorController,
                              label: 'גורם תיקון (mg/dL ליחידה)',
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: _targetMinController,
                              label: 'טווח יעד מינימלי (mg/dL)',
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: _targetMaxController,
                              label: 'טווח יעד מקסימלי (mg/dL)',
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'שמירה',
                onPressed: _handleSubmit,
                loading: _isLoading,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

