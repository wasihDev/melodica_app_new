import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  final String url;
  final String title;

  const WebViewPage({super.key, required this.url, required this.title});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController controller;
  bool isLoading = true; // 1. Track loading state

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isLoading = true; // Start showing spinner
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false; // Hide spinner
            });
          },
          onWebResourceError: (WebResourceError error) {
            // Handle errors here if needed
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(widget.title, style: const TextStyle(color: Colors.black)),
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.blue, // Match your app theme
              ),
            )
          : WebViewWidget(controller: controller),
    );
  }
}
