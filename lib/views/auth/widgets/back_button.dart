import 'package:flutter/material.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(16.adaptSize),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.adaptSize),
        onTap: () {
          Navigator.pop(context);
        },
        child: Ink(
          height: 40.h,
          width: 40.w,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(16.adaptSize),
          ),
          child: const Center(child: Icon(Icons.arrow_back)),
        ),
      ),
    );
  }
}

class AppBackButtonItems extends StatelessWidget {
  const AppBackButtonItems({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5.adaptSize),
      decoration: BoxDecoration(
        // color: Colors.transparent,
        color: Theme.of(context).listTileTheme.tileColor,
        borderRadius: BorderRadius.circular(15.adaptSize),
        boxShadow: [
          BoxShadow(
            blurRadius: 10.0,
            spreadRadius: 3.0,
            offset: const Offset(0, 1),
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[900]!
                : Colors.grey[200]!,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14.adaptSize),
          onTap: () async {
            // await DefaultCacheManager().emptyCache(); // clears disk
            // imageCache.clear();
            // imageCache.clearLiveImages();
            // provider.clearList();
            // provider.isHoldOn(false);
            // Navigator.pop(context);
            // context.showInterstitialAd(
            //   buttonId: "back_button",
            //   context,
            //   adUnitId: AdsUnit.adUnitIdInterstitialApp(),
            //   onComplete: () {
            //     provider.clearList();
            //     provider.isHoldOn(false);
            //     Navigator.pop(context);
            //   },
            // );
          },
          child: const Center(child: Icon(Icons.arrow_back)),
        ),
      ),
    );
  }
}
