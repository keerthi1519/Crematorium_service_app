import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cremation_app/screens/slot_availability_screen.dart';

final supabase = Supabase.instance.client; // ✅ Supabase Client

class DateSelectionScreen extends StatefulWidget {
  @override
  _DateSelectionScreenState createState() => _DateSelectionScreenState();
}

class _DateSelectionScreenState extends State<DateSelectionScreen> {
  DateTime? selectedDate;
  bool _isCheckingSlots = false;
  bool _slotsAvailable = false;

  // ✅ Check slot availability in Supabase
  Future<void> _checkSlotAvailability() async {
    if (selectedDate == null) return;

    setState(() => _isCheckingSlots = true);

    try {
      // Convert the DateTime object to the proper format (yyyy-MM-dd)
      String formattedDate = selectedDate!.toIso8601String().split('T')[0];

      final response = await supabase
          .from("slots")
          .select()
          .eq("date", formattedDate)
          .eq("available", true);

      if (response.isNotEmpty) {
        setState(() => _slotsAvailable = true);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SlotAvailabilityScreen(selectedDate: selectedDate!),
          ),
        );
      } else {
        setState(() => _slotsAvailable = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("⚠️ No slots available on this date.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error checking slots: ${e.toString()}")),
      );
    } finally {
      setState(() => _isCheckingSlots = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Date')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );

                if (pickedDate != null) {
                  setState(() => selectedDate = pickedDate);
                }
              },
              child: const Text('Select Date'),
            ),
            const SizedBox(height: 20),
            if (selectedDate != null)
              Text(
                'Selected Date: ${selectedDate!.toLocal()}'.split(' ')[0],
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            const SizedBox(height: 20),
            if (selectedDate != null)
              _isCheckingSlots
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _checkSlotAvailability,
                child: const Text('Check Availability'),
              ),
          ],
        ),
      ),
    );
  }
}
