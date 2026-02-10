import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:melodica_app_new/constants/app_colors.dart';
import 'package:melodica_app_new/models/services_model.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';

class PackageCard extends StatelessWidget {
  final ServiceModel package;
  bool isSelected;
  void Function()? onTap;

  PackageCard({
    super.key,
    required this.package,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // The main display text for the package (e.g., "12 Classes" or "7 Weeks")
    final packageDisplay = package.sessionstext;
    // print(
    //   '${package.price / package.sessions} package.sessions ${package.sessions}',
    // );
    // final perClassCost =
    //     ((package.price - int.parse(package.discount)) / package.sessions)
    //         .toStringAsFixed(0);
    final double discountedPrice = double.parse(package.discount.toString());
    final double sessions = package.sessions.toDouble();
    final discountedAmount = package.price * (discountedPrice / 100);
    final String perClassCost = ((package.price - discountedAmount) / sessions)
        .toStringAsFixed(2);

    return InkWell(
      onTap: onTap,

      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.fromLTRB(16, 0, 0, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Stack(
          children: [
            // Main Content
            Padding(
              padding: const EdgeInsets.only(right: 70.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 15),
                  // Text(
                  //   "",
                  //   // package.packageName
                  //   style: const TextStyle(
                  //     fontSize: 16,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  Text(
                    packageDisplay,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Class Cancellations : ${package.cancellations.toString()}",
                    style: TextStyle(
                      fontSize: 12.fSize,
                      color: Colors.grey[600]!,
                    ),
                  ),
                  Text(
                    "Freezing Weeks: ${package.freezings}",
                    style: TextStyle(
                      fontSize: 12.fSize,
                      color: Colors.grey[600]!,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

            // Discount Tag and Radio Button (Positioned top right)
            Positioned(
              top: 0,
              right: 0,
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Discount Tag
                      // CustomRibbonTag(
                      //   text: '20% OFF',
                      //   color: Theme.of(context).colorScheme.primary,
                      // ),
                      // Container(
                      //   height: 40,
                      //   width: 40,
                      //   decoration: BoxDecoration(
                      //     // color: Colors.red,
                      //     image: DecorationImage(
                      //       scale: 2.5,
                      //       invertColors: false,
                      //       image: AssetImage('assets/images/off.png'),
                      //     ),
                      //   ),
                      //   child: Text('sad'),
                      // ),
                      Stack(
                        children: [
                          Image.asset(
                            'assets/images/off.png',
                            scale: 2.5,
                            color: AppColors.primary,
                          ),
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              color: Colors.transparent,
                              child: Column(
                                children: [
                                  Text(
                                    "${package.discount}%",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    "OFF",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),

                      // Radio Button
                      Padding(
                        padding: const EdgeInsets.only(top: 14.0, right: 16.0),
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                            color: isSelected ? AppColors.black : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),

                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.end,
                      // crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(height: 8),
                        Row(
                          children: [
                            SvgPicture.asset('assets/svg/dirham.svg'),
                            Text(
                              ' ${package.price}', // Using the currency symbol from the image
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Text(
                          '$perClassCost per Class',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
