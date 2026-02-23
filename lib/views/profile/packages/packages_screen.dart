import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:melodica_app_new/constants/app_colors.dart';
import 'package:melodica_app_new/models/packages_model.dart';
import 'package:melodica_app_new/providers/pacakge_provider.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';
import 'package:melodica_app_new/views/profile/packages/packages_details.dart';
import 'package:provider/provider.dart';

class PackageListScreen extends StatefulWidget {
  const PackageListScreen({super.key});

  @override
  State<PackageListScreen> createState() => _PackageListScreenState();
}

class _PackageListScreenState extends State<PackageListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,

        title: const Text('Packages'),
        bottom: TabBar(
          indicatorColor: AppColors.primary,
          labelStyle: TextStyle(color: AppColors.primary),
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Consumer<PackageProvider>(
            builder: (context, provider, _) {
              if (provider.isloading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.error != null) {
                return Center(child: Text(provider.error!));
              }

              if (provider.packages.isEmpty) {
                return const Center(child: Text('Please wait....'));
              }

              final activePackages = provider.packages
                  .where(
                    (p) =>
                        p.packageStatus == 'Active' ||
                        p.packageStatus == "On Going",
                  )
                  .toList();
              final completedPackages = provider.packages
                  .where(
                    (p) =>
                        p.packageStatus != 'Active' &&
                        p.packageStatus != "On Going",
                  )
                  .toList();
              return TabBarView(
                controller: _tabController,
                children: [
                  _PackageListView(packages: activePackages, isActive: true),
                  _PackageListView(
                    packages: completedPackages,
                    isActive: false,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PackageListView extends StatelessWidget {
  final List<Package> packages;
  final bool isActive;

  const _PackageListView({required this.packages, required this.isActive});
  String formatCreatedOss(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty || isoDate == 'N/A') {
      return 'N/A';
    }

    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return 'N/A';
    }
  }

  Widget _statCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: packages.length,
      separatorBuilder: (context, index) => SizedBox(height: 15),
      itemBuilder: (context, index) {
        final package = packages[index];
        final unbookedClasses = package.totalClasses - package.totalBooked;
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PackageDetailScreen(package: package),
              ),
            );
          },
          child: Container(
            height: package.danceOrMusic == "Dance Classes" ? 320.h : 435.h,
            width: double.infinity,
            padding: EdgeInsets.all(12.adaptSize),
            margin: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  tileColor: Colors.grey[100],
                  contentPadding: EdgeInsets.all(0),
                  title: Text(
                    '${package.serviceandproduct}',
                    style: TextStyle(
                      fontSize: 20.fSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(package.locationName),
                ),
                Visibility(
                  visible: package.danceOrMusic != "Dance Classes",
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _statCard(
                        'Total Classes',
                        "${package.totalClasses.toString()}",
                      ),
                      SizedBox(width: 10),
                      _statCard(
                        'Remaining Classes',
                        "${package.remainingSessions.toString().split('.').first}",
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                Divider(color: Color(0xffE2E2E2)),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset('assets/svg/teacher.svg'),
                        SizedBox(width: 5),
                        Text('Teacher: ', style: TextStyle(fontSize: 14.fSize)),
                      ],
                    ),
                    Text(
                      '${package.teacherName}',
                      style: TextStyle(fontSize: 14.fSize),
                    ),
                  ],
                ),

                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset('assets/svg/location.svg'),
                        SizedBox(width: 5),
                        Text(
                          'Location: ',
                          style: TextStyle(fontSize: 14.fSize),
                        ),
                      ],
                    ),
                    Text(
                      '${package.locationName}',
                      style: TextStyle(fontSize: 14.fSize),
                    ),
                  ],
                ),

                Visibility(
                  visible: package.danceOrMusic != "Dance Classes",
                  child: SizedBox(height: 10.h),
                ),
                Visibility(
                  visible: package.danceOrMusic != "Dance Classes",
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset('assets/svg/remaining.svg'),
                          SizedBox(width: 5),
                          Text(
                            'Remaining Cancellation (Classes):',
                            style: TextStyle(fontSize: 14.fSize),
                          ),
                        ],
                      ),
                      Text(
                        '${package.remainingCancellations}/${package.totalAllowedCancellation}',
                        style: TextStyle(fontSize: 14.fSize),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset('assets/svg/freez.svg'),
                        SizedBox(width: 5),
                        Text(
                          "Freezing Remaining (Weeks):",
                          style: TextStyle(fontSize: 14.fSize),
                        ),
                      ],
                    ),

                    Text(
                      '${package.totalAllowedFreezings - package.totalFreezingTaken}/${package.totalAllowedFreezings}',
                      style: TextStyle(fontSize: 14.fSize),
                    ),
                  ],
                ),

                Visibility(
                  visible: package.danceOrMusic != "Dance Classes",
                  child: SizedBox(height: 10.h),
                ),
                Visibility(
                  visible: package.danceOrMusic != "Dance Classes",
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset('assets/svg/unscheduled.svg'),
                          SizedBox(width: 5),
                          Text(
                            'Unscheduled Count:',
                            style: TextStyle(fontSize: 14.fSize),
                          ),
                        ],
                      ),
                      Text(
                        '${unbookedClasses.isNegative ? 0 : unbookedClasses}',
                        style: TextStyle(fontSize: 14.fSize),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.exit_to_app_rounded,
                          size: 16.adaptSize,
                          color: Colors.red,
                        ),
                        SizedBox(width: 3),
                        Text(
                          "Package Expiry:",
                          style: TextStyle(
                            fontSize: 14.fSize,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),

                    Text(
                      DateFormat(
                        'd MMM yyyy',
                      ).format(DateTime.parse(package.packageExpiry)),
                      style: TextStyle(fontSize: 14.fSize, color: Colors.red),
                    ),
                  ],
                ),
                package.danceOrMusic == "Dance Classes"
                    ? SizedBox(height: 20.h)
                    : const Spacer(),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 2.0),
                    child: Container(
                      height: 45.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12.adaptSize),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'View Package Details',
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: 14.fSize,
                          fontWeight: FontWeight.w600,
                          decorationColor: AppColors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
