import 'package:flutter/material.dart';
import 'package:cremation_app/widgets/custom_appbar.dart';
import 'package:cremation_app/theme/app_theme.dart';

class BookingStatusScreen extends StatelessWidget {
  final String selectDate;
  final String selectedSlot;

  BookingStatusScreen({
    required this.selectDate,
    required this.selectedSlot,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: CustomAppBar(
        title: const Text("Booking Status"),
      ),
      body: SingleChildScrollView( // Wrap the body in a SingleChildScrollView
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.check_circle_outline, size: 90, color: AppColors.primary),
            const SizedBox(height: 24),

            Text(
              "Slot Booked Successfully!",
              style: theme.textTheme.headlineMedium?.copyWith(
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 28),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Scheduled Date: ${selectDate.isNotEmpty ? selectDate : 'Unknown'}",
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Scheduled Time: ${selectedSlot.isNotEmpty ? selectedSlot : 'Unknown'}",
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Instructions Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Important Instructions:",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "1. Please arrive at the crematorium at least 10 minutes before your scheduled slot.",
                    style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "2. You can collect the ashes 1 hour after the cremation process is complete.",
                    style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "3. Payment must be made in cash at the crematorium.",
                    style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "4. Any rituals you wish to perform can be done before the cremation process.",
                    style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black87),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Status Section
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.hourglass_empty, color: Colors.orange, size: 28),
                const SizedBox(width: 10),
                Text(
                  "Waiting for Confirmation...",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Contact Info Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Need More Information?",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Phone: 9786960063",
                    style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Email: abcd@gmail.com",
                    style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black87),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.dashboard),
              label: const Text("Back to Dashboard"),
            ),
          ],
        ),
      ),
    );
  }
}
