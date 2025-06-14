import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  static late final SupabaseClient _client;

  // ✅ Add your Supabase credentials here (Replace with your actual keys)
  static const String _supabaseUrl = "https://your-project.supabase.co";
  static const String _supabaseAnonKey = "your-secret-key";

  SupabaseService._internal();

  factory SupabaseService() {
    return _instance;
  }
  /// ✅ Initialize Supabase (Call this in main.dart)
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
    );
    _client = Supabase.instance.client;
    print("✅ Supabase Initialized Successfully!");
  }

  /// ✅ Get Supabase Client
  static SupabaseClient get client => _client;

  /// ✅ Upload a file to Supabase Storage
  Future<String?> uploadDocument(File file, String documentType) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception("❌ User not logged in");

      // Generate a unique filename
      String fileName = "${DateTime.now().millisecondsSinceEpoch}_${p.basename(file.path)}";
      final filePath = "uploads/${user.id}/$documentType/$fileName";

      final fileBytes = await file.readAsBytes();

      // ✅ Upload the file as binary
      await _client.storage.from("documents").uploadBinary(filePath, fileBytes);

      // ✅ Return the public URL
      String fileUrl = _client.storage.from("documents").getPublicUrl(filePath);
      print("✅ Document uploaded successfully: $fileUrl");
      return fileUrl;
    } catch (e) {
      print("❌ Upload Error: $e");
      return null;
    }
  }

  /// ✅ Fetch public URL of a stored document
  String fetchDocumentUrl(String filePath) {
    return _client.storage.from("documents").getPublicUrl(filePath);
  }
}
