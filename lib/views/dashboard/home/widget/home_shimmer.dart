import 'package:flutter/material.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';

class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(4, (index) => _classCardShimmer()),
      ),
    );
  }

  /// Upcoming class card shimmer
  Widget _classCardShimmer() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      ),
      child: Column(
        children: [
          _box(width: 200.w, height: 35.h),
          const SizedBox(height: 6),
          _box(width: 2, height: 35.h, radius: 8),
          const SizedBox(height: 6),
          _box(width: 2, height: 35.h),
        ],
      ),
    );
  }

  /// Reusable shimmer box
  Widget _box({
    required double width,
    required double height,
    double radius = 6,
  }) {
    return Container(
      // width: width,
      // height: height,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
