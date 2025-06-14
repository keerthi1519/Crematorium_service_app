import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/home_screen.dart';
import 'package:cremation_app/theme/app_theme.dart';
import 'package:cremation_app/screens/login_screen.dart';
import 'screens/admin_login_screen.dart';
import 'services/notification_service.dart';
import 'screens/user_dashboard.dart';
import 'screens/booking_status_screen.dart';
import 'screens/document_upload_screen.dart';

// ✅ MAIN ENTRY POINT
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Supabase
  await Supabase.initialize(
    url: 'https://your-project.supabase.co',
    anonKey:
    'your-secret-key',
  );

  final supabase = Supabase.instance.client;

  // ✅ Refresh session if expired
  final session = supabase.auth.currentSession;
  if (session != null && session.isExpired) {
    try {
      await supabase.auth.refreshSession();
      print('✅ Session refreshed');
    } catch (e) {
      print('❌ Session refresh failed: $e');
      await supabase.auth.signOut();
    }
  }

  // ✅ Initialize Notifications
  await NotificationService.initialize();

  runApp(MyApp());
}

// ✅ MAIN APP CLASS
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cremation App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: HomeScreen(),
      routes: {
        '/login': (_) => LoginScreen(),
        '/admin_login': (_) => AdminLoginScreen(),
        '/user_dashboard': (_) => UserDashboard(enableBooking: true),
      },
      onGenerateRoute: (settings) {
        final args = settings.arguments as Map<String, dynamic>?;

        switch (settings.name) {
          case '/document_upload':
            if (args != null &&
                args.containsKey("selectDate") &&
                args.containsKey("selectedSlot") &&
                args.containsKey("deceasedName")) {
              return MaterialPageRoute(
                builder: (_) => DocumentUploadScreen(
                  selectDate: args["selectDate"],
                  selectedSlot: args["selectedSlot"],
                  deceasedName: args["deceasedName"],
                ),
              );
            }
            break;

          case '/booking_status':
            if (args != null &&
                args.containsKey("selectDate") &&
                args.containsKey("selectedSlot")) {
              return MaterialPageRoute(
                builder: (_) => BookingStatusScreen(
                  selectDate: args["selectDate"],
                  selectedSlot: args["selectedSlot"],
                ),
              );
            }
            break;
        }

        // ✅ Fallback route (optional)
        return null;
      },
    );
  }
}
