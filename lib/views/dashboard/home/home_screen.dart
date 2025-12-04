import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:melodica_app_new/constants/app_colors.dart';
import 'package:melodica_app_new/models/student_model.dart';
import 'package:melodica_app_new/routes/routes.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';
import 'package:melodica_app_new/views/dashboard/home/widget/custom_student_item_widget.dart';
import 'package:melodica_app_new/widgets/custom_app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Main Content
            Column(
              children: [
                Divider(),
                SizedBox(height: 16.h),
                // Welcome Banner
                Container(
                  height: 96.h,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Keep Shine in the Worlds',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                      Stack(
                        children: [
                          const Text('🎹', style: TextStyle(fontSize: 60)),
                          Positioned(
                            right: -10,
                            top: -10,
                            child: Text('✨', style: TextStyle(fontSize: 20)),
                          ),
                          Positioned(
                            right: 20,
                            top: 10,
                            child: Text('✨', style: TextStyle(fontSize: 16)),
                          ),
                          Positioned(
                            right: -5,
                            bottom: 15,
                            child: Text('✨', style: TextStyle(fontSize: 14)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 25.h),
                // Category Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCategoryCard(
                        'assets/svg/music_class.svg',
                        'Music Class',
                        onTap: () {
                          print('1');
                        },
                      ),
                      const SizedBox(width: 16),
                      _buildCategoryCard(
                        'assets/svg/dance_class.svg',
                        'Dance Class',
                        onTap: () {
                          print('2');
                        },
                      ),
                      const SizedBox(width: 16),
                      _buildCategoryCard(
                        'assets/svg/packages.svg',
                        'Packages',
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.packageSelection,
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      _buildCategoryCard(
                        'assets/svg/online_store.svg',
                        'Online Store',
                        onTap: () {
                          print('4');
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Container(
                  padding: EdgeInsets.only(left: 12, right: 12, top: 15),
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Color(0xffF7F7F7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xffE2E2E2)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Text(
                                'Upcoming Classes',
                                style: TextStyle(
                                  fontSize: 16.fSize,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text('Today Scheduled Classes'),
                            ],
                          ),
                          Icon(Icons.arrow_forward),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      ListView.separated(
                        itemCount: 2,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 12.h),
                        itemBuilder: (context, index) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Color(0xffE2E2E2)),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 2,
                                horizontal: 12,
                              ),
                              visualDensity: VisualDensity(vertical: 2),
                              tileColor: Colors.white,

                              leading: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Wed'),
                                  Container(
                                    height: 30,
                                    width: 30,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: AppColors.primary,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '5',
                                        style: TextStyle(
                                          fontSize: 16.fSize,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text('Nov'),
                                ],
                              ),
                              title: Text(
                                'Basic Of Piano',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16.fSize,
                                ),
                              ),
                              subtitle: Text('Class of Ms Sara'),
                              trailing: Text(
                                '4:00PM',
                                style: TextStyle(
                                  fontSize: 12.fSize,
                                  color: Colors.grey[500],
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
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    String emoji,
    String label, {
    required void Function()? onTap,
  }) {
    return Expanded(
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: SvgPicture.asset(emoji),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.fSize,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
