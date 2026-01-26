import 'package:flutter/material.dart';
import 'package:melodica_app_new/providers/auth_provider.dart';
import 'package:melodica_app_new/providers/student_provider.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';
import 'package:provider/provider.dart';

// --- 1. Models and Services (Mock) ---

/// Represents the body for the 'upsert profile' API call.
class DeleteAccountRequest {
  String type;
  String reason;
  String note;
  bool existing;
  // Add other fields like clientid, firstname, etc. as needed.
  // For this example, we'll just use placeholders.

  DeleteAccountRequest({
    required this.type,
    required this.reason,
    required this.note,
    this.existing = true,
  });

  Map<String, dynamic> toJson() {
    return {
      "firstname": "John", // Placeholder
      "lastname": "Doe", // Placeholder
      "email": "john.doe@example.com", // Placeholder
      "clientid": "12345", // Placeholder
      "type": type,
      "reason": reason,
      "note": note,
      "existing": existing,
      // ... add other fields as per your API spec
    };
  }
}

// --- 2. Main App & Screen ---

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  // State variables
  String? _selectedReason;
  final _noteController = TextEditingController();
  // final _apiService = ApiService();
  bool _isLoading = false;

  // List of reasons for the radio buttons
  final List<String> _reasons = [
    "No Longer need this app",
    "Privacy Concerns",
    "App is hard to use",
    "Too many notifications",
    "Other",
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  /// Handles the main delete action.
  Future<void> _handleDeleteAccount() async {
    // Close the confirmation dialog
    Navigator.of(context).pop();

    setState(() {
      _isLoading = true;
    });

    try {
      // Call the API
      final ctrl = context.read<CustomerController>();

      await ctrl
          .upsertStudentProfileDelete(
            context,
            firstname: ctrl.customer!.firstName,
            lastname: ctrl.customer!.lastName,
            email: ctrl.customer!.email,
            phone: '',
            countryCode: "971",
            areaCode: "52",
            level: "Beginner", // Beginner
            existing: true, // 👈 NEW STUDENT
            reason: _selectedReason,
            clientId: ctrl.selectedStudent!.mbId.toString(),
            type: "Delete",
            note: _noteController.text,
          )
          .then((val) {
            if (mounted) {
              _showSuccessDialog();
            }
          });

      // if (success) {
      // } else {
      //   // Handle API failure
      //   _showErrorSnackBar("Failed to delete account. Please try again.");
      // }
    } catch (e) {
      print("An error occurred: $e");
      // _showErrorSnackBar("An error occurred: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Shows the red confirmation dialog.
  void _showConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // User must choose an option
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Column(
            children: [
              Icon(Icons.error_outline, color: Colors.redAccent, size: 60),
              SizedBox(height: 16),
            ],
          ),
          content: const Text(
            "Are you sure want to Permanently Delete your Profile?",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              child: const Text("No"),
            ),
            ElevatedButton(
              onPressed: _handleDeleteAccount,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text("Yes"),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Shows the green success dialog.
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,

      builder: (BuildContext context) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.center,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: [
              Container(
                height: 45.h,
                width: 45.w,
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFF47C97E), width: 4),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.check,
                    size: 30.adaptSize,
                    color: Color(0xFF47C97E),
                  ),
                ),
              ),
              SizedBox(height: 16.fSize),
              Text(
                "Request Received",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            "Your account deletion request has been received.\n\n"
            "Our team is processing your request. This may take some time to complete.\n"
            "You will be notified once your account has been permanently deleted.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          actions: [
            Consumer<AuthProviders>(
              builder: (context, proovider, child) {
                return SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () async {
                      await proovider.logout(context);
                    },
                    child: const Text(
                      "OK",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Delete Account",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      // Show a loading indicator while the API is being called
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Why are you deleting your account?",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Radio buttons for reasons
                    ..._reasons.map(
                      (reason) => RadioListTile<String>(
                        title: Text(reason),
                        value: reason,
                        groupValue: _selectedReason,
                        activeColor: Colors.redAccent,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (value) {
                          setState(() {
                            _selectedReason = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Optional text field for additional notes
                    TextField(
                      controller: _noteController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "Explain reason (Optional)",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Delete Account Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        // Button is disabled if no reason is selected
                        onPressed: _selectedReason == null
                            ? null
                            : _showConfirmationDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFFFFD152,
                          ), // Yellow color from image
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          // Style for disabled state
                          disabledBackgroundColor: Colors.grey[300],
                          disabledForegroundColor: Colors.grey[600],
                        ),
                        child: const Text(
                          "Delete Account",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
