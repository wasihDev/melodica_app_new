import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:melodica_app_new/constants/app_colors.dart';
import 'package:melodica_app_new/models/packages_model.dart';
import 'package:melodica_app_new/providers/pacakge_provider.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';
import 'package:melodica_app_new/widgets/please_note_widget.dart';
import 'package:provider/provider.dart';

class FreezingRequestScreen extends StatefulWidget {
  Package package;
  FreezingRequestScreen({super.key, required this.package});

  @override
  State<FreezingRequestScreen> createState() => _FreezingRequestScreenState();
}

class _FreezingRequestScreenState extends State<FreezingRequestScreen> {
  DateTime currentMonth = DateTime.now();
  String reason = "Travel";
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<PackageProvider>(context, listen: false);
      print('provider.seasons ${provider.seasons}');
      if (provider.seasons.isEmpty) {
        await provider.fetchSeasons();
      }

      final remainingFreezes =
          widget.package.totalAllowedFreezings -
          widget.package.totalFreezingTaken;
      provider.setFreezingRemaining(remainingFreezes.toInt());
    });
  }

  List<DateTime> get daysInMonth {
    final last = DateTime(currentMonth.year, currentMonth.month + 1, 0);
    return List.generate(
      last.day,
      (i) => DateTime(currentMonth.year, currentMonth.month, i + 1),
    );
  }

  void onDateTap(DateTime date, PackageProvider p) {
    setState(() {
      if (p.startDate == null || p.endDate != null) {
        p.setStartDate(date);
        p.setEndDate(null);
      } else if (date.isBefore(p.startDate!)) {
        p.setStartDate(date);
      } else {
        p.setEndDate(date);
      }
    });
  }

  bool isInRange(DateTime date, PackageProvider p) {
    if (p.startDate == null) return false;
    if (p.endDate == null) return date == p.startDate;
    return !date.isBefore(p.startDate!) && !date.isAfter(p.endDate!);
  }

  List<DateTime?> buildCalendarDays(int year, int month) {
    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(year, month);

    final int leadingEmptyDays = firstDay.weekday - 1;

    final List<DateTime?> days = [];

    // Empty cells
    for (int i = 0; i < leadingEmptyDays; i++) {
      days.add(null);
    }

    // Actual days
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(year, month, i));
    }

    return days;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PackageProvider>(
      builder: (context, p, _) {
        final affectedClasses = p.scheduleProvider.getAffectedClasses(
          startDate: p.startDate ?? DateTime.now(),
          endDate: p.endDate ?? DateTime.now(),
          subject: p.packages.first.subject,
        );
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: const Text("Freezing Request"),
            leading: BackButton(
              onPressed: () {
                p.resetEndDate();
                Navigator.pop(context);
              },
            ),
          ),
          body: SafeArea(
            bottom: Platform.isIOS ? false : true,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // SizedBox(height: 5.h),
                    // _header(widget.package, p),
                    SizedBox(height: 10.h),
                    // _calendar(p),
                    dateRangeSelector(p),
                    SizedBox(height: 18.h),
                    PleaseNoteWidget(
                      title:
                          'Freezing beyond the allowable limit of your package may result in an extension fee. We recommend rescheduling your classes in advance to avoid extra fees.',
                    ),
                    SizedBox(height: 20.h),
                    _reasonDropdown(),
                    SizedBox(height: 5.h),
                    _freezingInfo(p),
                    SizedBox(height: 5.h),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.adaptSize),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (affectedClasses.isNotEmpty) ...[
                            SizedBox(height: 8.h),
                            Visibility(
                              visible: affectedClasses.length != 0,
                              child: _buildInfoRow(
                                "Affected Classes:",
                                "${affectedClasses.length}",
                                valueColor: Colors.red,
                                isBold: true,
                              ),
                            ),

                            SizedBox(height: 8.h),
                            Wrap(
                              spacing: 8.w,
                              runSpacing: 8.h,
                              children: affectedClasses.map((c) {
                                return Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 5.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade50,
                                    borderRadius: BorderRadius.circular(
                                      20.adaptSize,
                                    ),
                                    border: Border.all(
                                      color: Colors.amber.shade100,
                                    ),
                                  ),
                                  child: Text(
                                    DateFormat('d MMM yyyy').format(
                                      DateTime.parse(
                                        c['BookingDate'] ??
                                            DateTime.now().toString(),
                                      ),
                                    ),

                                    style: TextStyle(
                                      fontSize: 12.fSize,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            SizedBox(height: 8.h),
                          ],
                        ],
                      ), // --- SECTION 3: AFFECTED CLASSES (Visual Chips) ---
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            bottom: Platform.isIOS ? false : true,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: _submitButton(p),
            ),
          ),
        );
      },
    );
  }

  bool isPastOrToday(DateTime date) {
    final now = DateTime.now();
    final todayOnly = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    return !dateOnly.isAfter(todayOnly);
  }

  Future<void> _pickStartDate(PackageProvider p) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: p.startDate ?? DateTime.now(),
      firstDate: DateTime.now(),

      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.blue[900],
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      p.setStartDate(picked);
    }
  }

  Future<void> _pickEndDate(PackageProvider p) async {
    p.setSelectedPackage(widget.package);

    final firstDate = p.startDate ?? DateTime.now();

    // Ensure initialDate is valid
    DateTime initialDate;

    if (p.endDate != null && !p.endDate!.isBefore(firstDate)) {
      initialDate = p.endDate!;
    } else {
      initialDate = firstDate;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.blue[900],
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      p.setEndDate(picked);
      print('picked $picked');
      // 🔥 Call check after setting date
      p.checkNextClassPopup(context, p.selectedPackage!);
    }
  }

  Widget dateRangeSelector(PackageProvider p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Date Range",
          style: TextStyle(fontSize: 14.fSize, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _dateBox(
                context: context,
                date: p.startDate,
                onTap: () => _pickStartDate(p),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _dateBox(
                context: context,
                date: p.endDate,
                onTap: () => _pickEndDate(p),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _dateBox({
    required BuildContext context,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade500),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date != null
                  ? DateFormat("d MMM, yyyy").format(date)
                  : "Select date",
              style: TextStyle(fontSize: 13.fSize, fontWeight: FontWeight.w500),
            ),
            SvgPicture.asset('assets/svg/calendar_month.svg'),
          ],
        ),
      ),
    );
  }

  Widget _freezingInfo(PackageProvider p) {
    // Get affected classes
    final isSeason = p.currentSeason != null;
    // final isSeason = season != null;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 12.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.adaptSize),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- SECTION 1: HEADER ---
          Row(
            children: [
              Text(
                "Freezing Details",
                style: TextStyle(
                  fontSize: 14.fSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const Divider(height: 24),

          /// 🔥 Season Banner
          if (isSeason)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(8.w),
              margin: EdgeInsets.only(bottom: 8.h),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Text(
                p.isFullyInsideSeason
                    ? "Your selected dates fall within the season period. Free freezing is applied."
                    : "Your selected dates overlap with the season period. Fees apply only for dates outside the season.",
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.fSize,
                ),
              ),
            ),

          // TODO: remove s form weeks if its one
          // --- SECTION 2: DURATION DETAILS ---
          // Visibility(
          //   visible: p.freezeWeeksWithoutOverlap != 0,
          //   child: _buildInfoRow(
          //     "Freezing Duration:",
          //     "${p.freezeWeeksWithoutOverlap} Weeks",
          //     isBold: true,
          //   ),
          // ),
          // SizedBox(height: 8.h),
          Visibility(
            visible: p.freezeWeeks > 0,
            child: _buildInfoRow(
              "Freezing Duration:",
              "${p.freezeWeeks} Weeks",
              isBold: true,
            ),
          ),
          SizedBox(height: 8.h),
          _buildInfoRow(
            "Available Freezing:",
            "${p.freezingRemaining} Weeks",
            valueColor: Colors.black,
          ),
          SizedBox(height: 8.h),
          if (p.extraWeeks > 0)
            _buildInfoRow(
              "Extra Freezing required",
              "${p.extraWeeks} Weeks",
              valueColor: Colors.black,
              fontSize: 12.fSize,
            ),
          // Visibility(
          //   visible: affectedClasses.length != 0,
          //   child: _buildInfoRow(
          //     "Affected Classes:",
          //     "${affectedClasses.length}",
          //     valueColor: Colors.black,
          //   ),
          // ),

          // --- SECTION 4: EXTRA CHARGES (Conditional) ---
          // if (!isSeason)
          if (p.totalWithVat > 0)
            Consumer<PackageProvider>(
              builder: (_, p, __) {
                // final total = p.totalWithVat;
                return Column(
                  children: [
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.all(0.w),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8.adaptSize),
                      ),
                      child: Column(
                        children: [
                          // SizedBox(height: 6.h),
                          // _buildInfoRow(
                          //   "Base Fee",
                          //   "AED ${p.extraCharge.toStringAsFixed(2)}",
                          //   fontSize: 12.fSize,
                          // ),
                          // _buildInfoRow(
                          //   "VAT (5%)",
                          //   "AED ${vat.toStringAsFixed(2)}",
                          //   fontSize: 12.fSize,
                          //   isBold: true,
                          // ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total Fee",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.fSize,
                                  color: Colors.black,
                                ),
                              ),
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/svg/dirham_logo.svg',
                                    height: 12.h,
                                  ),
                                  Text(
                                    " ${p.totalWithVat.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.fSize,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  // Reusable helper for rows to keep the code clean
  Widget _buildInfoRow(
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
    double? fontSize,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize ?? 12.fSize,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize ?? 12.fSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _reasonDropdown() {
    return DropdownButtonFormField<String>(
      value: reason,
      items: [
        "Travel",
        "Medical",
        "Personal",
      ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: (v) => setState(() => reason = v!),
      dropdownColor: Colors.white,

      decoration: const InputDecoration(
        labelText: "Select Reason",

        border: OutlineInputBorder(),
      ),
      padding: EdgeInsets.all(0),
    );
  }

  Widget _submitButton(PackageProvider p) {
    return SafeArea(
      bottom: Platform.isIOS ? false : true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF5C542),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.adaptSize),
              ),
            ),
            onPressed: p.startDate != null && p.endDate != null && !p.isloading
                ? () => p.submitFreeze(context, reason, widget.package)
                : null,
            child: p.isloading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Submit", style: TextStyle(color: Colors.black)),
          ),
          SizedBox(height: 15.h),
        ],
      ),
    );
  }
}
