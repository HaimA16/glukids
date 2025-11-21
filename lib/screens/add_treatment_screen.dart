import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/treatment.dart';
import '../repositories/treatment_repository.dart';
import '../repositories/firebase_treatment_repository.dart';
import '../widgets/app_text_field.dart';
import '../widgets/primary_button.dart';
import '../core/snackbar_helper.dart';

final treatmentRepositoryProvider = Provider<TreatmentRepository>((ref) {
  return FirebaseTreatmentRepository();
});

class AddTreatmentScreen extends ConsumerStatefulWidget {
  final String childId;
  final double? prefillUnits;
  final String? prefillNote;

  const AddTreatmentScreen({
    super.key,
    required this.childId,
    this.prefillUnits,
    this.prefillNote,
  });

  @override
  ConsumerState<AddTreatmentScreen> createState() => _AddTreatmentScreenState();
}

class _AddTreatmentScreenState extends ConsumerState<AddTreatmentScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _unitsController;
  late final TextEditingController _noteController;
  late String _selectedType;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _unitsController = TextEditingController(
      text: widget.prefillUnits?.toString() ?? '',
    );
    _noteController = TextEditingController(
      text: widget.prefillNote ?? '',
    );
    _selectedType = widget.prefillUnits != null ? 'insulin_injection' : 'insulin_injection';
  }

  @override
  void dispose() {
    _unitsController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    setState(() => _isLoading = true);

    try {
      final givenAt = DateTime.now();
      final units = _unitsController.text.trim().isEmpty
          ? null
          : double.tryParse(_unitsController.text.trim());

      final treatment = Treatment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        childId: widget.childId,
        givenAt: givenAt,
        type: _selectedType,
        units: units,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );

      final repository = ref.read(treatmentRepositoryProvider);
      await repository.addTreatment(treatment);

      if (mounted) {
        showSuccessSnackBar(context, 'הטיפול נשמר');
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
            'טיפול חדש',
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
                        Icons.medication_rounded,
                        color: const Color(0xFF2196F3),
                        size: 28,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'רישום טיפול',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'רשום טיפול או אינסולין שניתן',
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
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: 'סוג טיפול',
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
                    value: 'insulin_injection',
                    child: Text('זריקת אינסולין'),
                  ),
                  DropdownMenuItem(
                    value: 'pump_bolus',
                    child: Text('בולוס במשאבה'),
                  ),
                  DropdownMenuItem(
                    value: 'other',
                    child: Text('אחר'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedType = value);
                  }
                },
              ),
              const SizedBox(height: 20),
              AppTextField(
                controller: _unitsController,
                label: 'יחידות',
                keyboardType: TextInputType.number,
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

