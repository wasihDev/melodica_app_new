import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:melodica_app_new/providers/services_provider.dart';
import 'package:melodica_app_new/utils/responsive_sizer.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';

class SignaturePad extends StatefulWidget {
  final Function(Uint8List?) onSave;

  const SignaturePad({super.key, required this.onSave});

  @override
  State<SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {
  ServicesProvider? _provider;
  Timer? _debounce;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final provider = Provider.of<ServicesProvider>(context);

    if (_provider != provider) {
      _provider = provider;

      // 🔥 REMOVE old listeners to avoid duplicates
      provider.signratureCtrl.removeListener(_onSignatureChange);
      provider.signratureCtrl.addListener(_onSignatureChange);
    }
  }

  void _onSignatureChange() {
    final provider = _provider!;
    if (provider.signratureCtrl.isEmpty) return;

    // debounce saving
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final data = await provider.signratureCtrl.toPngBytes();
      widget.onSave(data);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _provider?.signratureCtrl.removeListener(_onSignatureChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ServicesProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            Container(
              height: 140.h,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Signature(
                controller: provider.signratureCtrl,
                backgroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 8.h),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  provider.signratureCtrl.clear();
                  widget.onSave(null);
                },
                child: Text(
                  'Clear',
                  style: TextStyle(color: Colors.black, fontSize: 16.fSize),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
