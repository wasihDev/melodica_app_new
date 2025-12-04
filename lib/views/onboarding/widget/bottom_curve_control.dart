import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/onboarding_provider.dart';

class BottomCurveControls extends StatelessWidget {
  const BottomCurveControls();

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, prov, _) {
        final page = prov.page;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // This is intentionally empty because each page has its own curved container.
            const SizedBox(height: 12),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}
