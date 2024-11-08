// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
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
        title: Text(
          'Scanned Result',
          style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        centerTitle: true,
        backgroundColor: Colors.pinkAccent,
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

            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(
                  width: 0.5, color: Colors.grey
                ),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ]
              ),
              child: Text(
                code,
                style: TextStyle(
                    fontSize: 16,
                    color: isLink ? Color(0xff0A84FF) : Colors.black,
                    decoration:
                    isLink ? TextDecoration.underline : TextDecoration.none,
                  decorationColor: Colors.blue
                ),
              ),
            ),

            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: code));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Copied to clipboard')),
                      );
                    },
                    child: Text('Copy', style: TextStyle(color: Colors.white),),
                  ),
                ),
                SizedBox(width: 20),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
                    onPressed: () {
                      Share.share(code);
                    },
                    child: Text('Share', style: TextStyle(color: Colors.white),),
                  ),
                ),
              ],
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
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => WebViewScreen(url: code),
                    ));
                  },
                  child: Text('Open the link', style: TextStyle(color: Colors.white),),
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
            child: WebViewWidget(controller: _controller)),
      ),
    );
  }
}
