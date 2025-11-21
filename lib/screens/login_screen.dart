import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/app_text_field.dart';
import '../widgets/primary_button.dart';
import '../services/auth_service.dart';
import '../core/snackbar_helper.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showErrorSnackBar(context, 'נא למלא את כל השדות');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      await authService.signIn(email, password);
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String errorMessage = 'התחברות נכשלה';
        if (e.code == 'user-not-found') {
          errorMessage = 'משתמש לא נמצא';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'סיסמה שגויה';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'כתובת אימייל לא תקינה';
        } else if (e.code == 'user-disabled') {
          errorMessage = 'המשתמש הושבת';
        }
        showErrorSnackBar(context, errorMessage);
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, 'התחברות נכשלה: ${e.toString()}');
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
            'התחברות סייעת',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 40,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'כניסה למערכת',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'הזן את פרטי הכניסה שלך',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 40),
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
                  const SizedBox(height: 32),
                  PrimaryButton(
                    text: 'כניסה',
                    onPressed: _handleLogin,
                    loading: _isLoading,
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/register');
                    },
                    child: Text(
                      'אין לך חשבון? הירשם',
                      style: TextStyle(
                        fontSize: 16,
                        color: const Color(0xFF2196F3),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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

