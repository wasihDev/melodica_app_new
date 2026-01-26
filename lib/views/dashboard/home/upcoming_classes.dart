import 'package:flutter/material.dart';
import 'package:melodica_app_new/constants/app_colors.dart';
import 'package:melodica_app_new/providers/schedule_provider.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';
import 'package:provider/provider.dart';

class UpcomingClasses extends StatelessWidget {
  const UpcomingClasses({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upcoming Classes'),
        backgroundColor: Colors.white,
      ),
      body: Consumer<ScheduleProvider>(
        builder: (context, provider, child) {
          return Container(
            // height: 350.h,
            margin: EdgeInsets.symmetric(horizontal: 12),
            color: Colors.transparent,
            child: ListView.separated(
              itemCount: provider.schedules.length,
              shrinkWrap: true,
              // physics: NeverScrollableScrollPhysics(),
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                return ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 2,
                    horizontal: 12,
                  ),
                  visualDensity: VisualDensity(vertical: 2),
                  tileColor: Colors.white,
                  //
                  leading: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${provider.schedules[index].bookingDay}'),
                      Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.primary,
                        ),
                        child: Center(
                          child: Text(
                            provider.schedules[index].day.toString(),
                            style: TextStyle(
                              fontSize: 14.fSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Text('${provider.schedules[index].monthShort}'),
                    ],
                  ),
                  title: Text(
                    provider.schedules[index].subject,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16.fSize,
                    ),
                  ),
                  subtitle: Text(provider.schedules[index].bookingRoom),
                  trailing: Text(
                    provider.schedules[index].time.toString(),
                    style: TextStyle(
                      fontSize: 12.fSize,
                      color: Colors.grey[500],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
