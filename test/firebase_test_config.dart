// Test helper for Firebase initialization in test environment
// This allows tests to run in CI without requiring real Firebase config files

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

/// Initializes Firebase for testing with dummy options that don't require
/// real Firebase configuration files or network access.
/// 
/// This should be called in `setUpAll()` for any test file that might
/// trigger Firebase initialization (e.g., widget tests that import app.dart).
/// 
/// For unit tests that don't use Firebase (e.g., model tests, service tests),
/// this is not needed.
Future<void> setupFirebaseForTests() async {
  // Ensure Flutter bindings are initialized for tests
  TestWidgetsFlutterBinding.ensureInitialized();

  // Check if Firebase is already initialized
  if (Firebase.apps.isNotEmpty) {
    return; // Already initialized
  }

  try {
    // Initialize Firebase with dummy test options
    // These options don't connect to a real Firebase project
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'test-api-key',
        appId: 'test-app-id',
        messagingSenderId: '123456789',
        projectId: 'test-project-id',
        storageBucket: 'test-project-id.appspot.com',
      ),
      name: '[DEFAULT]',
    );
  } on FirebaseException catch (e) {
    // If Firebase initialization fails (e.g., already initialized),
    // we ignore it and continue - this is fine for tests
    // Silently ignore errors - tests should work without Firebase
    if (e.code == 'already-initialized') {
      // This is expected and fine
      return;
    }
    // Other Firebase errors are also fine - tests don't need real Firebase
  } catch (e) {
    // For other errors, we also continue - tests should work without Firebase
    // Silently ignore - no logging needed in tests
  }
}


