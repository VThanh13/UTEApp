import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';

class PDFViewerPage extends StatefulWidget {
  final File file;

  const PDFViewerPage({super.key,
    required this.file,
  }) ;

  @override
  State<PDFViewerPage> createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  late PDFViewController controller;
  int pages = 0;
  int indexPage = 0;

  @override
  void initState() {
    super.initState();
    // final url =
    //     'https://www.adobe.com/support/products/enterprise/knowledgecenter/media/c4611_sample_explain.pdf';
    // final file = PDFApi.loadNetwork(url);
  }
  @override
  Widget build(BuildContext context) {
    const name = 'PDF File';
    final text = '${indexPage + 1} of $pages';

    return Scaffold(
      appBar: AppBar(
        title: const Text(name),
        backgroundColor: Colors.blue,
        actions: pages >= 2
            ? [
          Center(child: Text(text)),
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 32),
            onPressed: () {
              final page = indexPage == 0 ? pages : indexPage - 1;
              controller.setPage(page);
            },
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 32),
            onPressed: () {
              final page = indexPage == pages - 1 ? 0 : indexPage + 1;
              controller.setPage(page);
            },
          ),
        ]
            : null,
      ),
      body: PDFView(
        filePath: widget.file.path,
        // autoSpacing: false,
        // swipeHorizontal: true,
        // pageSnap: false,
        // pageFling: false,
        onRender: (pages) => setState(() => this.pages = pages!),
        onViewCreated: (controller) =>
            setState(() => this.controller = controller),
        onPageChanged: (indexPage, _) =>
            setState(() => this.indexPage = indexPage!),
      ),
    );
  }
}

class PDFApi {
  static Future<File> loadNetwork(String url) async {
    final response = await http.get(Uri.parse(url));
    final bytes = response.bodyBytes;

    return _storeFile(url, bytes);
  }
  static Future<File> _storeFile(String url, List<int> bytes) async {
    final filename = basename(url);
    final dir = await getApplicationDocumentsDirectory();

    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }
}