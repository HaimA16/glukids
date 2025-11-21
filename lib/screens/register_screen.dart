import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/app_text_field.dart';
import '../widgets/primary_button.dart';
import '../services/auth_service.dart';
import '../models/assistant.dart';
import '../repositories/assistant_repository.dart';
import '../repositories/firebase_assistant_repository.dart';
import '../core/snackbar_helper.dart';

final assistantRepositoryProvider = Provider<AssistantRepository>((ref) {
  return FirebaseAssistantRepository();
});

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _schoolNameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _schoolNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return email.contains('@') && email.contains('.');
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      showErrorSnackBar(context, 'הסיסמאות אינן תואמות');
      return;
    }

    if (password.length < 6) {
      showErrorSnackBar(context, 'הסיסמה חייבת להכיל לפחות 6 תווים');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.signUp(email, password);

      if (user != null) {
        final assistant = Assistant(
          id: user.uid,
          email: email,
          fullName: _fullNameController.text.trim(),
          schoolName: _schoolNameController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
        );

        final repository = ref.read(assistantRepositoryProvider);
        await repository.createAssistant(assistant);

        if (mounted) {
          showSuccessSnackBar(context, 'הרשמה הושלמה בהצלחה');
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/add-child',
            (route) => false,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String errorMessage = 'הרשמה נכשלה';
        if (e.code == 'email-already-in-use') {
          errorMessage = 'כתובת האימייל כבר בשימוש';
        } else if (e.code == 'weak-password') {
          errorMessage = 'הסיסמה חלשה מדי';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'כתובת אימייל לא תקינה';
        }
        showErrorSnackBar(context, errorMessage);
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
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                const Color(0xFF2196F3).withOpacity(0.06),
                Colors.white,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                AppBar(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  title: const Text(
                    'הרשמה',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  centerTitle: true,
                ),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: ListView(
                        padding: const EdgeInsets.all(24.0),
                        children: [
                          const SizedBox(height: 20),
                          const Text(
                            'צור חשבון חדש',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'מלא את הפרטים להרשמה',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          AppTextField(
                            controller: _emailController,
                            label: 'אימייל',
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 20),
                          AppTextField(
                            controller: _passwordController,
                            label: 'סיסמה',
                            obscureText: true,
                          ),
                          const SizedBox(height: 20),
                          AppTextField(
                            controller: _confirmPasswordController,
                            label: 'אישור סיסמה',
                            obscureText: true,
                          ),
                          const SizedBox(height: 20),
                          AppTextField(
                            controller: _fullNameController,
                            label: 'שם מלא',
                          ),
                          const SizedBox(height: 20),
                          AppTextField(
                            controller: _schoolNameController,
                            label: 'שם בית הספר',
                          ),
                          const SizedBox(height: 20),
                          AppTextField(
                            controller: _phoneController,
                            label: 'טלפון (אופציונלי)',
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 32),
                          PrimaryButton(
                            text: 'הרשמה',
                            onPressed: _handleRegister,
                            loading: _isLoading,
                          ),
                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacementNamed('/login');
                            },
                            child: Text(
                              'יש לך כבר חשבון? התחבר',
                              style: TextStyle(
                                fontSize: 16,
                                color: const Color(0xFF2196F3),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
