import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase exactly once
  try {
    // Check if Firebase default app already exists
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('Firebase initialized successfully');
    } else {
      debugPrint('Firebase already initialized');
    }
  } on FirebaseException catch (e) {
    debugPrint('Firebase initialization error: ${e.code} - ${e.message}');
    // Continue app execution - auth flow will handle unauthenticated state
  } catch (e, stackTrace) {
    debugPrint('Unexpected Firebase initialization error: $e');
    debugPrint('Stack trace: $stackTrace');
    // Continue app execution - auth flow will handle unauthenticated state
  }
  
  runApp(
    const ProviderScope(
      child: GluKidApp(),
    ),
  );
}
