import 'package:flutter/material.dart';

class LoadingIndicatorWideget extends StatelessWidget {
  final Color? color;
  const LoadingIndicatorWideget({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(color: Colors.black);
    //
  }
}
