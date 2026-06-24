import 'dart:typed_data';
import 'dart:ui';

import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/billing_constants.dart';
import '../models/receipt_model.dart';

class ReceiptPdfService {
  Future<Uint8List> buildReceiptPdf(ReceiptModel receipt) async {
    final document = PdfDocument();
    final page = document.pages.add();
    final font = PdfStandardFont(PdfFontFamily.helvetica, 14);
    final titleFont = PdfStandardFont(PdfFontFamily.helvetica, 20, style: PdfFontStyle.bold);
    double y = 24;
    void text(String value, {PdfFont? customFont}) {
      page.graphics.drawString(value, customFont ?? font, bounds: Rect.fromLTWH(24, y, page.getClientSize().width - 48, 28));
      y += 30;
    }

    text(BillingConstants.appName, customFont: titleFont);
    text('Receipt No: ${receipt.receiptNumber}');
    text('Date: ${DateFormat('yyyy/MM/dd HH:mm').format(receipt.createdAt)}');
    text('Collector: ${receipt.collectorName}');
    text('Subscriber: ${receipt.subscriberName}');
    text('Amount: ${receipt.amount.toStringAsFixed(2)} ${BillingConstants.currency}');
    text('Payment method: ${receipt.paymentMethod}');
    text('Thank you');
    final bytes = Uint8List.fromList(await document.save());
    document.dispose();
    return bytes;
  }

  Future<void> printReceipt(ReceiptModel receipt) async {
    final bytes = await buildReceiptPdf(receipt);
    await Printing.layoutPdf(name: 'receipt_${receipt.receiptNumber}.pdf', onLayout: (_) async => bytes);
  }

  Future<void> shareReceipt(ReceiptModel receipt) async {
    final bytes = await buildReceiptPdf(receipt);
    await Share.shareXFiles([XFile.fromData(bytes, mimeType: 'application/pdf', name: 'receipt_${receipt.receiptNumber}.pdf')], text: 'سند تحصيل ${receipt.receiptNumber}');
  }

  Future<void> sendViaWhatsApp(ReceiptModel receipt, String phone) async {
    final text = Uri.encodeComponent('سند تحصيل ${receipt.receiptNumber}\nالمبلغ: ${receipt.amount.toStringAsFixed(2)} ${BillingConstants.currency}');
    final uri = Uri.parse('https://wa.me/$phone?text=$text');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> sendViaTelegram(ReceiptModel receipt) async {
    final text = Uri.encodeComponent('سند تحصيل ${receipt.receiptNumber} - ${receipt.amount.toStringAsFixed(2)} ${BillingConstants.currency}');
    final uri = Uri.parse('https://t.me/share/url?url=&text=$text');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
