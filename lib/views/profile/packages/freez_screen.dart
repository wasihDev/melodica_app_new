import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:melodica_app_new/models/packages_model.dart';
import 'package:melodica_app_new/providers/pacakge_provider.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';
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
    final provider = Provider.of<PackageProvider>(context, listen: false);
    final remainingFreezes =
        widget.package.totalAllowedFreezings -
        widget.package.totalFreezingTaken;
    provider.setFreezingRemaining(remainingFreezes.toInt());
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

  @override
  Widget build(BuildContext context) {
    return Consumer<PackageProvider>(
      builder: (context, p, _) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: const Text("Freezing Request"),
            leading: const BackButton(),
          ),
          body: SafeArea(
            bottom: true,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _header(widget.package, p),
                    SizedBox(height: 10.h),
                    _calendar(p),
                    SizedBox(height: 10.h),
                    _freezingInfo(p),
                    SizedBox(height: 10.h),
                    _reasonDropdown(),
                    // const Spacer(),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: _submitButton(p),
        );
      },
    );
  }

  Widget _header(Package package, PackageProvider p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Date",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Chip(
              backgroundColor: Colors.white,
              label: Text(
                "${DateFormat('EEE, d MMM, y').format(DateTime.now())}",
              ),
            ),
            SizedBox(width: 8),
            Chip(
              backgroundColor: Colors.white,
              label: Text("${package.classDuration} "),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Text(
          "Remaining Sessions: ${package.remainingSessions.toString().split(".").first}/${package.totalClasses.toString()}",
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: package.remainingSessions / package.totalClasses,
            minHeight: 8,
            backgroundColor: Colors.grey.shade300,
            valueColor: const AlwaysStoppedAnimation(Color(0xFFF5C542)),
          ),
        ),
      ],
    );
  }

  bool isPastOrToday(DateTime date) {
    final now = DateTime.now();
    final todayOnly = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    return !dateOnly.isAfter(todayOnly);
  }

  Widget _calendar(PackageProvider p) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => setState(() {
                  currentMonth = DateTime(
                    currentMonth.year,
                    currentMonth.month - 1,
                  );
                }),
              ),
              Text(
                DateFormat.yMMMM().format(currentMonth),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => setState(() {
                  currentMonth = DateTime(
                    currentMonth.year,
                    currentMonth.month + 1,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _weekDays(),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daysInMonth.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemBuilder: (_, i) {
              final date = daysInMonth[i];
              final selected = isInRange(date, p);
              final isPast = isPastOrToday(date);

              return InkWell(
                onTap: isPast
                    ? null
                    : () => onDateTap(date, p), // 🚫 disable tap
                child: Container(
                  decoration: BoxDecoration(
                    color: isPast
                        ? Colors
                              .grey
                              .shade200 // past dates muted
                        : selected
                        ? Colors.amber
                        : Colors.amber.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isPast ? Colors.grey : Colors.black,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _weekDays() {
    const days = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days
          .map(
            (d) => SizedBox(
              width: 32,
              child: Text(d, textAlign: TextAlign.center),
            ),
          )
          .toList(),
    );
  }

  Widget _freezingInfo(PackageProvider p) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Freezing duration: ${p.freezeWeeks} week(s)",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              "Remaining Freezing: ${p.freezingRemaining}",
              style: TextStyle(
                color: p.hasEnoughFreezing ? Colors.green : Colors.red,
              ),
            ),
            Consumer<PackageProvider>(
              builder: (_, p, __) {
                final vat = p.extraCharge * 0.05;
                if (p.extraCharge == 0) {
                  return Text(
                    "Freezing covered by your allowance",
                    style: TextStyle(color: Colors.green),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Extra freezing required: ${p.extraWeeks} week(s)",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    //                   final double baseAmount = double.parse(amount);
                    // final double vat = baseAmount * 0.05;
                    // final double total = baseAmount + vat;
                    Text(
                      'VAT: AED ${p.extraCharge * 0.05}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Additional charge: AED ${p.extraCharge + vat}",
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
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

        border: OutlineInputBorder(
          // borderSide: BorderSide(color: Colors.yellow),
        ),
      ),
    );
  }

  Widget _submitButton(PackageProvider p) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF5C542),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: p.startDate != null && p.endDate != null && !p.isLoading
                ? () => p.submitFreeze(context, reason, widget.package)
                : null,
            child: p.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Submit", style: TextStyle(color: Colors.black)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
