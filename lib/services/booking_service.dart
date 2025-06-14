import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'supabase_service.dart';

class BookingService {
  final SupabaseClient supabase = SupabaseService.client;

  /// ✅ 1️⃣ Fetch available slots for a specific date
  Future<List<String>> fetchAvailableSlots(String date) async {
    try {
      final response = await supabase
          .from("slots")
          .select("slot, available")
          .eq("date", date);

      if (response.isEmpty) {
        await _createSlotsForDate(date);
        return ["7AM", "9AM", "11AM", "1PM", "3PM", "5PM"];
      }

      List<String> availableSlots = response
          .where((slotData) => slotData["available"] == true)
          .map<String>((slotData) => slotData["slot"] as String)
          .toList();

      print("✅ Available Slots for $date: $availableSlots");
      return availableSlots;
    } catch (e) {
      print("❌ Error fetching slots: $e");
      return [];
    }
  }

  /// ✅ 2️⃣ Auto-create default slots if missing
  Future<void> _createSlotsForDate(String date) async {
    try {
      List<Map<String, dynamic>> defaultSlots = [
        {"date": date, "slot": "7AM", "available": true},
        {"date": date, "slot": "9AM", "available": true},
        {"date": date, "slot": "11AM", "available": true},
        {"date": date, "slot": "1PM", "available": true},
        {"date": date, "slot": "3PM", "available": true},
        {"date": date, "slot": "5PM", "available": true},
      ];

      await supabase.from("slots").upsert(defaultSlots);
      print("✅ Auto-created slots for $date");
    } catch (e) {
      print("❌ Error creating slots: $e");
    }
  }

  /// ✅ 3️⃣ Book a slot (Fix for Time Format Issue)
  Future<bool> bookSlot(String date, String slot, Map<String, String> uploadedDocs) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception("❌ User not logged in");

      // ✅ Fix: Convert DateTime to "HH:MM:SS" format for Supabase (TIME type)
      String formattedTime = DateFormat("HH:mm:ss").format(DateTime.now());

      await supabase.from("bookings").insert({
        "user_id": user.id,
        "selected_date": date,
        "selected_slot": slot,
        "upload_time": formattedTime,  // ✅ Fix for Supabase TIME column
        "slot_time": formattedTime,    // ✅ Fix for Supabase TIME column
        "documents": uploadedDocs,
        "status": "Waiting for Confirmation",
        "created_at": DateTime.now().toIso8601String(),
      });

      // 🔹 Mark slot as unavailable
      await supabase.from("slots").update({"available": false}).match({"date": date, "slot": slot});

      print("✅ Slot booked successfully at $formattedTime");
      return true;
    } catch (e) {
      print("❌ Error booking slot: $e");
      return false;
    }
  }

  /// ✅ 4️⃣ Admin Approves Booking (User Upload Deadline Set)
  Future<void> approveBooking(int bookingId) async {
    try {
      DateTime deadline = DateTime.now().add(Duration(hours: 1)); // ⏳ 1-hour deadline

      await supabase.from("bookings").update({
        "status": "Confirmed",
        "document_upload_deadline": deadline.toIso8601String(),
      }).match({"id": bookingId});

      print("✅ Booking Approved: $bookingId");
    } catch (e) {
      print("❌ Error approving booking: $e");
    }
  }

  /// ✅ 5️⃣ Admin Rejects Booking & Free Slot
  Future<void> rejectBooking(int bookingId) async {
    try {
      final booking = await supabase
          .from("bookings")
          .select("selected_date, selected_slot")
          .eq("id", bookingId)
          .maybeSingle();

      if (booking == null) return;

      String date = booking["selected_date"];
      String slot = booking["selected_slot"];

      // 🔹 Free up slot
      await supabase
          .from("slots")
          .update({"available": true})
          .match({"date": date, "slot": slot});

      await supabase.from("bookings").update({"status": "Rejected"}).match({"id": bookingId});

      print("✅ Booking Rejected: $bookingId");
    } catch (e) {
      print("❌ Error rejecting booking: $e");
    }
  }

  /// ✅ 6️⃣ Auto-cancel expired bookings
  Future<void> checkExpiredBookings() async {
    try {
      DateTime now = DateTime.now();

      final expiredBookings = await supabase
          .from("bookings")
          .select("id, selected_date, selected_slot")
          .eq("status", "Confirmed")
          .lt("document_upload_deadline", now.toIso8601String());

      for (var booking in expiredBookings) {
        int bookingId = booking["id"];
        String date = booking["selected_date"];
        String slot = booking["selected_slot"];

        await supabase.from("bookings").update({"status": "Cancelled"}).match({"id": bookingId});

        // 🔹 Free up slot when booking is cancelled
        await supabase
            .from("slots")
            .update({"available": true})
            .match({"date": date, "slot": slot});
      }

      print("✅ Expired bookings cancelled successfully");
    } catch (e) {
      print("❌ Error checking expired bookings: $e");
    }
  }

  /// ✅ 7️⃣ Get real-time booking updates
  Stream<List<Map<String, dynamic>>> getBookingsStream() {
    return supabase.from("bookings").stream(primaryKey: ["id"]).execute();
  }
}
