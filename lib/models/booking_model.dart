import 'package:flutter/material.dart';

class BookingStatusScreen extends StatelessWidget {
  final String selectedDate;
  final String selectedSlot;

  BookingStatusScreen({required this.selectedDate, required this.selectedSlot});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Booking Confirmation"),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 80),
            SizedBox(height: 16),
            Text(
              "Your Slot Has Been Booked!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("📅 Date: ${selectedDate.isNotEmpty ? selectedDate : 'Unknown'}",
                      style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8),
                  Text("⏰ Time: ${selectedSlot.isNotEmpty ? selectedSlot : 'Unknown'}",
                      style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("📌 Please Read Before You Arrive", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  bulletPoint("Arrive at the crematorium at least **10 minutes before** your booked time."),
                  bulletPoint("You can **collect the ashes 1 hour** after the cremation is completed."),
                  bulletPoint("Please note: **Cash payments only** are accepted at the crematorium."),
                  bulletPoint("If any religious or cultural rituals are needed, they can be done **at the crematorium before the process**."),
                ],
              ),
            ),
            SizedBox(height: 30),
            Text(
              "⏳ Your booking is pending confirmation by the admin.",
              style: TextStyle(fontSize: 16, color: Colors.orange[800]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back),
              label: Text("Back to Dashboard"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
            SizedBox(height: 40),
            Divider(thickness: 1.2),
            SizedBox(height: 10),
            Text(
              "📞 Need Help?",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 6),
            Text("Contact Number: 0000000000", style: TextStyle(fontSize: 16)),
            Text("Email: abcd@gmail.com", style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("• ", style: TextStyle(fontSize: 16)),
          Expanded(child: Text(text, style: TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
