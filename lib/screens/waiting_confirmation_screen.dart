import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cremation_app/screens/login_screen.dart';
import 'package:cremation_app/widgets/custom_appbar.dart';
import 'package:cremation_app/theme/app_theme.dart';

class WaitingConfirmationScreen extends StatelessWidget {
  final Map<String, dynamic> bookingData;

  WaitingConfirmationScreen({required this.bookingData});

  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    String status = bookingData['status'] ?? 'Pending';
    String deceasedName = bookingData['deceased_name'] ?? 'N/A';
    String slotDate = bookingData['date'] ?? 'N/A';
    String slotTime = bookingData['slot_time'] ?? 'N/A';
    String? bookingId = bookingData['booking_id'];

    // Status Message
    String message;
    IconData icon;
    Color iconColor;

    if (status == 'Accepted') {
      message = 'Your cremation slot has been confirmed.';
      icon = Icons.check_circle_outline;
      iconColor = Colors.green.shade600;
    } else if (status == 'Declined') {
      message = 'Unfortunately, your booking was declined.';
      icon = Icons.cancel_outlined;
      iconColor = Colors.red.shade400;
    } else {
      message = 'Waiting for confirmation from admin.';
      icon = Icons.hourglass_top;
      iconColor = AppColors.accent;
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: const Text('Booking Status'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                await supabase.auth.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                      (route) => false,
                );
              }
            },
            itemBuilder: (BuildContext context) {
              final userEmail = supabase.auth.currentUser?.email ?? 'User';
              return [
                PopupMenuItem<String>(
                  value: 'username',
                  child: Text(userEmail),
                ),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Text('Logout'),
                ),
              ];
            },
            icon: const Icon(Icons.account_circle),
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: AppColors.card,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 64, color: iconColor),
                  const SizedBox(height: 20),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: iconColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Divider(color: AppColors.secondary),
                  const SizedBox(height: 16),
                  _buildInfoRow('Deceased Name', deceasedName),
                  _buildInfoRow('Slot Date', slotDate),
                  _buildInfoRow('Slot Time', slotTime),
                  if (bookingId != null) ...[
                    _buildInfoRow('Booking ID', bookingId),
                    const SizedBox(height: 42),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.softBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '➤ Please arrive at the crematorium at least 10 minutes early.\n\n'
                            '➤ Carry original documents uploaded for verification.\n\n'
                            '➤ A helper will assist you on-site.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
