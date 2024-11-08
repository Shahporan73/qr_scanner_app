// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ResultScreen extends StatelessWidget {
  final String code;
  final bool isLink;

  const ResultScreen({super.key, required this.code, required this.isLink});

  @override
  Widget build(BuildContext context) {
    print('Scanned Code: $code');
    print('Is Link: $isLink');

    return Scaffold(
      appBar: AppBar(
        title: Text('Scanned Result'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Result:',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              code,
              style: TextStyle(
                  fontSize: 16,
                color: isLink? Colors.blue : Colors.black,
                  decoration: isLink ? TextDecoration.underline : TextDecoration.none
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Content Type:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              isLink ? 'Link' : 'Text',
              style: TextStyle(
                fontSize: 16,
                color: isLink ? Colors.blue : Colors.black54,
              ),
            ),
            if (isLink)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => WebViewScreen(url: code),
                    ));
                  },
                  child: Text('Open Link in App'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}






// Updated WebView screen for displaying links within the app
class WebViewScreen extends StatefulWidget {
  final String url;

  const WebViewScreen({super.key, required this.url});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(title: Text('WebView')),
      body: SafeArea(
          child: Padding(
              padding: EdgeInsets.all(0.0),
              child: WebViewWidget(controller: _controller)
          ),
      ),
    );
  }
}