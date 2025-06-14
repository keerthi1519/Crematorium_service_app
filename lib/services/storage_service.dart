import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mime/mime.dart'; // ✅ To detect file MIME type
import 'package:path/path.dart' as p;
import 'supabase_service.dart';

class StorageService {
  final SupabaseClient supabase = SupabaseService.client;

  /// ✅ 1️⃣ Upload a Document (Secure & Fixed)
  Future<String> uploadDocument(File file, String userId, String documentType) async {
    try {
      // Generate a unique filename
      String fileName = "${DateTime.now().millisecondsSinceEpoch}_${p.basename(file.path)}";
      final filePath = "uploads/$userId/$documentType/$fileName";

      final fileBytes = await file.readAsBytes();

      // ✅ Detect file MIME type
      final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';

      // ✅ Upload the file as binary
      await supabase.storage.from("documents").uploadBinary(
        filePath,
        fileBytes,
        fileOptions: FileOptions(contentType: mimeType),
      );

      // ✅ Return the public URL
      String fileUrl = supabase.storage.from("documents").getPublicUrl(filePath);
      print("✅ Document uploaded successfully: $fileUrl");

      return fileUrl;
    } catch (e) {
      print("❌ Upload Error: $e");
      throw Exception("Failed to upload document: $e");
    }
  }

  /// ✅ 2️⃣ Get List of Uploaded Documents for a User
  Future<List<Map<String, String>>> getUploadedDocuments(String userId) async {
    try {
      final List<FileObject> files = await supabase.storage.from("documents").list(path: "uploads/$userId");

      List<Map<String, String>> fileList = files.map((file) => {
        "name": file.name,
        "url": supabase.storage.from("documents").getPublicUrl("uploads/$userId/${file.name}")
      }).toList();

      print("📂 Retrieved ${fileList.length} uploaded documents for user: $userId");
      return fileList;
    } catch (e) {
      print("❌ Error fetching documents: $e");
      throw Exception("Failed to fetch uploaded documents");
    }
  }
}
