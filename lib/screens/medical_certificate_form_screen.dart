import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_dashboard.dart';
import 'package:cremation_app/theme/app_theme.dart';
import 'package:intl/intl.dart';


class MedicalCertificateFormScreen extends StatefulWidget {
  @override
  _MedicalCertificateFormScreenState createState() =>
      _MedicalCertificateFormScreenState();
}

class _MedicalCertificateFormScreenState
    extends State<MedicalCertificateFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;

  final _nameController = TextEditingController();
  final _ageYearsController = TextEditingController();
  final _doctorNameController = TextEditingController();
  final _certificationDateController = TextEditingController();
  final _timeOfDeathController = TextEditingController();
  final _pregnancyReasonController = TextEditingController();
  final _otherConditionsReasonController = TextEditingController();

  String? _selectedSex, _selectedTimeFormat;
  bool? _wasPregnancyReason, _wasDelivery, _deliveryHappened;
  String? _selectedCauseOfDeath;

  @override
  void dispose() {
    _nameController.dispose();
    _ageYearsController.dispose();
    _doctorNameController.dispose();
    _certificationDateController.dispose();
    _timeOfDeathController.dispose();
    _pregnancyReasonController.dispose();
    _otherConditionsReasonController.dispose();
    super.dispose();
  }

  Future<void> submitToSupabase() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception("User not logged in.");
      print("User authenticated: ${user.id}");

      if (_formKey.currentState?.validate() ?? false) {
        String? causeOfDeath = _selectedCauseOfDeath;
        String? otherConditionReason = _otherConditionsReasonController.text.trim();

        if (causeOfDeath == "Other Conditions") {
          if (otherConditionReason.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please enter reason for Other Conditions.')),
            );
            return;
          }
        } else {
          otherConditionReason = null;
        }

        final data = {
          'user_id': user.id,
          'name': _nameController.text.trim(),
          'sex': _selectedSex,
          'age_years': int.tryParse(_ageYearsController.text.trim()) ?? 0,
          'cause_of_death': causeOfDeath,
          'other_conditions_reason': otherConditionReason,
          'doctor_name': _doctorNameController.text.trim(),
          'certification_date': _certificationDateController.text.trim(),
          'time_of_death': _timeOfDeathController.text.trim(),
          'am_pm': _selectedTimeFormat,
          'submitted_at': DateTime.now().toIso8601String(),
          'was_pregnancy_reason': _wasPregnancyReason,
          'was_delivery': _wasDelivery,
          'delivery_happened': _deliveryHappened,
          'pregnancy_reason': _pregnancyReasonController.text.trim().isEmpty
              ? null
              : _pregnancyReasonController.text.trim(),
        };

        // Log to check if data is ready for submission
        print("Data ready for insertion: $data");

        final response = await supabase.from('medical_certificates').insert(data);

        if (response == null || response.error != null) {
          print('Response error: ${response?.error?.message}');
          throw Exception('Failed to submit: ${response?.error?.message ?? 'Unknown error'}');
        }

        print("Submission successful!");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Form 4A submitted successfully!')),
        );
        _showSubmissionDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill out all required fields.')),
        );
      }
    } catch (e) {
      print("Error during submission: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'))

    );
    }
  }

  void _showSubmissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          AlertDialog(
            title: Text("Submitted"),
            content: Text("Form 4A submitted successfully. Redirecting..."),
          ),
    );
    Timer(Duration(seconds: 3), () {
      Navigator.pop(context);
      Navigator.pushReplacement(
          context, MaterialPageRoute(
          builder: (_) => UserDashboard(enableBooking: true)));
    });
  }

  // Show Instructions Dialog
  void _showInstructionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Instructions"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Instructions for Medical Certificate of Cause of Death (Form No. 4A):",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '''
• Name of deceased: Write in full. For infant, use “son/daughter of” and age.
• Age: Give exact age (in completed years/months/days). For infants below 1 year, give in days/months.
• Cause of Death: Fill Part I (immediate and underlying causes) and Part II (contributing conditions).
• Do not mention only mode of dying like “cardiac arrest”, “shock”, or “respiratory failure”.
• Sequence the causes correctly, with the underlying cause at the bottom of Part I.
• Mention method of injury if external cause involved (e.g., fall, poisoning, etc.).
• Do not use vague terms or modes of death as the only cause.
• Onset: Mention interval from onset to death (e.g., "3 days", "2 years").
• Accidental/violent deaths: Mention both cause and nature of injury.
• Maternal deaths: Note if pregnancy contributed.
• Old age or senility is not accepted unless a specific cause is unknown after investigation.
• Completeness: All sections should be filled. Write “Not known” if data is missing.
• Symptomatic terms (e.g., convulsions, diarrhea) should be avoided unless no better info is available.
              ''',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Form 4A - Medical Certificate"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () => _showInstructionsDialog(context),

          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildSection("Personal Details", [
                _buildTextField("Name of Deceased", _nameController),
                _buildDropdown(
                    "Sex", ["Male", "Female", "Transgender"], _selectedSex,
                        (val) => setState(() => _selectedSex = val)),
                _buildTextField(
                    "Age (Years)", _ageYearsController, isNumber: true),
              ]),
              _buildSection("Cause of Death", [
                _buildRadioGroup(
                    "Immediate Cause", _selectedCauseOfDeath, (val) =>
                    setState(() => _selectedCauseOfDeath = val)),
                _buildRadioGroup(
                    "Consequence Cause", _selectedCauseOfDeath, (val) =>
                    setState(() => _selectedCauseOfDeath = val)),
                _buildRadioGroup(
                    "Antecedent Cause", _selectedCauseOfDeath, (val) =>
                    setState(() => _selectedCauseOfDeath = val)),
                _buildRadioGroup(
                    "Morbid Conditions", _selectedCauseOfDeath, (val) =>
                    setState(() => _selectedCauseOfDeath = val)),
                _buildRadioGroup(
                    "Other Conditions", _selectedCauseOfDeath, (val) =>
                    setState(() => _selectedCauseOfDeath = val)),
                _buildTextField("Other Conditions Reason",
                    _otherConditionsReasonController),
              ]),
              if (_selectedSex == "Female")
                _buildSection("Pregnancy & Delivery", [
                  _buildYesNo(
                      "Was pregnancy the reason?", _wasPregnancyReason, (val) {
                    setState(() {
                      _wasPregnancyReason = val;
                      if (val != null && !val) {
                        _wasDelivery = null;
                        _deliveryHappened = null;
                      }
                    });
                  }),
                  if (_wasPregnancyReason == true)
                    _buildYesNo("Was there a delivery?", _wasDelivery,
                            (val) => setState(() => _wasDelivery = val)),
                  _buildYesNo("Did delivery happen?", _deliveryHappened,
                          (val) => setState(() => _deliveryHappened = val)),
                  _buildTextField(
                      "Pregnancy Reason (optional)", _pregnancyReasonController,
                      isOptional: true),
                ]),
              _buildSection("Doctor Certification", [
                _buildTextField("Doctor Name ", _doctorNameController),
                _buildTextField(
                    "Date of Certification", _certificationDateController),
                Row(
                  children: [
                    Expanded(child: _buildTextField(
                        "Time of Death", _timeOfDeathController)),
                    SizedBox(width: 8),
                    Expanded(child: _buildDropdown(
                        "AM/PM", ["AM", "PM"], _selectedTimeFormat,
                            (val) =>
                            setState(() => _selectedTimeFormat = val))),
                  ],
                ),
              ]),
              SizedBox(height: 24),
              ElevatedButton.icon(
                icon: Icon(Icons.check_circle_outline),
                label: Text("Submit Form"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  textStyle: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: submitToSupabase,
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent)),
          SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRadioGroup(String label, String? groupValue,
      Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: GestureDetector(
        onTap: () => onChanged(groupValue == null ? label : null),
        child: Row(
          children: [
            Radio<String>(
                value: label, groupValue: groupValue, onChanged: onChanged),
            Text(label),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isNumber = false, bool isOptional = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (val) =>
        !isOptional && val!.isEmpty
            ? 'This field is required'
            : null,
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> options, String? value,
      Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: onChanged,
        items: options
            .map((option) =>
            DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            ))
            .toList(),
        validator: (val) => val == null ? 'This field is required' : null,
      ),
    );
  }

  Widget _buildYesNo(String label, bool? value, Function(bool?) onChanged) {
    return Row(
      children: [
        Text(label),
        SizedBox(width: 12),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Radio<bool>(value: true, groupValue: value, onChanged: onChanged),
              Text('Yes'),
              SizedBox(width: 12),
              Radio<bool>(
                  value: false, groupValue: value, onChanged: onChanged),
              Text('No'),
            ],
          ),
        ),
      ],
    );
  }
}
