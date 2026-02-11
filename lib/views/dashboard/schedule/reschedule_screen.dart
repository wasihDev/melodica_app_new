import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:melodica_app_new/constants/app_colors.dart';
import 'package:melodica_app_new/models/schedule_model.dart';
import 'package:melodica_app_new/models/teacher_slots_models.dart';
import 'package:melodica_app_new/providers/pacakge_provider.dart';
import 'package:melodica_app_new/providers/schedule_provider.dart';
import 'package:melodica_app_new/providers/services_provider.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';
import 'package:melodica_app_new/utils/snacbar_utils.dart';
import 'package:melodica_app_new/views/dashboard/schedule/serivices.dart';
import 'package:melodica_app_new/views/dashboard/schedule/widget/custom_weekly_date_picker.dart';
import 'package:melodica_app_new/views/dashboard/schedule/widget/dialog_service.dart';
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
  // TeacherSlot? _selectedSlot;
  List<TeacherSlot> _slots = [];
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

      // print('subject = ${widget.s.subject}'); // Output: 30
      // print('locaiton = ${widget.s.bookingLocation}'); // Output: 30
      final response = await RescheduleService().getAvailability(
        // "2026-01-07",
        // DateFormat("yyyy-MM-dd").format(
        //   DateFormat("dd/MM/yyyy hh:mm a").parse(widget.s.bookingDateStartTime),
        // ),
        DateFormat('yyyy-MM-dd').format(_selectedDate),
        widget.s.bookingResourceId,
        duration.toInt(),
        widget.s.subject,
        widget.s.bookingLocation,
      );
      print('slots $response');
      // setState(() => _slots = slots);
      // final List<TeacherSlot> teacherSlots = (response['rows'] as List<dynamic>)
      //     .map((json) => TeacherSlot.fromJson(json))
      //     .toList();

      setState(() => _slots = response);
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
        return "Note:\nMoving this booking past its original booking date will consume one of your cancellations, consider taking it earlier if possible.\n";
      } else {
        return "Note:\nRescheduling this class to a later date will use one cancellation from your package. To avoid using a cancellation, you can choose an earlier date instead\n";
      }
    } else if (selectedDate.isAfter(packageExpiryDate) &&
        selectedDate.isBefore(packageExpiryDate.add(Duration(days: 7)))) {
      // Between package expiry and 1 week after expiry
      return "Note:\nThis is past your package expiry, booking these timings may result in using your extension or paying for an extension.\n";
    } else {
      return "";
    }
  }

  Future<void> _executeScheduleRequest(
    BuildContext context,
    ScheduleProvider provider, {
    required String action,
    required String lateNotic,
    required String preferredSlot,
  }) async {
    final classDateTime = formatStringToApiDate(widget.s.bookingDateStartTime);
    final Packageprovider = Provider.of<PackageProvider>(
      context,
      listen: false,
    );
    final pro = Packageprovider.packages.firstWhere(
      (n) => n.paymentRef == widget.s.PackageCode.toString(),
    );
    await provider
        .submitScheduleRequest(
          subject: widget.s.subject,
          classDateTime: classDateTime,
          action: action,
          preferredSlot: preferredSlot,
          reason: "",
          branch: "${pro.branch}",
          packageid: '${pro.paymentRef}',
          lateNotic: lateNotic, //late or early
          transactionId: '',
        )
        .then((val) {
          if (val == true) {
            DialogService.showSuccessDialog(context);
          }
        });
  }

  // Function to calculate Early or Late notice
  String calculateNoticeType(String classDateTime) {
    final format = DateFormat('dd MMM yyyy hh:mm a');
    final classTime = format.parse(classDateTime);

    final now = DateTime.now();
    final diff = classTime.difference(now);

    return diff.inHours > 24 ? 'Early' : 'Late';
  }

  String? _selectedTeacherId;
  String? _selectedSlotTime;
  String? _selectedTeacher;
  bool _showOthers = false;
  Widget _buildTeacherCard(var teacher) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${teacher.fullname}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 4,
            children: teacher.slots.map<Widget>((slotTime) {
              final isSelected =
                  _selectedTeacherId == teacher.id &&
                  _selectedSlotTime == slotTime;
              return GestureDetector(
                onTap: () {
                  final lastname = teacher.lastName.contains('(')
                      ? teacher.lastName.split('(').last.split(')').first
                      : teacher.lastName;
                  setState(() {
                    _selectedTeacherId = teacher.id;
                    _selectedTeacher = "${teacher.firstName} $lastname";
                    _selectedSlotTime = slotTime;
                  });
                },
                child: Chip(
                  label: Text(slotTime),
                  backgroundColor: isSelected
                      ? Colors.orange[100]
                      : Colors.grey[100],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  bool _showAllTeachers = false;
  @override
  Widget build(BuildContext context) {
    // final packageExpiryDate = DateFormat(
    //   'dd MMM yyyy hh:mm a',
    // ).parse(widget.s.PackageExpiry);

    // // Parse bookingDateStartTime (custom format with AM/PM)
    // final originalClassDate = DateFormat(
    //   'dd MMM yyyy hh:mm a',
    // ).parse(widget.s.bookingDateStartTime);
    // 1. For PackageExpiry: "2026-02-27T00:00:00"
    // This is ISO8601 format.
    final packageExpiryDate = DateFormat(
      "yyyy-MM-dd'T'HH:mm:ss",
    ).parse(widget.s.PackageExpiry);

    // 2. For bookingDateStartTime: "31 Jan 2026 01:00 PM"
    // This is your custom display format.
    final originalClassDate = DateFormat(
      "dd MMM yyyy hh:mm a",
    ).parse(widget.s.bookingDateStartTime);

    final warningNote = getWarningNote(
      selectedDate: _selectedDate,
      originalClassDate: originalClassDate,
      packageExpiryDate: packageExpiryDate,
      hasCancellations: widget.s.RemainingCancellations > 0,
    );
    // final sche = Provider.of<ScheduleProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white, title: Text("Reschedule")),
      body: SafeArea(
        bottom: Platform.isIOS ? false : true,
        child: Column(
          children: [
            Divider(),
            SizedBox(height: 5),
            // 1. Weekly Date Picker (As per design)
            CustomWeeklyDatePicker(
              initialDate: _selectedDate,
              expiryDate: packageExpiryDate,
              onDateSelected: (date) {
                print("packageExpiryDate ${packageExpiryDate}");
                setState(() {
                  _selectedDate = date;
                  _showAllTeachers = false;
                });

                _fetchSlots();
              },
            ),

            // 2. Warning Note
            if (warningNote.isNotEmpty ||
                _slots.isNotEmpty && _slots.first.slots.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFF7EC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '''$warningNote'''
                    '''${_slots.isNotEmpty && _slots.first.slots.isEmpty ? "Note:\nYour teacher is unavailable on this date. Available times with other teachers are listed below" : ""}''',
                    style: TextStyle(color: Colors.orange[800], fontSize: 13),
                  ),
                ),
              ),
            SizedBox(height: 10),
            selectedTimeDataWidget(),
            // 4. Action Buttons (Footer)
            Consumer2<ScheduleProvider, ServicesProvider>(
              builder: (context, scheduleProvider, servicesProvider, child) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedSlotTime == null
                                ? Colors.grey[200]
                                : AppColors.primary,
                          ),
                          onPressed: _selectedSlotTime == null
                              ? () {
                                  print('_selectedTeacher $_selectedTeacher');
                                }
                              : () async {
                                  final packageProvider =
                                      Provider.of<PackageProvider>(
                                        context,
                                        listen: false,
                                      );

                                  // 1️⃣ Parse booking date
                                  final DateTime bookingDate = DateFormat(
                                    'dd MMM yyyy hh:mm a',
                                  ).parse(widget.s.bookingDateStartTime);

                                  final DateTime selectedDate = DateTime(
                                    _selectedDate.year,
                                    _selectedDate.month,
                                    _selectedDate.day,
                                  );
                                  final expiryDay = DateTime(
                                    packageExpiryDate.year,
                                    packageExpiryDate.month,
                                    packageExpiryDate.day,
                                  );
                                  // 2️⃣ Calculate notice type (NO 24H logic)
                                  final String noticeType =
                                      calculateNoticeTypeFromDate(bookingDate);

                                  // 3️⃣ Decide charging
                                  final bool chargeUser = shouldCharge(
                                    bookingDate: bookingDate,
                                    selectedDate: selectedDate,
                                    noticeType: noticeType,
                                  );

                                  debugPrint("NoticeType: $noticeType");
                                  debugPrint("ChargeUser: $chargeUser");

                                  // 4️⃣ Prepare API values
                                  final classDateTime = formatStringToApiDate(
                                    widget.s.bookingDateStartTime,
                                  );

                                  final String newDatePart = DateFormat(
                                    'dd MMM yyyy',
                                  ).format(_selectedDate);

                                  final String combinedPreferredSlot =
                                      "$newDatePart $_selectedTeacher $_selectedSlotTime";
                                  print(
                                    ' combinedPreferredSlot ${combinedPreferredSlot}',
                                  );
                                  print(
                                    'widget.s.PackageCode ${widget.s.PackageCode}',
                                  );
                                  final pro = packageProvider.packages
                                      .firstWhere(
                                        (n) =>
                                            n.paymentRef ==
                                            widget.s.PackageCode.toString(),
                                      );

                                  // Current datetime
                                  final DateTime now = DateTime.now();
                                  final DateTime today = DateTime(
                                    now.year,
                                    now.month,
                                    now.day,
                                  );
                                  final DateTime scheduledDay = DateTime(
                                    bookingDate.year,
                                    bookingDate.month,
                                    bookingDate.day,
                                  );

                                  // if (today == scheduledDay &&
                                  //     selectedDate. > today) {
                                  //   showLateNoticeDialog(context);
                                  //   return;
                                  // }
                                  // if (today == scheduledDay) {
                                  //   showLateNoticeDialog(context);
                                  //   return;
                                  // }
                                  // final remainingExtension = 0;
                                  print(
                                    'pro.remainingExtension ${pro.remainingExtension}',
                                  );
                                  if (today.isAtSameMomentAs(scheduledDay) &&
                                      selectedDate.isAfter(today) &&
                                      ((selectedDate.isAfter(expiryDay) &&
                                              pro.remainingExtension > 0) ||
                                          selectedDate.isBefore(expiryDay))) {
                                    DialogService.showLateNoticeDialog(context);
                                    return;
                                  }
                                  // print(
                                  //   'object ${widget.s.RemainingCancellations != 0 && selectedDate.isAfter(scheduledDay)}',
                                  // );
                                  // Remainiign cancellation
                                  if (widget.s.RemainingCancellations != 0 &&
                                      selectedDate.isAfter(scheduledDay)) {
                                    if (selectedDate.isAfter(scheduledDay) &&
                                        !selectedDate.isAfter(expiryDay)) {
                                      DialogService.showConsumeCancellationDialog(
                                        context,
                                        onConfirm: () async {
                                          await _executeScheduleRequest(
                                            context,
                                            scheduleProvider,
                                            action: "Rebook",
                                            lateNotic: noticeType,
                                            preferredSlot:
                                                combinedPreferredSlot,
                                          );
                                        },
                                      );
                                      return;
                                    }

                                    if (noticeType == "Late" && !chargeUser) {
                                      await _executeScheduleRequest(
                                        context,
                                        scheduleProvider,
                                        action: "Reschedule",
                                        lateNotic: noticeType,
                                        preferredSlot: combinedPreferredSlot,
                                      );
                                      return;
                                    }

                                    print(
                                      'pro.remainingExtension ${pro.remainingExtension}',
                                    );
                                    if (selectedDate.isAtSameMomentAs(
                                          expiryDay,
                                        ) ||
                                        selectedDate.isAfter(expiryDay)) {
                                      if (pro.remainingExtension > 0) {
                                        print('remainingExtension > 0');
                                        DialogService.showConsumePopup(
                                          context,
                                          onConfirm: () async {
                                            await _executeScheduleRequest(
                                              context,
                                              scheduleProvider,
                                              action: "Rebook",
                                              lateNotic: 'Late',
                                              preferredSlot:
                                                  combinedPreferredSlot,
                                            );
                                          },
                                        );
                                        return;
                                      } else if (widget.s.LastClass == "TRUE") {
                                        print('widget.s.LastClass');
                                        DialogService.showNotEnoughExtensionPopup(
                                          context,
                                          ontap: () async {
                                            servicesProvider.setPaymentType(
                                              PaymentType.schedulePoints,
                                            );

                                            scheduleProvider
                                                .setScheduleRequests(
                                                  subject: widget.s.subject,
                                                  classDateTime: classDateTime,
                                                  action: "Rebook",
                                                  preferredSlot:
                                                      combinedPreferredSlot,
                                                  lateNotice: "Late",
                                                  branch: "${pro.branch}",
                                                  packageId:
                                                      '${pro.paymentRef}',
                                                );

                                            final vat = 50 * 0.05;
                                            final amountWithVat = (50 + vat);

                                            final success =
                                                await servicesProvider
                                                    .startCheckout(
                                                      context,
                                                      amount: amountWithVat,
                                                    );

                                            if (success &&
                                                servicesProvider.paymentUrl !=
                                                    null) {
                                              final requestReturn =
                                                  await scheduleProvider
                                                      .submitScheduleRequestAfterPayment(
                                                        servicesProvider
                                                            .orderReference!,
                                                      );
                                              if (requestReturn) {
                                                if (Navigator.canPop(context)) {
                                                  Navigator.pop(context);
                                                }
                                                await launchUrl(
                                                  Uri.parse(
                                                    servicesProvider
                                                        .paymentUrl!,
                                                  ),
                                                  mode: LaunchMode
                                                      .externalApplication,
                                                );
                                              }
                                            }
                                          },
                                          title:
                                              'No Extension!\nConsider paying for an extension to move it here?',
                                          payment: '50',
                                        );
                                        return;
                                      } else {
                                        print('remainingExtension == 0');
                                        DialogService.showNotEnoughExtensionPopup(
                                          context,
                                          ontap: () async {
                                            servicesProvider.setPaymentType(
                                              PaymentType.schedulePoints,
                                            );

                                            scheduleProvider
                                                .setScheduleRequests(
                                                  subject: widget.s.subject,
                                                  classDateTime: classDateTime,
                                                  action: "Rebook",
                                                  preferredSlot:
                                                      combinedPreferredSlot,
                                                  lateNotice: "Late",
                                                  branch: "${pro.branch}",
                                                  packageId:
                                                      '${pro.paymentRef}',
                                                );

                                            final vat = 50 * 0.05;
                                            // extension
                                            final amountWithVat = (100 + vat);
                                            // hit payment api first
                                            final success =
                                                await servicesProvider
                                                    .startCheckout(
                                                      context,
                                                      amount: amountWithVat,
                                                    );
                                            //then hit the submitSchedule

                                            if (success &&
                                                servicesProvider.paymentUrl !=
                                                    null) {
                                              final requestReturn =
                                                  await scheduleProvider
                                                      .submitScheduleRequestAfterPayment(
                                                        servicesProvider
                                                            .orderReference!,
                                                      );
                                              if (requestReturn) {
                                                if (Navigator.canPop(context)) {
                                                  Navigator.pop(context);
                                                }
                                                await launchUrl(
                                                  Uri.parse(
                                                    servicesProvider
                                                        .paymentUrl!,
                                                  ),
                                                  mode: LaunchMode
                                                      .externalApplication,
                                                );
                                              }
                                            }
                                          },
                                          title:
                                              "Late notice!\nReschedule earlier to avoid recovery and extension fee.",
                                          payment: '100',
                                        );
                                        return;
                                      }
                                    }
                                  } else if (widget.s.RemainingCancellations ==
                                          0 &&
                                      selectedDate.isAfter(scheduledDay)) {
                                    if (widget.s.RemainingCancellations == 0 &&
                                        pro.remainingExtension == 0) {
                                      DialogService.showNotEnoughExtensionPopup(
                                        context,
                                        ontap: () async {
                                          servicesProvider.setPaymentType(
                                            PaymentType.schedulePoints,
                                          );

                                          scheduleProvider.setScheduleRequests(
                                            subject: widget.s.subject,
                                            classDateTime: classDateTime,
                                            action: "Rebook",
                                            preferredSlot:
                                                combinedPreferredSlot,
                                            lateNotice: "Late",
                                            branch: "${pro.branch}",
                                            packageId: '${pro.paymentRef}',
                                          );

                                          final vat = 50 * 0.05;
                                          // extension
                                          final amountWithVat = (100 + vat);
                                          print('amountWithVat $amountWithVat');
                                          final success = await servicesProvider
                                              .startCheckout(
                                                context,
                                                amount: amountWithVat,
                                              );

                                          if (success &&
                                              servicesProvider.paymentUrl !=
                                                  null) {
                                            final requestReturn =
                                                await scheduleProvider
                                                    .submitScheduleRequestAfterPayment(
                                                      servicesProvider
                                                          .orderReference!,
                                                    );
                                            if (requestReturn) {
                                              if (Navigator.canPop(context)) {
                                                Navigator.pop(context);
                                              }
                                              await launchUrl(
                                                Uri.parse(
                                                  servicesProvider.paymentUrl!,
                                                ),
                                                mode: LaunchMode
                                                    .externalApplication,
                                              );
                                            }
                                          }
                                        },
                                        title:
                                            "Late notice!\nReschedule earlier to avoid recovery and extension fee.",
                                        payment: '100',
                                      );
                                      return;
                                    }
                                    print('esle if part');
                                    DialogService.showNotEnoughCancellationPopup(
                                      context,
                                      ontap: () async {
                                        servicesProvider.setPaymentType(
                                          PaymentType.schedulePoints,
                                        );

                                        scheduleProvider.setScheduleRequests(
                                          subject: widget.s.subject,
                                          classDateTime: classDateTime,
                                          action: "Rebook",
                                          preferredSlot: combinedPreferredSlot,
                                          lateNotice: "Early",
                                          branch: "${pro.branch}",
                                          packageId: '${pro.paymentRef}',
                                        );

                                        final vat = 50 * 0.05;
                                        final amountWithVat = (50 + vat);

                                        final success = await servicesProvider
                                            .startCheckout(
                                              context,
                                              amount: amountWithVat,
                                            );
                                        if (success &&
                                            servicesProvider.paymentUrl !=
                                                null) {
                                          final requestReturn =
                                              await scheduleProvider
                                                  .submitScheduleRequestAfterPayment(
                                                    servicesProvider
                                                        .orderReference!,
                                                  );
                                          if (requestReturn) {
                                            if (Navigator.canPop(context)) {
                                              Navigator.pop(context);
                                            }
                                            await launchUrl(
                                              Uri.parse(
                                                servicesProvider.paymentUrl!,
                                              ),
                                              mode: LaunchMode
                                                  .externalApplication,
                                            );
                                          }
                                        }
                                      },
                                    );
                                    return;
                                  } else {
                                    print('else');
                                    await _executeScheduleRequest(
                                      context,
                                      scheduleProvider,
                                      action: "Reschedule",
                                      lateNotic: noticeType,
                                      preferredSlot: combinedPreferredSlot,
                                    );
                                    return;
                                  }

                                  // =========================
                                  // 🟢 CASE 3: EARLY → ALWAYS FREE
                                  // =========================
                                  await _executeScheduleRequest(
                                    context,
                                    scheduleProvider,
                                    action: "Reschedule",
                                    lateNotic: noticeType,
                                    preferredSlot: combinedPreferredSlot,
                                  );
                                },
                          child: scheduleProvider.isLoading
                              ? CircularProgressIndicator(color: Colors.black)
                              : Text(
                                  "Select this time",
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
                              style: ButtonStyle(
                                side: WidgetStatePropertyAll(
                                  BorderSide(
                                    color: Colors.black,

                                    // width: 2,
                                  ),
                                ),
                              ),
                              onPressed: () async {
                                final Packageprovider =
                                    Provider.of<PackageProvider>(
                                      context,
                                      listen: false,
                                    );

                                // Find the specific package to check its details
                                final pro = Packageprovider.packages.firstWhere(
                                  (n) =>
                                      n.paymentRef ==
                                      widget.s.PackageCode.toString(),
                                );

                                // Parsing the ORIGINAL class date
                                final DateTime bookingdata = DateFormat(
                                  'dd MMM yyyy hh:mm a',
                                ).parse(widget.s.bookingDateStartTime);
                                final DateTime now = DateTime.now();

                                // Standardize dates to compare only the Day
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
                                final servicesProvider =
                                    Provider.of<ServicesProvider>(
                                      context,
                                      listen: false,
                                    );

                                final scheduleProvider =
                                    Provider.of<ScheduleProvider>(
                                      context,
                                      listen: false,
                                    );
                                final classDateTime = formatStringToApiDate(
                                  widget.s.bookingDateStartTime,
                                );
                                // --- FIX 2 & 3: LATE NOTICE & RESTRICTION LOGIC ---
                                if (pro.remainingExtension <= 0) {
                                  DialogService.showNotEnoughExtensionPopup(
                                    context,
                                    ontap: () async {
                                      servicesProvider.setPaymentType(
                                        PaymentType.schedulePoints,
                                      );

                                      scheduleProvider.setScheduleRequests(
                                        subject: widget.s.subject,
                                        classDateTime: classDateTime,
                                        action: "Rebook",
                                        preferredSlot: '',
                                        lateNotice: 'Late',
                                        branch: "${pro.branch}",
                                        packageId: '${pro.paymentRef}',
                                      );

                                      final vat = 50 * 0.05;
                                      final amountWithVat = (50 + vat);

                                      final success = await servicesProvider
                                          .startCheckout(
                                            context,
                                            amount: amountWithVat,
                                          );

                                      if (success &&
                                          servicesProvider.paymentUrl != null) {
                                        final requestReturn =
                                            await scheduleProvider
                                                .submitScheduleRequestAfterPayment(
                                                  servicesProvider
                                                      .orderReference!,
                                                );
                                        if (requestReturn) {
                                          if (Navigator.canPop(context)) {
                                            Navigator.pop(context);
                                          }
                                          await launchUrl(
                                            Uri.parse(
                                              servicesProvider.paymentUrl!,
                                            ),
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
                                        }
                                      }
                                    },
                                    title:
                                        'No Extension!\nConsider paying for an extension to move it here?',
                                    payment: '50',
                                  );

                                  return;
                                }
                                if (today == scheduledDay) {
                                  DialogService.showLateNoticeDialog(context);
                                  return;
                                }

                                // --- 1: For remaining cancellations ---
                                if (widget.s.RemainingCancellations != 0) {
                                  DialogService.showConsumeCancellationDialog(
                                    context,
                                    onConfirm: () async {
                                      await provider
                                          .submitScheduleRequest(
                                            subject: widget.s.subject,
                                            // ✅ Manager's requirement: Use the ORIGINAL class date here
                                            classDateTime: classDateTime,
                                            action: 'Unbooked',
                                            // Empty because it's "Schedule Later"
                                            preferredSlot: "",
                                            reason: '',
                                            branch: '${pro.branch}',
                                            packageid: '${pro.paymentRef}',
                                            // Pass 'Late' or 'Early' so the API knows which rule to apply
                                            lateNotic: today == scheduledDay
                                                ? 'Late'
                                                : 'Early',
                                          )
                                          .then((val) {
                                            if (val == true) {
                                              DialogService.showSuccessDialog(
                                                context,
                                              );
                                            }
                                          });
                                    },
                                  );
                                  return;
                                } else {
                                  DialogService.showNotEnoughCancellationPopup(
                                    context,
                                    ontap: () async {
                                      servicesProvider.setPaymentType(
                                        PaymentType.schedulePoints,
                                      );

                                      scheduleProvider.setScheduleRequests(
                                        subject: widget.s.subject,
                                        classDateTime: classDateTime,
                                        action: "Rebook",
                                        preferredSlot: "",
                                        lateNotice: today == scheduledDay
                                            ? 'Late'
                                            : 'Early',
                                        branch: "${pro.branch}",
                                        packageId: '${pro.paymentRef}',
                                      );

                                      final vat = 50 * 0.05;
                                      final amountWithVat = (50 + vat);

                                      final success = await servicesProvider
                                          .startCheckout(
                                            context,
                                            amount: amountWithVat,
                                          );

                                      if (success &&
                                          servicesProvider.paymentUrl != null) {
                                        final requestReturn =
                                            await scheduleProvider
                                                .submitScheduleRequestAfterPayment(
                                                  servicesProvider
                                                      .orderReference!,
                                                );
                                        if (requestReturn) {
                                          if (Navigator.canPop(context)) {
                                            Navigator.pop(context);
                                          }
                                          await launchUrl(
                                            Uri.parse(
                                              servicesProvider.paymentUrl!,
                                            ),
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
                                        }
                                      }
                                    },
                                  );
                                  return;
                                }
                              },
                              child: Text(
                                "Decide later",
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

  Widget selectedTimeDataWidget() {
    return Expanded(
      child: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.symmetric(horizontal: 16),
              children: [
                // --- 2. LIST OF TEACHERS ---
                ..._slots.asMap().entries.map((entry) {
                  int index = entry.key;
                  final teacher = entry.value;

                  // Logic: Show the first teacher OR show everyone if the button was clicked
                  if (index > 0 && !_showAllTeachers) {
                    return SizedBox.shrink();
                  }

                  return Column(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.only(bottom: 10),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${teacher.fullname}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            if (teacher.slots.isEmpty)
                              Text(
                                "No slots available",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              )
                            else
                              Wrap(
                                spacing: 5,
                                children: teacher.slots.map((slotTime) {
                                  final isSelected =
                                      _selectedTeacherId == teacher.id &&
                                      _selectedSlotTime == slotTime;
                                  return GestureDetector(
                                    onTap: () {
                                      final lastname = teacher.lastName
                                          .split('(')
                                          .last
                                          .replaceAll(')', '');
                                      setState(() {
                                        _selectedTeacherId = teacher.id;
                                        _selectedTeacher =
                                            "${teacher.firstName} $lastname";
                                        _selectedSlotTime = slotTime;
                                      });
                                    },
                                    child: Chip(
                                      padding: EdgeInsets.all(0),
                                      label: Text(slotTime),
                                      backgroundColor: isSelected
                                          ? Colors.orange[100]
                                          : Colors.grey[100],
                                    ),
                                  );
                                }).toList(),
                              ),
                          ],
                        ),
                      ),

                      // --- 3. THE "SHOW OTHER TEACHERS" BUTTON ---
                      // Show this only after the first teacher and only if there's more than one teacher
                      if (index == 0 && _slots.length > 1 && !_showAllTeachers)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Center(
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(
                                  AppColors.primary,
                                ),
                              ),
                              onPressed: () =>
                                  setState(() => _showAllTeachers = true),
                              child: Text(
                                "Show Other Teachers",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                }).toList(),
              ],
            ),
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

  bool isAfterExpiry(DateTime selectedDate, DateTime expiryDate) {
    return selectedDate.isAfter(expiryDate);
  }

  String formatToApiDate(DateTime date) {
    return date.toUtc().toIso8601String().split('.').first + 'Z';
  }

  String formatStringToApiDate(String dateString) {
    try {
      // Parse: 31 Jan 2026 01:00 PM
      final parsedDate = DateFormat('dd MMM yyyy hh:mm a').parse(dateString);

      // Convert to API-friendly ISO8601 (UTC)
      return parsedDate.toUtc().toIso8601String().split('.').first + 'Z';
    } catch (e) {
      print("Error parsing date string: $e");
      return dateString;
    }
  }

  /// new schedule logic is here
  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String calculateNoticeTypeFromDate(DateTime bookingDate) {
    final now = DateTime.now();
    print('bookingDate $bookingDate');
    print('now $now');
    return isSameDay(bookingDate, now) ? "Late" : "Early";
  }

  bool shouldCharge({
    required DateTime bookingDate,
    required DateTime selectedDate,
    required String noticeType,
  }) {
    if (noticeType == "Early") return false;
    return !isSameDay(bookingDate, selectedDate);
  }
}

extension ScheduleModelExt on ScheduleModel {
  DateTime get endDateTime {
    if (bookingDateTime == null) return DateTime.now();
    return bookingDateTime!.add(Duration(minutes: durationInMinutes));
  }

  bool get isOngoing {
    final now = DateTime.now();
    if (bookingDateTime == null) return false;
    return now.isAfter(bookingDateTime!) && now.isBefore(endDateTime);
  }
}
