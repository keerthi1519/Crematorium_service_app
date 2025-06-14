import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'document_upload_screen.dart';
import 'waiting_confirmation_screen.dart';
import 'medical_certificate_form_screen.dart';
import 'package:cremation_app/widgets/custom_appbar.dart';

class UserDashboard extends StatefulWidget {
  final bool enableBooking;

  UserDashboard({required this.enableBooking});

  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  DateTime selectDate = DateTime.now();
  List<String> allSlots = ["09:00", "10:00", "11:00", "12:00", "15:00", "17:00"];
  List<String> availableSlots = [];
  String? selectedSlot;
  final supabase = Supabase.instance.client;
  TextEditingController deceasedNameController = TextEditingController();
  bool isLoading = false;
  bool hasBooking = false;
  Map<String, dynamic>? userBooking;
  bool isMedicalFormFilled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchAvailableSlots();
      checkIfUserHasBooking();
      checkIfMedicalFormFilled();
    });
  }

  @override
  void dispose() {
    deceasedNameController.dispose();
    super.dispose();
  }

  Future<void> checkIfUserHasBooking() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final response = await supabase
          .from('bookings')
          .select()
          .eq('user_id', userId)
          .neq('status', 'Declined')
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (!mounted) return;

      setState(() {
        hasBooking = response != null;
        userBooking = response;
      });
    } catch (e) {
      print("Error checking user booking: $e");
    }
  }

  Future<void> checkIfMedicalFormFilled() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final response = await supabase
          .from('medical_certificates')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();

      if (mounted) {
        setState(() => isMedicalFormFilled = response != null);
      }
    } catch (e) {
      print("Error checking medical form: $e");
    }
  }

  Future<void> fetchAvailableSlots() async {
    setState(() => isLoading = true);
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectDate);

    try {
      final response = await supabase
          .from('bookings')
          .select('slot_time, status')
          .eq('date', formattedDate)
          .neq('status', 'Declined');

      List<String> bookedSlots = response.map<String>((booking) {
        String fullSlot = booking['slot_time'].toString();
        return fullSlot.substring(0, 5);
      }).toList();

      if (mounted) {
        setState(() {
          availableSlots = allSlots
              .where((slot) => !bookedSlots.contains(slot))
              .toList();
          selectedSlot = null;
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch slots")),
        );
      }
    }

    if (mounted) setState(() => isLoading = false);
  }

  void navigateToMedicalForm() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MedicalCertificateFormScreen()),
    );

    if (result == true && mounted) {
      setState(() => isMedicalFormFilled = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Medical form submitted. You can now book a slot.")),
      );
    }
  }

  void navigateToDocumentUpload() {
    if (deceasedNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter the deceased's name")),
      );
      return;
    }

    if (selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a slot before proceeding")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentUploadScreen(
          selectDate: DateFormat('yyyy-MM-dd').format(selectDate),
          selectedSlot: selectedSlot!,
          deceasedName: deceasedNameController.text.trim(),
        ),
      ),
    );
  }

  void navigateToStatusScreen() async {
    if (userBooking != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WaitingConfirmationScreen(
            bookingData: userBooking!,
          ),
        ),
      );
      if (mounted) checkIfUserHasBooking();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.teal.shade600;
    final Color secondaryColor = Colors.indigo.shade400;
    final Color disabledColor = Colors.grey.shade400;

    return Scaffold(
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMedicalFormFilled)
              Container(
                padding: EdgeInsets.all(14),
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  border: Border.all(color: Colors.red.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.red),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Please fill the medical certificate form before booking a slot.",
                        style: TextStyle(
                          color: Colors.red.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Text("Select Date", style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 30)),
                );
                if (picked != null) {
                  setState(() => selectDate = picked);
                  fetchAvailableSlots();
                }
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: secondaryColor.withOpacity(0.05),
                  border: Border.all(color: secondaryColor.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  DateFormat('yyyy-MM-dd').format(selectDate),
                  style: TextStyle(fontSize: 16, color: secondaryColor),
                ),
              ),
            ),
            SizedBox(height: 24),

            Text("Deceased's Name", style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 10),
            TextField(
              controller: deceasedNameController,
              decoration: InputDecoration(
                hintText: "Enter name",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
            SizedBox(height: 24),

            Text("Available Slots", style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 10),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : availableSlots.isEmpty
                ? Text(
              "No slots available for selected date",
              style: TextStyle(color: Colors.grey.shade600),
            )
                : DropdownButtonFormField<String>(
              value: selectedSlot,
              hint: Text("Choose a slot"),
              isExpanded: true,
              items: availableSlots.map((slot) {
                return DropdownMenuItem(value: slot, child: Text(slot));
              }).toList(),
              onChanged: (slot) => setState(() => selectedSlot = slot),
              decoration: InputDecoration(
                contentPadding:
                EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
            SizedBox(height: 24),

            if (!isMedicalFormFilled)
              ElevatedButton.icon(
                onPressed: navigateToMedicalForm,
                icon: Icon(Icons.assignment_turned_in),
                label: Text("Fill Medical Certificate Form"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),

            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: widget.enableBooking ? navigateToDocumentUpload : null,
              icon: Icon(Icons.calendar_today),
              label: Text("Book Slot"),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.enableBooking ? secondaryColor : disabledColor,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            if (!widget.enableBooking)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "Booking is currently disabled.",
                  style: TextStyle(color: Colors.red),
                ),
              ),

            SizedBox(height: 30),
            Divider(thickness: 1),

            if (hasBooking)
              ElevatedButton.icon(
                onPressed: navigateToStatusScreen,
                icon: Icon(Icons.info_outline),
                label: Text("Check Booking Status"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}