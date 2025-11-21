import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: Implement actual dark mode state management
// Currently stored in local state - future enhancement: persist to SharedPreferences or Riverpod state
final darkModeProvider = StateProvider<bool>((ref) => false);

// TODO: Implement actual notifications state management
// Future enhancement: integrate with Firebase Cloud Messaging (FCM) for push notifications
final notificationsProvider = StateProvider<bool>((ref) => true);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkMode = ref.watch(darkModeProvider);
    final notifications = ref.watch(notificationsProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: const Text(
            'הגדרות',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
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
                        Icon(
                          Icons.palette_rounded,
                          color: const Color(0xFF2196F3),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'עיצוב',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SwitchListTile(
                      value: darkMode,
                      onChanged: (value) {
                        ref.read(darkModeProvider.notifier).state = value;
                        // TODO: Implement actual dark mode theme switching
                        // Future enhancement: Use ThemeMode.dark / ThemeMode.light
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'מצב כהה - זמין בקרוב',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.grey.shade700,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      title: const Text('מצב כהה'),
                      subtitle: const Text('החלף בין מצב בהיר וכהה'),
                      secondary: Icon(
                        darkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                        color: darkMode ? Colors.grey.shade800 : Colors.amber,
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
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
                        Icon(
                          Icons.notifications_rounded,
                          color: const Color(0xFF2196F3),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'התראות',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SwitchListTile(
                      value: notifications,
                      onChanged: (value) {
                        ref.read(notificationsProvider.notifier).state = value;
                        // TODO: Implement actual push notifications
                        // Future enhancement: Integrate with Firebase Cloud Messaging (FCM)
                        // and request device permissions when enabling
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              value
                                  ? 'התראות מופעלות (זמין בקרוב)'
                                  : 'התראות מושבתות',
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: value
                                ? const Color(0xFF4CAF50)
                                : Colors.grey.shade700,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      title: const Text('התראות היפו/היפר'),
                      subtitle: const Text(
                        'קבל התראות כאשר יש קריאות נמוכות או גבוהות',
                      ),
                      secondary: Icon(
                        notifications ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
                        color: notifications ? Colors.orange : Colors.grey.shade600,
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
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
                        Icon(
                          Icons.info_outline_rounded,
                          color: const Color(0xFF2196F3),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'אודות',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildAboutRow(
                      'גרסה',
                      '1.0.0',
                      Icons.info_rounded,
                    ),
                    const Divider(height: 24),
                    _buildAboutRow(
                      'GluKids',
                      'מערכת ניהול לילדים סוכרתיים',
                      Icons.medical_services_rounded,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF1A1A1A),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

