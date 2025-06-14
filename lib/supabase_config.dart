import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static final SupabaseClient supabase = SupabaseClient(
    // It's better to store these in environment variables or configuration files
    'https://your-project.supabase.co', // Replace with your Supabase URL
'your-secret-key'  );

  // It's also good practice to provide a method for initializing Supabase (useful in main.dart)
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://lcobvndzdtpgdwywjtxb.supabase.co', // Replace with your Supabase URL
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imxjb2J2bmR6ZHRwZ2R3eXdqdHhiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDMyMTE2OTUsImV4cCI6MjA1ODc4NzY5NX0.eosLwIg_fB2HsPFiFPZ4VPQur2ZOdrxuhDTPOr_8hTs', // Replace with your Supabase anon key
    );
  }
}
