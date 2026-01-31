import 'package:flutter/material.dart';
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
  // late Future<List<Package>> _packagesFuture;
  late TabController _tabController;
  // final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // WidgetsBinding.instance.addPostFrameCallback((asy) async {
    //   final provider = context.read<PackageProvider>();
    //   // if (provider.packages.isEmpty) {
    //   await provider.fetchPackages(context);
    //   setState(() {});
    //   // }
    // });
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
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.error != null) {
                return Center(child: Text(provider.error!));
              }

              if (provider.packages.isEmpty) {
                return const Center(child: Text('Please wait....'));
              }

              // if (snapshot.connectionState == ConnectionState.waiting) {
              //   return const Center(child: CircularProgressIndicator());
              // } else if (snapshot.hasError) {
              //   return Center(child: Text('Error: ${snapshot.error}'));
              // } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              //   return const Center(child: Text('No packages found.'));
              // }

              final activePackages = provider.packages
                  .where((p) => p.packageStatus != 'Completed')
                  .toList();
              final completedPackages = provider.packages
                  .where((p) => p.packageStatus == 'Completed')
                  .toList();
              print('provider ${provider.servicesProvider.currentPaymentType}');
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

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: packages.length,
      separatorBuilder: (context, index) => SizedBox(height: 15),
      itemBuilder: (context, index) {
        final package = packages[index];
        final remainingFreezes =
            package.totalAllowedFreezings - package.totalFreezingTaken;
        // print('package.packageExpiry ${package.packageExpiry}');
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
            height: 285.h,
            width: double.infinity,
            padding: EdgeInsets.all(12),
            margin: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Color(0xffF7F7F7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  tileColor: Colors.grey[300],

                  title: Text('${package.itemName}'),
                  subtitle: Text(package.locationName),
                  trailing: Text(
                    '${package.remainingSessions.toString().split('.').first}/${package.totalClasses}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Container(
                        height: 80.h,
                        width: double.infinity,
                        padding: EdgeInsets.only(top: 8, left: 14),
                        // alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total Classes'),
                            SizedBox(height: 8),
                            Text(
                              package.totalClasses.toString(),
                              style: TextStyle(
                                fontSize: 18.fSize,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        height: 80.h,

                        width: double.infinity,
                        padding: EdgeInsets.only(top: 8, left: 14),
                        // alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Remaining Classes'),
                            SizedBox(height: 8),
                            Text(
                              package.remainingSessions
                                  .toString()
                                  .split('.')
                                  .first,
                              style: TextStyle(
                                fontSize: 18.fSize,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Remaining Cancellation: ${package.remainingCancellations}X',
                    ),
                    Text(
                      'Expiry: ${formatCreatedOss(package.packageExpiry)}',
                      style: TextStyle(color: Colors.red, fontSize: 12.fSize),
                    ),
                  ],
                ),
                SizedBox(height: 10),

                SizedBox(height: 10),
                Text('Remaining Freezing : ${remainingFreezes} Week'),
              ],
            ),
          ),
        );
      },
    );
  }
}
