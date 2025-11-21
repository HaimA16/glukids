import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/child.dart';
import '../services/auth_service.dart';
import '../repositories/child_repository.dart';
import '../repositories/firebase_child_repository.dart';
import '../widgets/app_text_field.dart';
import '../widgets/primary_button.dart';
import '../core/snackbar_helper.dart';

final childRepositoryForEditProvider = Provider<ChildRepository>((ref) {
  return FirebaseChildRepository();
});

final childForEditProvider = FutureProvider.family<ChildModel, String>((ref, childId) async {
  final repository = ref.watch(childRepositoryForEditProvider);
  return repository.getChildById(childId);
});

class EditChildScreen extends ConsumerStatefulWidget {
  final String childId;

  const EditChildScreen({
    super.key,
    required this.childId,
  });

  @override
  ConsumerState<EditChildScreen> createState() => _EditChildScreenState();
}

class _EditChildScreenState extends ConsumerState<EditChildScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _gradeController;
  late final TextEditingController _parentPhoneController;
  late final TextEditingController _glucoseMinController;
  late final TextEditingController _glucoseMaxController;
  late final TextEditingController _instructionsController;
  late final TextEditingController _insulinToCarbRatioController;
  late final TextEditingController _correctionFactorController;
  late final TextEditingController _targetMinController;
  late final TextEditingController _targetMaxController;
  
  bool _isLoading = false;
  bool _showInsulinParams = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _gradeController = TextEditingController();
    _parentPhoneController = TextEditingController();
    _glucoseMinController = TextEditingController();
    _glucoseMaxController = TextEditingController();
    _instructionsController = TextEditingController();
    _insulinToCarbRatioController = TextEditingController();
    _correctionFactorController = TextEditingController();
    _targetMinController = TextEditingController();
    _targetMaxController = TextEditingController();
  }

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

  void _initializeControllers(ChildModel child) {
    _nameController.text = child.name;
    _gradeController.text = child.grade;
    _parentPhoneController.text = child.parentPhone;
    _glucoseMinController.text = child.glucoseMin.toString();
    _glucoseMaxController.text = child.glucoseMax.toString();
    _instructionsController.text = child.instructions;
    
    if (child.insulinToCarbRatio != null) {
      _insulinToCarbRatioController.text = child.insulinToCarbRatio.toString();
      _showInsulinParams = true;
    }
    if (child.correctionFactor != null) {
      _correctionFactorController.text = child.correctionFactor.toString();
    }
    if (child.targetMin != null) {
      _targetMinController.text = child.targetMin.toString();
    }
    if (child.targetMax != null) {
      _targetMaxController.text = child.targetMax.toString();
    }
  }

  Future<void> _handleSubmit(ChildModel originalChild) async {
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

      final updatedChild = originalChild.copyWith(
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

      final repository = ref.read(childRepositoryForEditProvider);
      await repository.updateChild(updatedChild);

      if (mounted) {
        showSuccessSnackBar(context, 'פרטי התלמיד עודכנו בהצלחה');
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
    final childAsync = ref.watch(childForEditProvider(widget.childId));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: const Text(
            'עריכת פרטי תלמיד',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          centerTitle: true,
        ),
        body: childAsync.when(
          data: (child) {
            // Initialize controllers once when data is loaded
            if (_nameController.text.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _initializeControllers(child);
                }
              });
            }

            return Form(
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
                            Icons.edit_rounded,
                            color: const Color(0xFF2196F3),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'ערוך את פרטי התלמיד',
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
                    text: 'שמירת שינויים',
                    onPressed: () => _handleSubmit(child),
                    loading: _isLoading,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
            ),
          ),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'שגיאה: ${error.toString()}',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

