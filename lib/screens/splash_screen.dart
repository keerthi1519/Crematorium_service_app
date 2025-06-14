import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cremation_app/screens/home_screen.dart';
import 'package:cremation_app/screens/login_screen.dart';
import 'package:cremation_app/screens/admin_dashboard.dart';
final supabase = Supabase.instance.client; // ✅ Supabase Client

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  /// Checks user session and navigates accordingly
  Future<void> _navigateToNextScreen() async {
    await Future.delayed(Duration(seconds: 3)); // Splash screen delay

    final user = supabase.auth.currentUser; // ✅ Supabase User Check
    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', height: 100), // Your app logo
            SizedBox(height: 20),
            CircularProgressIndicator(), // Loading indicator
          ],
        ),
      ),
    );
  }
}
