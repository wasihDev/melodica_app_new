import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AffectedClassesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> affectedClasses;
  final String subject;

  const AffectedClassesScreen({
    super.key,
    required this.affectedClasses,
    required this.subject,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Affected Classes"), centerTitle: true),
      body: affectedClasses.isEmpty
          ? const Center(
              child: Text(
                "No affected classes found.",
                style: TextStyle(fontSize: 16),
              ),
            )
          : Column(
              children: [
                const SizedBox(height: 16),

                /// Info message
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "These classes fall outside your freezing allowance. "
                    "Please reschedule each class to avoid session loss.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                ),

                const SizedBox(height: 12),

                /// List
                Expanded(
                  child: ListView.builder(
                    itemCount: affectedClasses.length,
                    itemBuilder: (context, index) {
                      final c = affectedClasses[index];

                      final DateTime classDate = DateTime.parse(
                        c['bookingstart'],
                      );

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.event),

                          /// Date & Time
                          title: Text(
                            DateFormat('EEE, d MMM yyyy').format(classDate),
                          ),
                          subtitle: Text(
                            DateFormat('hh:mm a').format(classDate),
                          ),

                          /// 🔥 Per-class Reschedule button
                          trailing: TextButton(
                            onPressed: () {
                              _openRescheduleCalendar(
                                context,
                                classDate,
                                c['bookingid'],
                              );
                            },
                            child: const Text(
                              "Reschedule",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  /// Open calendar for that specific class
  void _openRescheduleCalendar(
    BuildContext context,
    DateTime classDate,
    String bookingId,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RescheduleCalendarScreen(
          originalDate: classDate,
          bookingId: bookingId,
        ),
      ),
    );
  }
}

class RescheduleCalendarScreen extends StatefulWidget {
  final DateTime originalDate;
  final String bookingId;

  const RescheduleCalendarScreen({
    super.key,
    required this.originalDate,
    required this.bookingId,
  });

  @override
  State<RescheduleCalendarScreen> createState() =>
      _RescheduleCalendarScreenState();
}

class _RescheduleCalendarScreenState extends State<RescheduleCalendarScreen> {
  DateTime? selectedDate;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.originalDate.add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  void _submitReschedule() {
    if (selectedDate == null) return;

    /// TODO: Call your reschedule API here

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Class rescheduled to ${DateFormat('d MMM yyyy').format(selectedDate!)}",
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reschedule Class")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Original Class:", style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 4),
            Text(
              DateFormat('EEE, d MMM yyyy hh:mm a').format(widget.originalDate),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _pickDate,
              child: const Text("Select New Date"),
            ),

            if (selectedDate != null) ...[
              const SizedBox(height: 16),
              Text(
                "New Date: ${DateFormat('d MMM yyyy').format(selectedDate!)}",
              ),
            ],

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: selectedDate == null ? null : _submitReschedule,
                child: const Text("Confirm Reschedule"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
