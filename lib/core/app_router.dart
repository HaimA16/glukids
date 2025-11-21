import 'package:flutter/material.dart';
import '../screens/welcome_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/add_child_screen.dart';
import '../screens/child_detail_screen.dart';
import '../screens/add_reading_screen.dart';
import '../screens/add_treatment_screen.dart';
import '../screens/daily_log_screen.dart';
import '../screens/insulin_calculator_screen.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/welcome':
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
        
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
        
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case '/dashboard':
        return MaterialPageRoute(builder: (_) => const DashboardScreen());

      case '/add-child':
        return MaterialPageRoute(builder: (_) => const AddChildScreen());

      case '/child':
        final args = settings.arguments as Map<String, dynamic>?;
        final childId = args?['childId'] as String?;
        if (childId == null) {
          throw Exception('ChildDetailScreen requires childId argument');
        }
        return MaterialPageRoute(
          builder: (_) => ChildDetailScreen(childId: childId),
        );

      case '/add-reading':
        final args = settings.arguments as Map<String, dynamic>?;
        final childId = args?['childId'] as String?;
        if (childId == null) {
          throw Exception('AddReadingScreen requires childId argument');
        }
        return MaterialPageRoute(
          builder: (_) => AddReadingScreen(childId: childId),
        );

      case '/add-treatment':
        final args = settings.arguments as Map<String, dynamic>?;
        final childId = args?['childId'] as String?;
        if (childId == null) {
          throw Exception('AddTreatmentScreen requires childId argument');
        }
        return MaterialPageRoute(
          builder: (_) => AddTreatmentScreen(childId: childId),
        );

      case '/daily-log':
        final args = settings.arguments as Map<String, dynamic>?;
        final childId = args?['childId'] as String?;
        if (childId == null) {
          throw Exception('DailyLogScreen requires childId argument');
        }
        return MaterialPageRoute(
          builder: (_) => DailyLogScreen(childId: childId),
        );

      case '/insulin-calculator':
        final args = settings.arguments as Map<String, dynamic>?;
        final childId = args?['childId'] as String?;
        if (childId == null) {
          throw Exception('InsulinCalculatorScreen requires childId argument');
        }
        return MaterialPageRoute(
          builder: (_) => InsulinCalculatorScreen(childId: childId),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route not found: ${settings.name}'),
            ),
          ),
        );
    }
  }
}

