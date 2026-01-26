import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:melodica_app_new/constants/app_colors.dart';
import 'package:melodica_app_new/models/schedule_model.dart';
import 'package:melodica_app_new/providers/pacakge_provider.dart';
import 'package:melodica_app_new/providers/schedule_provider.dart';
import 'package:melodica_app_new/providers/services_provider.dart';
import 'package:melodica_app_new/routes/routes.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';
import 'package:melodica_app_new/views/dashboard/schedule/checkout_screen_reschedule.dart';
import 'package:melodica_app_new/views/dashboard/schedule/serivices.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ScheduleModels {
  late final String PackageExpiry;
  late final String bookingDateStartTime;
  late final int RemainingCancellations;

  DateTime get packageExpiryDate => DateTime.parse(PackageExpiry);

  DateTime get originalClassDate => DateTime.parse(bookingDateStartTime);

  bool get hasCancellations => RemainingCancellations > 0;
}

// ignore: must_be_immutable
class RescheduleScreen extends StatefulWidget {
  ScheduleModel s;
  RescheduleScreen({required this.s});
  @override
  _RescheduleScreenState createState() => _RescheduleScreenState();
}

class _RescheduleScreenState extends State<RescheduleScreen> {
  DateTime _selectedDate = DateTime.now();
  AvailabilitySlot? _selectedSlot;
  List<AvailabilitySlot> _slots = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchSlots();
  }

  // void _fetchSlots() async {
  //   setState(() => _isLoading = true);
  //   try {
  //     List<String> parts = widget.s.Pricing.split(' - ');
  //     String lastPart = parts.last;
  //     String duration = lastPart.split(' ').first;
  //     // 1️⃣ Get slots from API (already List<AvailabilitySlot>)
  //     final List<AvailabilitySlot> responseSlots = await RescheduleService()
  //         .getAvailability(
  //           DateFormat('yyyy-MM-dd').format(_selectedDate),
  //           widget.s.bookingResourceId,
  //           int.parse(duration),
  //         );
  //     final now = DateTime.now();
  //     // 2️⃣ Process slots: parse start/end time and mark ongoing
  //     final slots = responseSlots
  //         .map((slot) {
  //           // Parse start & end times
  //           final times = slot.slotsRange.split(' - ');
  //           final startParts = times[0].split(':');
  //           final endParts = times[1].split(':');
  //           final today = DateTime(now.year, now.month, now.day);
  //           slot.startTime = DateTime(
  //             today.year,
  //             today.month,
  //             today.day,
  //             int.parse(startParts[0]),
  //             int.parse(startParts[1]),
  //           );
  //           slot.endTime = DateTime(
  //             today.year,
  //             today.month,
  //             today.day,
  //             int.parse(endParts[0]),
  //             int.parse(endParts[1]),
  //           );
  //           // Mark ongoing
  //           slot.isOngoing =
  //               now.isAfter(slot.startTime) && now.isBefore(slot.endTime);
  //           return slot;
  //         })
  //         // Remove slots that are already ended
  //         .where((slot) => now.isBefore(slot.endTime))
  //         .toList();
  //     setState(() => _slots = slots);
  //   } finally {
  //     setState(() => _isLoading = false);
  //   }
  // }

  // late update
  void _fetchSlots() async {
    setState(() => _isLoading = true);
    try {
      List<String> parts = widget.s.Pricing.split(' - ');

      // 2. Get the last part ("30 Mins")
      String lastPart = parts.last;

      // 3. Split the last part by space and take the first element
      String duration = lastPart.split(' ').first;

      print('duration'); // Output: 30
      final slots = await RescheduleService().getAvailability(
        // "2026-01-07",
        // DateFormat("yyyy-MM-dd").format(
        //   DateFormat("dd/MM/yyyy hh:mm a").parse(widget.s.bookingDateStartTime),
        // ),
        DateFormat('yyyy-MM-dd').format(_selectedDate),
        widget.s.bookingResourceId,
        duration.toInt(),
      );
      print('slots $slots');
      setState(() => _slots = slots);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String getWarningNote({
    required DateTime selectedDate,
    required DateTime originalClassDate,
    required DateTime packageExpiryDate,
    required bool hasCancellations,
  }) {
    if (selectedDate.isBefore(originalClassDate) ||
        selectedDate.isAtSameMomentAs(originalClassDate)) {
      // Taking class in advance → No note
      return "";
    } else if (selectedDate.isAfter(originalClassDate) &&
        selectedDate.isBefore(packageExpiryDate)) {
      // Between original class date and package expiry
      if (hasCancellations) {
        return "Note:\nMoving this booking past its original booking date will consume one of your cancellations, consider taking it earlier if possible.";
      } else {
        return "Note:\nMoving this booking past its original booking date requires a cancellation, select to purchase a recovery or consider taking the class in advance.";
      }
    } else if (selectedDate.isAfter(packageExpiryDate) &&
        selectedDate.isBefore(packageExpiryDate.add(Duration(days: 7)))) {
      // Between package expiry and 1 week after expiry
      return "Note:\nThis is past your package expiry, booking these timings may result in using your extension or paying for an extension.";
    } else {
      return "";
    }
  }

  void _executeScheduleRequest(
    BuildContext context,
    ScheduleProvider provider,
  ) {
    final classDateTime = formatToApiDate(_selectedDate);
    final Packageprovider = Provider.of<PackageProvider>(
      context,
      listen: false,
    );
    final pro = Packageprovider.packages.firstWhere(
      (n) => n.paymentRef == widget.s.PackageCode.toString(),
    );

    provider
        .submitScheduleRequest(
          subject: widget.s.subject,
          classDateTime: classDateTime,
          action: "Rebook",
          preferredSlot: _selectedSlot!.slotsRange,
          reason: "",
          branch: "${pro.branch}",
          packageid: '${pro.paymentRef}',
        )
        .then((val) {
          showSuccessDialog(context);
        });
  }

  @override
  Widget build(BuildContext context) {
    // 2. Warning Note
    print('widget.s.PackageExpiry ${widget.s.PackageExpiry}');
    print('widget.s.bookingDateStartTime ${widget.s.bookingDateStartTime}');
    final packageExpiryDate = DateFormat(
      "yyyy-MM-dd'T'HH:mm:ss",
    ).parse(widget.s.PackageExpiry);

    // Parse bookingDateStartTime (custom format with AM/PM)
    final originalClassDate = DateFormat(
      "dd/MM/yyyy hh:mm a",
    ).parse(widget.s.bookingDateStartTime);

    final warningNote = getWarningNote(
      selectedDate: _selectedDate,
      originalClassDate: originalClassDate,
      packageExpiryDate: packageExpiryDate,
      hasCancellations: widget.s.RemainingCancellations > 0,
    );
    // final sche = Provider.of<ScheduleProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Reschedule"),
        // leading: Icon(Icons.arrow_back_ios),
      ),
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            // 1. Weekly Date Picker (As per design)
            CustomWeeklyDatePicker(
              initialDate: _selectedDate,
              onDateSelected: (date) {
                setState(() => _selectedDate = date);
                _fetchSlots();
              },
            ),

            // 2. Warning Note
            if (warningNote.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFF7EC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    warningNote,
                    //  "This is past your package expiry, booking these timings may result in using your extension or paying for an extension",
                    style: TextStyle(color: Colors.orange[800], fontSize: 13),
                  ),
                ),
              ),
            SizedBox(height: 10),
            // Text('_slots.length ${_slots.length}'),
            // 3. Slots Grid
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      shrinkWrap: true,
                      itemCount: _slots.length,
                      itemBuilder: (context, index) {
                        final slot = _slots[index];
                        final isSelected = _selectedSlot == slot;

                        return GestureDetector(
                          onTap: () => setState(() => _selectedSlot = slot),
                          child: Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.only(bottom: 5),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected
                                    ? Colors.orange
                                    : Colors.grey[300]!,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              color: isSelected
                                  ? Color(0xFFFFF7EC)
                                  : Colors.white,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  slot.slotsRange,
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),

                                // if (isSelectedDateToday && slot.isOngoing)
                                //   Container(
                                //     padding: EdgeInsets.symmetric(
                                //       horizontal: 6,
                                //       vertical: 2,
                                //     ),
                                //     decoration: BoxDecoration(
                                //       color: Colors.red.withOpacity(0.1),
                                //       borderRadius: BorderRadius.circular(4),
                                //     ),
                                //     child: const Text(
                                //       "On Going",
                                //       style: TextStyle(
                                //         fontSize: 10,
                                //         color: Colors.red,
                                //       ),
                                //     ),
                                //   ),
                                // if (!slot.isOngoing)
                                Icon(Icons.alarm),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            // 4. Action Buttons (Footer)
            Consumer2<ScheduleProvider, ServicesProvider>(
              builder: (context, provider, checkout, child) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFFD152),
                          ),
                          onPressed: _selectedSlot == null
                              ? null
                              : () {
                                  final Packageprovider =
                                      Provider.of<PackageProvider>(
                                        context,
                                        listen: false,
                                      );
                                  final pro = Packageprovider.packages
                                      .firstWhere(
                                        (n) =>
                                            n.paymentRef ==
                                            widget.s.PackageCode.toString(),
                                      );

                                  /// pass this over terortory id

                                  // 1. Parse the bookingDateStartTime date from your widget data
                                  final DateTime bookingdata = DateFormat(
                                    'dd/MM/yyyy hh:mm a',
                                  ).parse(widget.s.bookingDateStartTime);
                                  // Current datetime
                                  final DateTime now = DateTime.now();
                                  final DateTime today = DateTime(
                                    now.year,
                                    now.month,
                                    now.day,
                                  );
                                  final DateTime scheduledDay = DateTime(
                                    bookingdata.year,
                                    bookingdata.month,
                                    bookingdata.day,
                                  );
                                  print('NOW =====>>> $now');
                                  print('SCHEDULED =====>>> $bookingdata');

                                  // Show late notice if now is equal OR after scheduled time
                                  if (today == scheduledDay) {
                                    showLateNoticeDialog(context);
                                    return;
                                  }
                                  // i want to check if current datetime is equals to schedule pacakage date. then show the late notice popup

                                  final DateTime packageExpiryDate =
                                      DateTime.parse(widget.s.PackageExpiry);
                                  final selectedDay = DateTime(
                                    _selectedDate.year,
                                    _selectedDate.month,
                                    _selectedDate.day,
                                  );

                                  final expiryDay = DateTime(
                                    packageExpiryDate.year,
                                    packageExpiryDate.month,
                                    packageExpiryDate.day,
                                  );
                                  print('selectedDay= =====>>> ${selectedDay}');
                                  print('expiryDay  =====>>>$expiryDay');

                                  if (selectedDay.isAtSameMomentAs(expiryDay) ||
                                      selectedDay.isAfter(expiryDay)) {
                                    print('yesss');

                                    // return;
                                    if (pro.remainingExtension != 0) {
                                      // show consume extension dialog
                                      // if extension is available
                                      _showConsumePopup(
                                        context,
                                        onConfirm: () {
                                          _executeScheduleRequest(
                                            context,
                                            provider,
                                          );
                                        },
                                      );
                                      return;
                                    } else {
                                      // show paying for an extension to move it
                                      _showNotEnoughExtensionPopup(context);
                                      return;
                                    }
                                  }

                                  final DateTime bookingay = DateTime(
                                    bookingdata.year,
                                    bookingdata.month,
                                    bookingdata.day,
                                  );
                                  print('selectedDay ===>> ${selectedDay}');
                                  print('bookingdata ===>> ${bookingay}');
                                  print(
                                    'is check ${selectedDay.isAfter(bookingay)}',
                                  );
                                  if (selectedDay.isAfter(bookingay)) {
                                    _showConsumeCancellationDialog(
                                      context,
                                      onConfirm: () {
                                        // Proceed with scheduling after user clicks "Yes" in the popup
                                        _executeScheduleRequest(
                                          context,
                                          provider,
                                        );
                                      },
                                    );
                                    return;
                                  }
                                  ////////
                                  final classDateTime = formatToApiDate(
                                    _selectedDate,
                                  );
                                  final slotRange = _selectedSlot!.slotsRange;
                                  final selectedDate = _selectedDate;

                                  /// 🚫 Expired slot check
                                  if (isExpiredSlot(
                                    selectedDate: selectedDate,
                                    slotRange: slotRange,
                                  )) {
                                    _showConsumeExtensionDialog(
                                      context,
                                      onConfirm: () async {
                                        await provider
                                            .submitScheduleRequest(
                                              subject: widget.s.subject,
                                              classDateTime: classDateTime,
                                              action: "Rebook",
                                              preferredSlot:
                                                  _selectedSlot!.slotsRange,
                                              reason: "",
                                              branch: '${pro.branch}',
                                              packageid: '${pro.paymentRef}',
                                            )
                                            .then((val) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      CheckoutScreenReschedule(),
                                                ),
                                              );
                                            });
                                      },
                                    );
                                    return;
                                  }

                                  print('classDateTime ${classDateTime}');
                                  _executeScheduleRequest(context, provider);
                                },
                          child: provider.isLoading
                              ? CircularProgressIndicator(color: Colors.black)
                              : Text(
                                  "Schedule Now",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Consumer<ScheduleProvider>(
                        builder: (context, provider, child) {
                          return SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton(
                              onPressed: () {
                                final classDateTime = formatToApiDate(
                                  _selectedDate,
                                );
                                final Packageprovider =
                                    Provider.of<PackageProvider>(
                                      context,
                                      listen: false,
                                    );

                                final DateTime bookingdata = DateFormat(
                                  'dd/MM/yyyy hh:mm a',
                                ).parse(widget.s.bookingDateStartTime);
                                // Current datetime
                                final DateTime now = DateTime.now();
                                final DateTime today = DateTime(
                                  now.year,
                                  now.month,
                                  now.day,
                                );
                                final DateTime scheduledDay = DateTime(
                                  bookingdata.year,
                                  bookingdata.month,
                                  bookingdata.day,
                                );
                                print('NOW =====>>> $now');
                                print('SCHEDULED =====>>> $bookingdata');

                                // Show late notice if now is equal OR after scheduled time
                                if (today == scheduledDay) {
                                  showLateNoticeDialog(context);
                                  return;
                                }
                                // print('Packageprovider.packages ${}')
                                final pro = Packageprovider.packages.firstWhere(
                                  (n) =>
                                      n.paymentRef ==
                                      widget.s.PackageCode.toString(),
                                );

                                /// pass this over terortory id
                                print('dataValue =====>>> ${pro.branch}');

                                _showConsumeCancellationDialog(
                                  context,
                                  onConfirm: () async {
                                    await provider
                                        .submitScheduleRequest(
                                          subject: widget.s.subject,
                                          classDateTime: classDateTime,
                                          action: 'Unbooked',
                                          preferredSlot: "",
                                          reason: '',
                                          branch: '${pro.branch}',
                                          packageid: '${pro.paymentRef}',
                                        )
                                        .then((val) {
                                          if (val == true) {
                                            showSuccessDialog(context);
                                          }
                                        });
                                  },
                                );
                                // provider
                                //     .submitScheduleRequest(
                                //       subject: widget.s.subject,
                                //       classDateTime: classDateTime,
                                //       action: 'Unbooked',
                                //       preferredSlot: "",
                                //       reason: '', branch: '',
                                //     )
                                //     .then((val) {
                                // if (val == true) {
                                //   showSuccessDialog(context);
                                // }
                                //     });
                              },
                              child: Text(
                                "Schedule Later",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // popup for late notice
  void showLateNoticeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Orange Warning Icon
            const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFF27E2B), // Matches the orange in your screenshot
              size: 80,
            ),
            const SizedBox(height: 16),

            // Main Text Content
            const Text(
              "Late notice! This will consume cancellation.\nConsider paying recovery fee to book.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.4,
                color: Color(0xFF4A4A4A),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                // "No, thanks" Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "No, thanks",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // "AED 50" Payment Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final servicesProvider = Provider.of<ServicesProvider>(
                        context,
                        listen: false,
                      );
                      servicesProvider.setPaymentType(
                        PaymentType.freezingPoints,
                      );
                      final vat = 50 * 0.05;
                      final amountWithVat = (50 + vat).toInt();

                      final success = await servicesProvider.startCheckout(
                        context,
                        amount: amountWithVat,
                        redirectUrl: "https://melodica-mobile.web.app",
                      );

                      if (success && servicesProvider.paymentUrl != null) {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                        await launchUrl(
                          Uri.parse(servicesProvider.paymentUrl!),
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF27E2B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "AED ${50 * 1.05}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // for  extension or consume extension
  Future<bool> _showConsumePopup(
    BuildContext context, {
    required VoidCallback onConfirm,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: Colors.white,
            title: Icon(Icons.warning, color: Colors.orange, size: 40),
            content: Text(
              "You're about to consume your Extension.\nWould like to proceed?",
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text("No"),
              ),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  onConfirm();
                },
                child: Container(
                  height: 50,
                  width: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      "Yes",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  // Pay Extension
  void _showNotEnoughExtensionPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        actionsPadding: EdgeInsets.only(bottom: 20, right: 10),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        backgroundColor: Colors.white,
        title: Icon(Icons.warning, color: Colors.orange, size: 40),
        content: Text(
          "No Extension!\nConsider paying for an extension to move it\nhere?",
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "No, thanks",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          InkWell(
            onTap: () async {
              final servicesProvider = Provider.of<ServicesProvider>(
                context,
                listen: false,
              );
              servicesProvider.setPaymentType(PaymentType.freezingPoints);
              final vat = 50 * 0.05;
              final amountWithVat = (50 + vat).toInt();

              final success = await servicesProvider.startCheckout(
                context,
                amount: amountWithVat,
                redirectUrl: "https://melodica-mobile.web.app",
              );

              if (success && servicesProvider.paymentUrl != null) {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
                await launchUrl(
                  Uri.parse(servicesProvider.paymentUrl!),
                  mode: LaunchMode.externalApplication,
                );
              }
              // servicesProvider.startCheckout(amount:extraCharge, redirectUrl: '' )
            },
            child: Container(
              height: 50,
              width: 120,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  "AED ${50 * 1.05}",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //
  // Success dialog
  void showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Stack(
              children: [
                // Close Button (Top Right)
                // Positioned(
                //   right: 0,
                //   top: 0,
                //   child: GestureDetector(
                //     onTap: () => Navigator.pop(context),
                //     child: Container(
                //       padding: const EdgeInsets.all(4),
                //       decoration: const BoxDecoration(
                //         color: Color(0xFF4A4A4A), // Dark grey background
                //         shape: BoxShape.circle,
                //       ),
                //       child: const Icon(
                //         Icons.close,
                //         size: 16,
                //         color: Colors.white,
                //       ),
                //     ),
                //   ),
                // ),

                // Main Content
                Column(
                  mainAxisSize: MainAxisSize.min, // Wrap content height
                  children: [
                    const SizedBox(height: 10),

                    // Green Checkmark Icon
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
                    SizedBox(height: 20.h),

                    Text(
                      "Your request has been submitted.", // Fixed grammar from screenshot
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.adaptSize,
                        color: Color(0xff636363),
                      ),
                    ),
                    Text(
                      "Our team will get back to you",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.adaptSize,
                        color: Color(0xff636363),
                      ),
                    ),
                    SizedBox(height: 15.h),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                          // AppColors.primary,
                          Color(0xFF47C97E),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Okay',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool isExpiredSlot({
    required DateTime selectedDate,
    required String slotRange,
  }) {
    final now = DateTime.now();

    // Only validate if selected date is TODAY
    final isToday =
        selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;

    if (!isToday) return false;

    final slotStart = parseSlotStartTime(selectedDate, slotRange);

    return slotStart.isBefore(now);
  }

  DateTime parseSlotStartTime(DateTime selectedDate, String slotRange) {
    final startTimeStr = slotRange.split('-').first.trim(); // "17:45"

    final time = DateFormat('HH:mm').parse(startTimeStr);

    return DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      time.hour,
      time.minute,
    );
  }

  void _showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  bool isAfterExpiry(DateTime selectedDate, DateTime expiryDate) {
    return selectedDate.isAfter(expiryDate);
  }

  String formatToApiDate(DateTime date) {
    return date.toUtc().toIso8601String().split('.').first + 'Z';
  }

  // Dialog triggered by 'Schedule Now'
  void _showConsumeExtensionDialog(
    BuildContext context, {
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Icon(Icons.info_rounded, size: 70, color: Color(0xffFE7501)),
        content: const Text(
          "No Extensions! Consider paying for an extension to move it here?",
        ),
        actions: [
          TextButton(
            style: ButtonStyle(
              padding: MaterialStateProperty.all<EdgeInsets>(
                EdgeInsets.all(15),
              ),
              foregroundColor: MaterialStateProperty.all<Color>(Colors.red),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  side: BorderSide(color: Colors.red),
                ),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text("No, thanks"),
          ),
          ElevatedButton(
            style: ButtonStyle(
              padding: WidgetStateProperty.all<EdgeInsets>(EdgeInsets.all(15)),
              backgroundColor: WidgetStateProperty.all<Color>(
                Color(0xffFE7501),
              ),
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  side: BorderSide(color: Colors.red),
                ),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text(
              "AED ${50 * 1.05} ",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showConsumeCancellationDialog(
    BuildContext context, {
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 50,
            ),
            const SizedBox(height: 16),
            const Text(
              "You’re about to consume your Cancellation.\nWould like to proceed?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context), // Close dialog
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("No"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE67E22), // Orange color
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Yes"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CustomWeeklyDatePicker extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateSelected;

  const CustomWeeklyDatePicker({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
  });

  @override
  State<CustomWeeklyDatePicker> createState() => _CustomWeeklyDatePickerState();
}

class _CustomWeeklyDatePickerState extends State<CustomWeeklyDatePicker> {
  late DateTime _focusedDate;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _focusedDate = widget.initialDate;
    _selectedDate = widget.initialDate;
  }

  // Helper to get the 7 days of the week for the focused date
  List<DateTime> _getWeekDays(DateTime date) {
    // Finding Monday of the current week
    DateTime monday = date.subtract(Duration(days: date.weekday - 1));
    return List.generate(7, (index) => monday.add(Duration(days: index)));
  }

  void _changeWeek(int weeks) {
    setState(() {
      _focusedDate = _focusedDate.add(Duration(days: weeks * 7));
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final days = _getWeekDays(_focusedDate);
    // Accessing your provider to find available dates
    final scheduleProvider = context.watch<ScheduleProvider>();

    return Container(
      padding: const EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Header: Select Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Select Date',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
          const SizedBox(height: 16),

          // 2. Navigation: < Wed, 3 Nov, 2025 >
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, size: 20),
                onPressed: () => _changeWeek(-1),
              ),
              Text(
                DateFormat('EEE, d MMM, yyyy').format(_focusedDate),
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward, size: 20),
                onPressed: () => _changeWeek(1),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 3. Days Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: days.map((day) {
              final isSelected = _isSameDay(day, _selectedDate);
              final isAvailable = scheduleProvider.availableDates.any(
                (d) => _isSameDay(d, day),
              );
              // final provider= Provider.of<ScheduleProvider>(context,listen: false);
              final isPast = _isPastDate(day); // check if day is past

              return GestureDetector(
                onTap: isPast
                    ? null // disable tap for past days
                    : () {
                        setState(() => _selectedDate = day);
                        widget.onDateSelected(day);
                      },
                child: Column(
                  children: [
                    Text(
                      DateFormat('E').format(day).substring(0, 2),
                      style: TextStyle(
                        color: isPast
                            ? Colors.grey
                            : Colors.black, // grey for past
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 40,
                      height: 45,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFF5E7B6)
                            : isAvailable
                            ? const Color(0xFFFBF3D3)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        day.day.toString(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isPast
                              ? Colors
                                    .grey // grey for past
                              : isSelected || isAvailable
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  bool _isPastDate(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(day.year, day.month, day.day);
    return d.isBefore(today); // true if day is before today
  }
}

extension ScheduleModelExt on ScheduleModel {
  DateTime get endDateTime {
    if (bookingDateTime == null) return DateTime.now();
    return bookingDateTime!.add(Duration(minutes: durationInMinutes ?? 60));
  }

  bool get isOngoing {
    final now = DateTime.now();
    if (bookingDateTime == null) return false;
    return now.isAfter(bookingDateTime!) && now.isBefore(endDateTime);
  }
}
