import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/glucose_reading.dart';
import '../models/child.dart';
import '../repositories/child_repository.dart';
import '../repositories/firebase_child_repository.dart';
import '../repositories/glucose_repository.dart';
import '../repositories/firebase_glucose_repository.dart';
import '../widgets/app_text_field.dart';
import '../widgets/primary_button.dart';
import '../core/snackbar_helper.dart';

final childRepositoryProvider = Provider<ChildRepository>((ref) {
  return FirebaseChildRepository();
});

final glucoseRepositoryProvider = Provider<GlucoseRepository>((ref) {
  return FirebaseGlucoseRepository();
});

final childByIdProvider = FutureProvider.family<ChildModel, String>((ref, id) async {
  final repository = ref.watch(childRepositoryProvider);
  return repository.getChildById(id);
});

class AddReadingScreen extends ConsumerStatefulWidget {
  final String childId;

  const AddReadingScreen({
    super.key,
    required this.childId,
  });

  @override
  ConsumerState<AddReadingScreen> createState() => _AddReadingScreenState();
}

class _AddReadingScreenState extends ConsumerState<AddReadingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  final _noteController = TextEditingController();
  String _selectedContext = 'before_meal';
  bool _isLoading = false;

  @override
  void dispose() {
    _valueController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final childAsync = ref.read(childByIdProvider(widget.childId).future);
      final child = await childAsync;

      final value = double.parse(_valueController.text.trim());
      final measuredAt = DateTime.now();
      final isLow = value < child.glucoseMin;
      final isHigh = value > child.glucoseMax;

      final reading = GlucoseReading(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        childId: widget.childId,
        measuredAt: measuredAt,
        value: value,
        context: _selectedContext,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        isLow: isLow,
        isHigh: isHigh,
      );

      final repository = ref.read(glucoseRepositoryProvider);
      await repository.addReading(reading);

      if (mounted) {
        if (isLow) {
          _showAlert(
            context,
            'ערך סוכר נמוך!',
            'ערך סוכר נמוך! פעל לפי ההוראות: ${child.instructions}',
            Colors.red,
          );
        } else if (isHigh) {
          _showAlert(
            context,
            'ערך סוכר גבוה!',
            'ערך סוכר גבוה! פעל לפי ההוראות: ${child.instructions}',
            Colors.orange,
          );
        } else {
          showSuccessSnackBar(context, 'מדידה נשמרה בהצלחה');
        }
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

  void _showAlert(BuildContext context, String title, String message, Color color) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(title),
          content: Text(message),
          backgroundColor: color.withOpacity(0.1),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('אישור'),
            ),
          ],
        ),
      ),
    );
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
            'מדידת סוכר חדשה',
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
                color: const Color(0xFF4CAF50).withOpacity(0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.bloodtype_rounded,
                        color: const Color(0xFF4CAF50),
                        size: 28,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'מדידת סוכר',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'הזן את ערך הסוכר שנמדד',
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
                ),
              ),
              const SizedBox(height: 32),
              AppTextField(
                controller: _valueController,
                label: 'ערך סוכר (mg/dL)',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedContext,
                decoration: InputDecoration(
                  labelText: 'הקשר',
                  labelStyle: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'before_meal',
                    child: Text('לפני אוכל'),
                  ),
                  DropdownMenuItem(
                    value: 'after_meal',
                    child: Text('אחרי אוכל'),
                  ),
                  DropdownMenuItem(
                    value: 'other',
                    child: Text('אחר'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedContext = value);
                  }
                },
              ),
              const SizedBox(height: 20),
              AppTextField(
                controller: _noteController,
                label: 'הערה',
                maxLines: 3,
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

