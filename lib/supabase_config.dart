import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static final SupabaseClient supabase = SupabaseClient(
    // It's better to store these in environment variables or configuration files
    'https://your-project.supabase.co', // Replace with your Supabase URL
'your-secret-key'  );

  // It's also good practice to provide a method for initializing Supabase (useful in main.dart)
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://your-project.supabase.co', // Replace with your Supabase URL
      anonKey: 'your-secret-key', // Replace with your Supabase anon key
    );
  }
}
