import 'package:intl/intl.dart'; // Import for date formatting
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class DatabaseService {
  final SupabaseClient supabase = SupabaseService.client;

  /// ✅ 1️⃣ Fetch all booked slots
  Future<List<Map<String, dynamic>>> getBookedSlots() async {
    try {
      final response = await supabase.from('booked_slots').select();
      return response;
    } catch (e) {
      print("❌ Error fetching booked slots: $e");
      return [];
    }
  }

  /// ✅ 2️⃣ Book a slot (Fixed time format issue)
  Future<void> bookSlot(Map<String, dynamic> slotData) async {
    try {
      if (slotData.containsKey('slot_time')) { // Ensure 'slot_time' exists
        dynamic originalTime = slotData['slot_time'];

        // If it's a DateTime object, convert it to HH:mm:ss format
        if (originalTime is DateTime) {
          slotData['slot_time'] = DateFormat.Hms().format(originalTime); // "HH:mm:ss"
        }
        // If it's a String but in the wrong format, try parsing and fixing it
        else if (originalTime is String) {
          DateTime parsedTime = DateTime.parse(originalTime);
          slotData['slot_time'] = DateFormat.Hms().format(parsedTime);
        }
      }

      await supabase.from('booked_slots').insert(slotData);
      print("✅ Slot booked successfully");
    } catch (e) {
      print("❌ Error booking slot: $e");
      throw Exception("Failed to book slot");
    }
  }

  /// ✅ 3️⃣ Cancel a booking
  Future<void> cancelBooking(int bookingId) async {
    try {
      await supabase.from('booked_slots').delete().match({"id": bookingId});
      print("✅ Booking cancelled successfully");
    } catch (e) {
      print("❌ Error cancelling booking: $e");
      throw Exception("Failed to cancel booking");
    }
  }
}
