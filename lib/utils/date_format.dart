import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatCreatedOn(String rawDate) {
  if (rawDate.isEmpty) return "";

  try {
    final date = DateFormat('d MMM yyyy hh:mm a').parse(rawDate);
    return DateFormat('d MMM yyyy').format(date);
  } catch (e) {
    debugPrint('Date parse error: $rawDate');
    return "";
  }
}
