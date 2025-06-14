import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cremation_app/theme/app_theme.dart';


final supabase = Supabase.instance.client; // ✅ Supabase Client

class SlotAvailabilityScreen extends StatefulWidget {
  final DateTime selectedDate;

  SlotAvailabilityScreen({required this.selectedDate});

  @override
  _SlotAvailabilityScreenState createState() => _SlotAvailabilityScreenState();
}

class _SlotAvailabilityScreenState extends State<SlotAvailabilityScreen> {
  List<Map<String, dynamic>> slots = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSlots();
  }

  // 🔹 Fetch Available Slots from Supabase
  Future<void> _fetchSlots() async {
    setState(() => _isLoading = true);

    try {
      final response = await supabase
          .from('slots')
          .select()
          .eq('date', widget.selectedDate.toIso8601String().split('T')[0]); // Filter by selected date

      setState(() {
        slots = List<Map<String, dynamic>>.from(response); // Convert response to List<Map> if needed
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching slots: $e");
      setState(() => _isLoading = false);
    }
  }

  // 🔹 Book a Slot
  Future<void> _bookSlot(String slotId, String time) async {
    try {
      await supabase.from('bookings').insert({
        'date': widget.selectedDate.toIso8601String().split('T')[0],
        'slot_id': slotId,
        'time': time,
        'user_id': supabase.auth.currentUser?.id, // Get logged-in user ID
        'status': 'Booked',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Slot booked successfully!")),
      );

      _fetchSlots(); // ✅ Refresh slot availability
    } catch (e) {
      print("Error booking slot: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to book slot.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Available Slots on ${widget.selectedDate.toLocal().toString().split(' ')[0]}'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // ✅ Show Loader While Fetching
          : slots.isEmpty
          ? Center(child: Text("No slots available for this date.")) // ✅ Show message if no slots
          : ListView.builder(
        itemCount: slots.length,
        itemBuilder: (context, index) {
          final slot = slots[index];
          bool isBooked = slot['status'] == 'Booked';

          return ListTile(
            title: Text('Slot ${slot['slot_id']}: ${slot['time']}'),
            trailing: isBooked
                ? Icon(Icons.block, color: Colors.red) // Show "Booked" status
                : ElevatedButton(
              onPressed: () => _bookSlot(slot['slot_id'], slot['time']),
              child: const Text('Book'),
            ),
          );
        },
      ),
    );
  }
}
