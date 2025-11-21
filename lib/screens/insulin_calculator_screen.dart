import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/child.dart';
import '../repositories/child_repository.dart';
import '../repositories/firebase_child_repository.dart';
import '../services/insulin_calculator_service.dart';
import '../widgets/app_text_field.dart';
import '../widgets/primary_button.dart';
import '../core/snackbar_helper.dart';

final childRepositoryProvider = Provider<ChildRepository>((ref) {
  return FirebaseChildRepository();
});

final childByIdProvider = FutureProvider.family<ChildModel, String>((ref, id) async {
  final repository = ref.watch(childRepositoryProvider);
  return repository.getChildById(id);
});

class InsulinCalculatorScreen extends ConsumerStatefulWidget {
  final String childId;

  const InsulinCalculatorScreen({
    super.key,
    required this.childId,
  });

  @override
  ConsumerState<InsulinCalculatorScreen> createState() => _InsulinCalculatorScreenState();
}

class _InsulinCalculatorScreenState extends ConsumerState<InsulinCalculatorScreen> {
  final _glucoseController = TextEditingController();
  final _carbsController = TextEditingController();
  final _noteController = TextEditingController();
  InsulinCalculationResult? _calculationResult;

  @override
  void dispose() {
    _glucoseController.dispose();
    _carbsController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _calculate() {
    final glucose = double.tryParse(_glucoseController.text.trim());
    final carbs = double.tryParse(_carbsController.text.trim());

    if (glucose == null || carbs == null) {
      showErrorSnackBar(context, 'נא למלא את כל השדות');
      return;
    }

    final childAsync = ref.read(childByIdProvider(widget.childId).future);
    childAsync.then((child) {
      if (child.insulinToCarbRatio == null ||
          child.correctionFactor == null ||
          child.targetMin == null ||
          child.targetMax == null) {
        showErrorSnackBar(
          context,
          'יש להגדיר את פרמטרי האינסולין לילד בהגדרות',
        );
        return;
      }

      final result = InsulinCalculatorService.calculateBolus(
        currentGlucose: glucose,
        carbs: carbs,
        insulinToCarbRatio: child.insulinToCarbRatio!,
        correctionFactor: child.correctionFactor!,
        targetMin: child.targetMin!,
        targetMax: child.targetMax!,
      );

      setState(() {
        _calculationResult = result;
      });
    }).catchError((error) {
      showErrorSnackBar(context, 'שגיאה: ${error.toString()}');
    });
  }

  void _saveAsTreatment(InsulinCalculationResult result, ChildModel child) {
    Navigator.of(context).pushNamed(
      '/add-treatment',
      arguments: {
        'childId': widget.childId,
        'prefillUnits': result.roundedBolus,
        'note': 'חושב במחשבון: ${result.explanation}',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final childAsync = ref.watch(childByIdProvider(widget.childId));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: const Text(
            'מחשבון אינסולין',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          centerTitle: true,
        ),
        body: childAsync.when(
          data: (child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Disclaimer
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange.shade700,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'חשוב: האפליקציה אינה תחליף להנחיות הרפואיות. יש לוודא כל מינון עם הצוות הרפואי.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.orange.shade900,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Child info card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2196F3).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.child_care_rounded,
                                  size: 24,
                                  color: Color(0xFF2196F3),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      child.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1A1A1A),
                                      ),
                                    ),
                                    Text(
                                      'כיתה ${child.grade}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          _buildParameterRow(
                            'יחס אינסולין-פחמימות',
                            child.insulinToCarbRatio != null
                                ? '${child.insulinToCarbRatio} יחידות ל-10g'
                                : 'לא הוגדר',
                            child.insulinToCarbRatio != null,
                          ),
                          const SizedBox(height: 12),
                          _buildParameterRow(
                            'גורם תיקון',
                            child.correctionFactor != null
                                ? '1 יחידה מורידה ${child.correctionFactor} mg/dL'
                                : 'לא הוגדר',
                            child.correctionFactor != null,
                          ),
                          const SizedBox(height: 12),
                          _buildParameterRow(
                            'טווח יעד',
                            child.targetMin != null && child.targetMax != null
                                ? '${child.targetMin} - ${child.targetMax} mg/dL'
                                : 'לא הוגדר',
                            child.targetMin != null && child.targetMax != null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Input form
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'הזן פרטים לחישוב',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 20),
                          AppTextField(
                            controller: _glucoseController,
                            label: 'ערך סוכר נוכחי (mg/dL)',
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            controller: _carbsController,
                            label: 'פחמימות מתוכננות (גרמים)',
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 20),
                          PrimaryButton(
                            text: 'חשב מינון',
                            onPressed: () {
                              if (child.insulinToCarbRatio == null ||
                                  child.correctionFactor == null ||
                                  child.targetMin == null ||
                                  child.targetMax == null) {
                                showErrorSnackBar(
                                  context,
                                  'יש להגדיר את פרמטרי האינסולין לילד בהגדרות',
                                );
                                return;
                              }
                              _calculate();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Result card
                  if (_calculationResult != null) ...[
                    const SizedBox(height: 24),
                    Card(
                      elevation: 2,
                      color: const Color(0xFF4CAF50).withOpacity(0.05),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: const Color(0xFF4CAF50).withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.calculate_rounded,
                                  color: const Color(0xFF4CAF50),
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'תוצאות החישוב',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '${_calculationResult!.roundedBolus} יחידות',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4CAF50),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'מינון מומלץ (חישוב)',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF1A1A1A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _calculationResult!.explanation,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade800,
                                  height: 1.6,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            PrimaryButton(
                              text: 'שמור כמנה',
                              onPressed: () => _saveAsTreatment(_calculationResult!, child),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
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

  Widget _buildParameterRow(String label, String value, bool isConfigured) {
    return Row(
      children: [
        Icon(
          isConfigured ? Icons.check_circle_rounded : Icons.warning_rounded,
          size: 20,
          color: isConfigured ? Colors.green : Colors.orange,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  color: isConfigured ? const Color(0xFF1A1A1A) : Colors.orange.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

