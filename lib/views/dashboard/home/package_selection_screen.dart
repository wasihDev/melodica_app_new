import 'package:flutter/material.dart';
import 'package:melodica_app_new/constants/app_colors.dart';
import 'package:melodica_app_new/providers/services_provider.dart';
import 'package:melodica_app_new/providers/student_provider.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';
import 'package:melodica_app_new/utils/snacbar_utils.dart';
import 'package:melodica_app_new/views/dashboard/home/checkout/checkout_screen.dart';
import 'package:melodica_app_new/views/dashboard/home/widget/package_card.dart';
import 'package:melodica_app_new/views/dashboard/home/widget/package_dance_card.dart';
import 'package:provider/provider.dart';

class PackageSelectionScreen extends StatefulWidget {
  bool isShowdanceTab;
  bool? iscomingFromNewStudent = false;
  PackageSelectionScreen({
    super.key,
    required this.isShowdanceTab,
    this.iscomingFromNewStudent,
  });

  @override
  State<PackageSelectionScreen> createState() => _PackageSelectionScreenState();
}

class _PackageSelectionScreenState extends State<PackageSelectionScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final ctrl = Provider.of<ServicesProvider>(context, listen: false);

      if (widget.isShowdanceTab == false) {
        ctrl.setTab('Music');
        setState(() {
          widget.isShowdanceTab = false;
        });
      } else {
        ctrl.setTab('Dance');
        setState(() {
          widget.isShowdanceTab = true;
        });
      }
    });
    print('widget.isShowdanceTab ${widget.isShowdanceTab}');

    WidgetsBinding.instance.addPostFrameCallback((val) async {
      final provider = context.read<ServicesProvider>();

      if (provider.all.isEmpty) {
        await context.read<ServicesProvider>().fetch();

        setState(() {});
      }
      if (mounted) {
        await context.read<ServicesProvider>().fetchDancePackages();
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Package Selection'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Consumer<ServicesProvider>(
        builder: (context, ctrl, child) {
          return ctrl.loading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0.w),
                  child: Column(
                    children: [
                      // Tabs (Music / Dance)
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                ctrl.setTab('Music');
                                setState(() {
                                  widget.isShowdanceTab = false;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 10.h),
                                decoration: BoxDecoration(
                                  color: ctrl.tab == 'Music'
                                      ? const Color(0xFFF7CD3C)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Music',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: ctrl.tab == 'Music'
                                        ? Colors.black87
                                        : Colors.black54,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Consumer<CustomerController>(
                            builder: (context, ctrls, child) {
                              return Expanded(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: ctrls.display
                                      ? () {
                                          ctrl.setTab('Dance');
                                          setState(() {
                                            widget.isShowdanceTab = true;
                                          });
                                        }
                                      : () {
                                          SnackbarUtils.showInfo(
                                            context,
                                            "There are currently no dance packages available for this branch.Feel free to enquire about packages at our other branches.",
                                          );
                                        },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 10.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: ctrl.tab == 'Dance'
                                          ? const Color(0xFFF7CD3C)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(28),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Dance',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: ctrl.tab == 'Dance'
                                            ? Colors.black87
                                            : Colors.black54,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      SizedBox(height: 10.h),

                      widget.isShowdanceTab == false
                          ? Expanded(
                              // music
                              child: Column(
                                children: [
                                  // Course dropdown
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Select Course',
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField<String>(
                                    padding: EdgeInsets.all(0),
                                    value:
                                        ctrl.selectedServiceName ??
                                        (ctrl.uniqueServices.isEmpty
                                            ? null
                                            : ctrl.uniqueServices.first),
                                    menuMaxHeight: 300.h,

                                    dropdownColor: Colors.white,
                                    items: ctrl.uniqueServices
                                        .map(
                                          (s) => DropdownMenuItem(
                                            value: s,
                                            child: Text(
                                              s,
                                              style: TextStyle(
                                                fontSize: 14.fSize,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) {
                                      if (v != null) ctrl.setSelectedService(v);
                                      setState(() {});
                                    },

                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 12.h,
                                      ),
                                      filled: true,
                                      fillColor: Colors.transparent,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[200]!,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // DropdownButtonFormField<ServiceModel>(
                                  //   value:
                                  //       ctrl.selectedFrequency ??
                                  //       (ctrl.uniqueFrequencies.isEmpty
                                  //           ? null
                                  //           : ctrl.uniqueFrequencies.first),
                                  //   items: ctrl.uniqueFrequencies.map((f) {
                                  //     return DropdownMenuItem<ServiceModel>(
                                  //       value: f,
                                  //       child: Text(
                                  //         f.frequencytext ?? '',
                                  //         style: const TextStyle(fontSize: 16),
                                  //       ),
                                  //     );
                                  //   }).toList(),
                                  //   onChanged: (v) {
                                  //     if (v != null) {
                                  //       // ctrl.setSelectedFrequency(v);
                                  //     }
                                  //   },
                                  //   decoration: InputDecoration(
                                  //     contentPadding:
                                  //         const EdgeInsets.symmetric(
                                  //           horizontal: 16,
                                  //           vertical: 18,
                                  //         ),
                                  //     filled: true,
                                  //     fillColor: Colors.transparent,
                                  //     border: OutlineInputBorder(
                                  //       borderRadius: BorderRadius.circular(12),
                                  //       borderSide: BorderSide(
                                  //         color: Colors.grey[200]!,
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                  SizedBox(
                                    height: 40.h,
                                    child: ListView(
                                      scrollDirection: Axis.horizontal,
                                      children:
                                          ctrl
                                              .durationsForSelectedService
                                              .isEmpty
                                          ? []
                                          : ctrl.durationsForSelectedService.map((
                                              d,
                                            ) {
                                              final selected =
                                                  ctrl.selectedDuration == d;
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 12,
                                                ),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    print('selecrted');
                                                    ctrl.setSelectedDuration(d);
                                                    setState(() {});
                                                  },
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 20,
                                                          vertical: 10,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: selected
                                                          ? const Color(
                                                              0xFFF7CD3C,
                                                            )
                                                          : Colors.transparent,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            30,
                                                          ),
                                                      border: Border.all(
                                                        color: Colors
                                                            .grey
                                                            .shade400,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      '$d Min',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 12.fSize,
                                                        color: selected
                                                            ? Colors.black87
                                                            : Colors.black54,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  DropdownButtonFormField<String>(
                                    dropdownColor: Colors.white,
                                    value: ctrl.selectedFrequency,
                                    hint: const Text('Select frequency'),
                                    items: ctrl.frequencyOptions
                                        .map(
                                          (f) => DropdownMenuItem(
                                            value: f,
                                            child: Text(f),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: ctrl.setFrequency,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12.h,
                                      ),
                                      filled: true,
                                      fillColor: Colors.transparent,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[200]!,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Duration chips (30/45/60 based on available durations)
                                  SizedBox(height: 15.h),

                                  // Packages list
                                  Expanded(
                                    child: ctrl.filteredList.isEmpty
                                        ? const Center(
                                            child: CircularProgressIndicator(),
                                          )
                                        : ListView.builder(
                                            itemCount: ctrl.filteredList.length,
                                            padding: EdgeInsets.only(
                                              bottom: 10.h,
                                            ),
                                            itemBuilder: (context, idx) {
                                              final s = ctrl.filteredList[idx];
                                              final selected = ctrl.isSelected(
                                                s,
                                              );
                                              if (ctrl.all.isEmpty) {
                                                return Expanded(
                                                  child: Center(
                                                    child: Text(
                                                      'No Music Package found',
                                                    ),
                                                  ),
                                                );
                                              }
                                              return PackageCard(
                                                onTap: () {
                                                  print('object');

                                                  ctrl.selectPrice(s.priceid);
                                                  ctrl.addPackage(s, idx);

                                                  setState(() {});
                                                },
                                                package: ctrl.filteredList[idx],
                                                isSelected: selected,
                                              );
                                            },
                                          ),
                                  ),

                                  // Next button
                                  SafeArea(
                                    top: false,
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: ctrl.selectedPackages.isEmpty
                                            ? null
                                            : widget.iscomingFromNewStudent ==
                                                  true
                                            ? () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        CheckoutScreen(
                                                          iscomingFromNewStudent:
                                                              true,
                                                        ),
                                                  ),
                                                );
                                              }
                                            : () {
                                                final selectedPackage =
                                                    ctrl.selectedPackages;
                                                if (selectedPackage
                                                    .isNotEmpty) {
                                                  // ctrl.addPackage(
                                                  //   selectedPackage[],
                                                  // );
                                                  showStudentPicker(context);
                                                }
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              ctrl.selectedPackages.isEmpty
                                              ? Colors.grey
                                              : const Color(0xFFF7CD3C),
                                          foregroundColor: Colors.black87,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 18,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'Next',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          //////////////////////// <=== dance ===> ///////////////////////////////////////////////////////////////////
                          : Expanded(
                              child: Column(
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Select Course',
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    height: 50.h,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey[500]!,
                                      ),
                                    ),
                                    child: Consumer<ServicesProvider>(
                                      builder: (context, provider, child) {
                                        return Center(
                                          child: Text(
                                            provider.alldanceList.first.subject,
                                            // 'Ballet, Hip Hop, Contemporary & Belly Dance',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  Consumer<ServicesProvider>(
                                    builder: (context, provider, child) {
                                      if (provider.alldanceList.isEmpty) {
                                        return Expanded(
                                          child: Center(
                                            child: Text(
                                              'No Dance Package found',
                                            ),
                                          ),
                                        );
                                      }
                                      return Expanded(
                                        child: provider.loading
                                            ? const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                      color: AppColors.primary,
                                                    ),
                                              )
                                            : ListView.builder(
                                                itemCount: provider
                                                    .alldanceList
                                                    .length,
                                                padding: const EdgeInsets.only(
                                                  bottom: 15,
                                                ),
                                                itemBuilder: (context, idx) {
                                                  final s = provider
                                                      .alldanceList[idx];
                                                  final selected = ctrl
                                                      .isSelected(s);
                                                  return PackageWidgetCard(
                                                    onTap: () {
                                                      provider.selectPrice(
                                                        s.priceid,
                                                      );
                                                      ctrl.addPackage(s, idx);

                                                      setState(() {});
                                                    },
                                                    package: provider
                                                        .alldanceList[idx],
                                                    isSelected: selected,
                                                  );
                                                },
                                              ),
                                      );
                                    },
                                  ),
                                  Consumer<ServicesProvider>(
                                    builder: (context, provider, child) {
                                      return SafeArea(
                                        top: false,
                                        bottom: true,
                                        child: SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed:
                                                widget.iscomingFromNewStudent ==
                                                    true
                                                ? () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            CheckoutScreen(
                                                              iscomingFromNewStudent:
                                                                  true,
                                                            ),
                                                      ),
                                                    );
                                                  }
                                                : () {
                                                    // final selected = provider.all
                                                    //     .firstWhere(
                                                    //       (e) =>
                                                    //           e.priceid ==
                                                    //           provider
                                                    //               .selectedPriceId,
                                                    //     );
                                                    // handle next step — for demo we show a snackbar
                                                    final selectedPackage =
                                                        ctrl.selectedPackages;
                                                    if (selectedPackage
                                                        .isNotEmpty) {
                                                      // ctrl.addPackage(
                                                      //   selectedPackage[],
                                                      // );
                                                      // Navigator.push(
                                                      //   context,
                                                      //   MaterialPageRoute(
                                                      //     builder: (_) =>
                                                      //         StudentsScreen(),
                                                      //   ),
                                                      // );
                                                      showStudentPicker(
                                                        context,
                                                      );
                                                    }
                                                  },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFFF7CD3C,
                                              ),
                                              foregroundColor: Colors.black87,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 18,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: const Text(
                                              'Next',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                    ],
                  ),
                );
        },
      ),
    );
  }

  void showStudentPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer<CustomerController>(
          builder: (context, ctrl, _) {
            return AlertDialog(
              title: const Text('Select Student'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: ctrl.students.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final student = ctrl.students[index];
                    final isSelected =
                        ctrl.selectedStudent?.mbId == student.mbId;

                    return ListTile(
                      title: Text(student.fullName),
                      subtitle: Text("MBID: ${student.mbId.toString()}"),

                      trailing: isSelected
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                      onTap: () {
                        ctrl.selectStudent(student);
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CheckoutScreen(iscomingFromNewStudent: false),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
