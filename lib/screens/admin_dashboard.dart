import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart'; // Import this line at the top of the file

import 'package:cremation_app/services/notification_service.dart';

final supabase = Supabase.instance.client;

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String formatDate(String date) {
    try {
      final DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd/MM/yyyy').format(parsedDate); // Format to MM/DD/YYYY
    } catch (e) {
      return 'Invalid Date'; // Handle invalid or null date
    }
  }
  List<Map<String, dynamic>> bookings = [];
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> filteredBookings = [];
  List<Map<String, dynamic>> medicalCerts = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);
    await fetchBookings();
    await fetchMedicalCertificates();
    filterBookings();
    setState(() => isLoading = false);
  }

  Future<void> fetchBookings() async {
    try {
      final response = await supabase
          .from("bookings")
          .select("""
            id, select_date, selected_slot, slot_time, user_id, deceased_name, 
            created_at, status, admin_verification, aadhaar_url, photo_url, 
            doctor_verification_url, death_certificate_url, applicant_aadhaar_url
          """)
          .order("select_date", ascending: false);

      bookings = List<Map<String, dynamic>>.from(response);
    } catch (error) {
      print("Error fetching bookings: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading bookings.")),
      );
    }
  }

  Future<void> fetchMedicalCertificates() async {
    try {
      final response = await supabase
          .from("medical_certificates")
          .select("*")
          .order("submitted_at", ascending: false);

      medicalCerts = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Fetch Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load certificates")),
      );
    }
  }

  void filterBookings() {
    final query = searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      filteredBookings = bookings;
    } else {
      filteredBookings = bookings.where((booking) {
        final name = booking['deceased_name']?.toString().toLowerCase() ?? '';
        final userId = booking['user_id']?.toString().toLowerCase() ?? '';
        return name.contains(query) || userId.contains(query);
      }).toList();
    }
  }

  Future<void> updateStatus(String bookingId, String status, {String? bookingDate, String? timeSlot}) async {
    try {
      print("Updating booking with ID: $bookingId");

      final response = await supabase.from("bookings").update({
        'status': status,
        'admin_verification': status == "Accepted" ? "Approved" : "Rejected",
      }).eq("id", bookingId);

      print("Supabase update response: $response");

      // Only attempt to delete if slot is accepted and slot is valid
      if (status == "Accepted" && timeSlot != null && timeSlot.isNotEmpty) {
        try {
          final deleteResponse = await supabase
              .from("available_slots")
              .delete()
              .eq("time_slot", timeSlot);

          print("Slot delete response: $deleteResponse");
        } catch (slotError) {
          print("Slot deletion failed: $slotError");
        }
      }

      // Refresh UI
      await fetchBookings();
      filterBookings();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Booking $status")),
      );
    } catch (e) {
      print("Booking update failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update booking status.")),
      );
    }
  }


  Future<void> _launchUrlSafely(String? url, String title) async {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("URL for $title is not available.")),
      );
      return;
    }

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Cannot launch $title")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error opening $title")),
      );
    }
  }

  Widget buildDocumentTile(String title, String? url) {
    if (url == null || url.isEmpty) return SizedBox.shrink();
    return ListTile(
      title: Text(title),
      trailing: Icon(Icons.open_in_new, color: Colors.blue),
      onTap: () => _launchUrlSafely(url, title),
    );
  }

  Widget buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget buildMedicalCertificateDetails(Map<String, dynamic> cert) {
    String getField(String key) => cert[key]?.toString() ?? 'N/A';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.grey[100],
        elevation: 1.5,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Medical Certificate (Form 4A)",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 8),
              buildField("Sex", getField('sex')),
              buildField("Age", "${getField('age_years')}y"),
              buildField("Cause of Death", getField('cause_of_death')),
              buildField("Other Conditions", getField('other_conditions')),
              buildField("Reason for Other Conditions", getField('other_conditions_reason')),
              if (getField('sex') == 'Female') ...[
                buildField("Was Pregnant", getField('was_pregnancy_reason')),
                buildField("Was Delivery", getField('was_delivery')),
                buildField("Delivery Happened", getField('delivery_happened')),
                buildField("Pregnancy Reason", getField('pregnancy_reason')),
              ],
              buildField("Doctor Name", getField('doctor_name')),
              buildField("Certification Date", formatDate(getField('certification_date'))),
              buildField("Time of Death", "${getField('time_of_death')} ${getField('am_pm')}"),
              buildField("Submitted At", formatDate(getField('submitted_at'))),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Dashboard"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              fetchData();
              searchController.clear(); // Reset search when refreshed
            },
            tooltip: "Refresh",
          )
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search by deceased name or user ID",
                prefixIcon: Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    setState(() {
                      filterBookings();
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  filterBookings();
                });
              },
            ),
          ),
          filteredBookings.isEmpty
              ? Expanded(
            child: Center(child: Text("No matching bookings")),
          )
              : Expanded(
            child: ListView.builder(
              itemCount: filteredBookings.length,
              itemBuilder: (context, index) {
                final booking = filteredBookings[index];
                final formattedSlotTime = booking["slot_time"]
                    ?.toString()
                    .substring(0, 5) ?? "N/A";

                final matchedCert = medicalCerts.firstWhere(
                      (cert) =>
                  cert['name']?.toString().toLowerCase().trim() ==
                      booking['deceased_name']?.toString().toLowerCase().trim(),
                  orElse: () => {},
                );

                return Card(
                  margin: EdgeInsets.all(10),
                  elevation: 3,
                  child: ExpansionTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Name: ${booking['deceased_name']}"),
                        Text("Date: ${booking['select_date']}"),
                        Text("Time: $formattedSlotTime"),
                      ],
                    ),
                    subtitle: Text("Status: ${booking['status']}"),
                    children: [
                      buildMedicalCertificateDetails(matchedCert),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                updateStatus(
                                  booking['id'],
                                  "Accepted",
                                  bookingDate: booking['select_date'],
                                  timeSlot: booking['slot_time'],
                                );
                              },
                              child: Text("Accept"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                updateStatus(
                                  booking['id'],
                                  "Declined",
                                  bookingDate: booking['select_date'],
                                  timeSlot: booking['slot_time'],
                                );
                              },
                              child: Text("Decline"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      buildDocumentTile("Aadhaar Card", booking['aadhaar_url']),
                      buildDocumentTile("Photo of Deceased", booking['photo_url']),
                      buildDocumentTile("Doctor Verification", booking['doctor_verification_url']),
                      buildDocumentTile("Death Certificate", booking['death_certificate_url']),
                      buildDocumentTile("Applicant Aadhaar", booking['applicant_aadhaar_url']),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
