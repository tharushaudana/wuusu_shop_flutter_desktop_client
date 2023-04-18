import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:wuusu_shop_client/alert.dart';
import 'package:wuusu_shop_client/apicall.dart';

class PdfViewer extends StatefulWidget {
  final ApiCall apiCall;
  final String invoice_id;
  String theme = 'ctec';

  PdfViewer({
    required this.apiCall,
    required this.invoice_id,
    required this.theme,
  });

  static show({
    required BuildContext context,
    required ApiCall apiCall,
    required String invoice_id,
    required String theme,
  }) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(invoice_id),
          content: SizedBox(
            height: 500,
            width: 400,
            child: PdfViewer(
                apiCall: apiCall, invoice_id: invoice_id, theme: theme),
          ),
        );
      },
    );
  }

  @override
  State<StatefulWidget> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  bool isDisposed = false;
  bool isRetriving = false;

  late Uint8List pdfBytes;

  safeCall(func) {
    if (isDisposed) return;
    func();
  }

  retrivePdf() async {
    safeCall(() => setState(() => isRetriving = true));

    try {
      Uint8List? bytes = await widget.apiCall
          .get("/pdf/invoice/${widget.invoice_id}")
          .param("theme", widget.theme)
          .callForBytes();

      pdfBytes = bytes!;

      safeCall(() {
        setState(() => isRetriving = false);
      });
    } catch (e) {
      safeCall(() {
        setState(() => isRetriving = false);
        Alert.show("PDF Retriving Failed", e.toString(), context);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    retrivePdf();
  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //width: double.infinity,
      //height: double.infinity,
      child: isRetriving
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "PDF Retriving...",
                  style: TextStyle(fontSize: 12),
                ),
              ],
            )
          : SafeArea(
              child: PdfPreview(
                build: (format) => pdfBytes,
              ),
            ),
    );
  }
}
