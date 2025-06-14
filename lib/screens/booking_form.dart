import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client; // ✅ Supabase Client

class BookingForm extends StatefulWidget {
  final String selectedDate;  // Date string
  final String selectedSlot;  // Slot string

  BookingForm({required this.selectedDate, required this.selectedSlot});

  @override
  _BookingFormState createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final _formKey = GlobalKey<FormState>();
  String? fullName;
  String? phoneNumber;
  bool _isLoading = false;

  // ✅ Confirm Booking (Using Supabase)
  Future<void> _confirmBooking() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("⚠️ You must be logged in to book a slot.")),
        );
        return;
      }

      // Convert the selectedDate string to DateTime
      DateTime selectedDateTime = DateTime.parse(widget.selectedDate);

      await supabase.from("bookings").insert({
        "user_id": user.id,
        "full_name": fullName,
        "phone_number": phoneNumber,
        "date": selectedDateTime.toIso8601String(), // Storing DateTime as a string
        "slot": widget.selectedSlot,
        "status": "Pending",
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Booking Confirmed for ${widget.selectedSlot} on ${widget.selectedDate}")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: ${e.toString()}")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Complete Booking")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text("Slot: ${widget.selectedSlot}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text("Date: ${widget.selectedDate}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(labelText: "Full Name"),
                validator: (value) => value == null || value.isEmpty ? "Please enter your name" : null,
                onSaved: (value) => fullName = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Phone Number"),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Enter a valid phone number";
                  if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) return "Phone number must be 10 digits";
                  return null;
                },
                onSaved: (value) => phoneNumber = value,
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _confirmBooking,
                child: Text("Confirm Booking"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
