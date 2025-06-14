import 'package:intl/intl.dart';

class TimeHelper {
  static String convertTo24Hour(String time) {
    print("🔍 Received time for conversion: $time");

    try {
      // ✅ If time is already in 24-hour format, return it
      if (RegExp(r'^\d{2}:\d{2}(:\d{2})?$').hasMatch(time)) {
        print("✅ Already in correct format: $time");
        return time;
      }

      // Otherwise, convert "hh:mm a" → "HH:mm:ss"
      final inputFormat = DateFormat("hh:mm a");
      final outputFormat = DateFormat("HH:mm:ss");

      String formattedTime = outputFormat.format(inputFormat.parse(time));

      print("✅ Converted to 24-hour format: $formattedTime");
      return formattedTime;
    } catch (e) {
      print("❌ Time Format Error: $e");
      return time; // Return original value if parsing fails
    }
  }
}
