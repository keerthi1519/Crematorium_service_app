import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:cremation_app/services/notification_service.dart';
import 'package:cremation_app/widgets/custom_appbar.dart';
import 'package:cremation_app/theme/app_theme.dart';

final supabase = Supabase.instance.client;
final Uuid uuid = Uuid();

class DocumentUploadScreen extends StatefulWidget {
  final String selectDate;
  final String selectedSlot;
  final String deceasedName;

  DocumentUploadScreen({
    required this.selectDate,
    required this.selectedSlot,
    required this.deceasedName,
  });

  @override
  _DocumentUploadScreenState createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  Map<String, File?> selectedFiles = {
    "Photo of Deceased": null,
    "Death Certificate": null,
    "Aadhaar Card": null,
    "Doctor Approval": null,
    "Applicant's Aadhaar Card": null,
  };

  bool isUploading = false;
  bool isSubmitted = false;
  TimeOfDay? selectedTime;

  String formatSlotTime(String slot) {
    try {
      if (slot.isEmpty) return "12:00:00";
      DateTime parsedTime = DateFormat("hh:mm a").parse(slot);
      return DateFormat("HH:mm:ss").format(parsedTime);
    } catch (e) {
      return "12:00:00";
    }
  }

  Future<void> pickFile(String documentType) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      double fileSizeInMB = (await file.length()) / (1024 * 1024);

      if (fileSizeInMB > 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("File size exceeds 5MB.")),
        );
        return;
      }

      setState(() {
        selectedFiles[documentType] = file;
      });
    }
  }

  Future<String?> uploadFile(File file, String documentType) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception("User not logged in");

      String fileName = "${uuid.v4()}_${documentType}_${p.basename(file.path)}".replaceAll(" ", "_");
      final filePath = "documents/${user.id}/$fileName";

      await supabase.storage.from("documents").uploadBinary(filePath, await file.readAsBytes());
      return supabase.storage.from("documents").getPublicUrl(filePath);
    } catch (e) {
      print("Upload error: $e");
      return null;
    }
  }

  Future<void> submitDocuments() async {
    if (selectedFiles.values.any((file) => file == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please upload all required documents.")),
      );
      return;
    }

    setState(() => isUploading = true);

    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception("User not logged in");

      DateTime parsedDate = DateFormat("yyyy-MM-dd").parse(widget.selectDate);
      Map<String, String?> uploadedUrls = {};

      for (String docType in selectedFiles.keys) {
        if (selectedFiles[docType] != null) {
          String? url = await uploadFile(selectedFiles[docType]!, docType);
          if (url == null) throw Exception("Upload failed for $docType");
          uploadedUrls[docType] = url;
        }
      }

      await supabase.from("bookings").insert({
        "user_id": user.id,
        "deceased_name": widget.deceasedName,
        "slot_time": selectedTime != null
            ? "${selectedTime!.hour}:${selectedTime!.minute}:00"
            : formatSlotTime(widget.selectedSlot),
        "select_date": DateFormat("yyyy-MM-dd").format(parsedDate),
        "selected_slot": formatSlotTime(widget.selectedSlot),
        "date": DateFormat("yyyy-MM-dd").format(parsedDate),
        "photo_url": uploadedUrls["Photo of Deceased"],
        "death_certificate_url": uploadedUrls["Death Certificate"],
        "aadhaar_url": uploadedUrls["Aadhaar Card"],
        "doctor_verification_url": uploadedUrls["Doctor Approval"],
        "applicant_aadhaar_url": uploadedUrls["Applicant's Aadhaar Card"],
        "status": "Submitted",
        "admin_verification": "Pending",
        "upload_time": DateTime.now().toUtc().toIso8601String(),
      });

      setState(() {
        isUploading = false;
        isSubmitted = true;
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text("🎉 Submission Successful"),
          content: Text("Your documents have been uploaded successfully."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(
                  context,
                  "/booking_status",
                  arguments: {
                    "selectDate": widget.selectDate,
                    "selectedSlot": formatSlotTime(widget.selectedSlot),
                  },
                );
              },
              child: Text("Go to Status"),
            )
          ],
        ),
      );
    } catch (e) {
      print("Error: $e");
      setState(() => isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F6F8),
      appBar: CustomAppBar(title: Text("Upload Documents")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Documents for:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 4),
            Text(
              "${widget.deceasedName} • ${widget.selectedSlot} • ${widget.selectDate}",
              style: TextStyle(color: Colors.grey[700]),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: selectedFiles.keys.length,
                itemBuilder: (context, index) {
                  String docType = selectedFiles.keys.elementAt(index);
                  File? file = selectedFiles[docType];

                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                    margin: EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      title: Text(docType),
                      subtitle: Text(
                        file != null ? p.basename(file.path) : "No file selected",
                        style: TextStyle(
                          color: file != null ? Colors.green[700] : Colors.grey[600],
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.upload_file_rounded, color: Colors.blueAccent),
                        onPressed: () => pickFile(docType),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: isSubmitted || isUploading ? null : submitDocuments,
              icon: Icon(Icons.cloud_upload_rounded),
              label: Text(isSubmitted ? "Documents Submitted" : "Submit Documents"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                minimumSize: Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            if (isUploading)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
