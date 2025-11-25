import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

class ReceiptScanner {
  static final TextRecognizer _textRecognizer = TextRecognizer();

  static Future<ReceiptData?> scanReceipt(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      if (!imageFile.existsSync()) {
        print('scanReceipt: file does not exist at $imagePath');
        return null;
      }

      final InputImage inputImage = InputImage.fromFile(imageFile);
  final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
  print('scanReceipt: OCR recognized text length=${recognizedText.text.length}');
  // debug print first 400 chars
  print('scanReceipt: recognizedText sample: ${recognizedText.text.substring(0, recognizedText.text.length > 400 ? 400 : recognizedText.text.length)}');

  final ReceiptData? parsed = _parseReceiptText(recognizedText.text);
      if (parsed == null) return null;
      // attach image path so UI can show thumbnail
      return ReceiptData(
        merchant: parsed.merchant,
        total: parsed.total,
        items: parsed.items,
        rawText: parsed.rawText,
        imagePath: imagePath,
      );
    } catch (e) {
      print('OCR Error: $e');
      return null;
    }
  }

  /// Accepts an [XFile] (from image_picker) and handles content URIs by
  /// copying bytes to a temporary file before scanning. This improves
  /// compatibility when users pick images from file explorer or other sources
  /// where the returned path may not be a direct filesystem path.
  static Future<ReceiptData?> scanReceiptFromXFile(XFile xfile) async {
    try {
      // If the XFile already exposes a path that exists on disk, use it.
      if (xfile.path.isNotEmpty) {
        final File f = File(xfile.path);
        if (await f.exists()) {
          return await scanReceipt(f.path);
        }
      }

      // Otherwise, read the bytes and write to a temp file.
      final List<int> bytes = await xfile.readAsBytes();
      final Directory tmp = Directory.systemTemp;
      final String name = 'receipt_${DateTime.now().millisecondsSinceEpoch}${p.extension(xfile.name)}';
      final File tmpFile = File(p.join(tmp.path, name));
      await tmpFile.writeAsBytes(bytes, flush: true);
      final ReceiptData? res = await scanReceipt(tmpFile.path);
      // Optionally delete the temp file later; keep it for debugging now.
      return res;
    } catch (e) {
      print('scanReceiptFromXFile error: $e');
      return null;
    }
  }

  static ReceiptData? _parseReceiptText(String text) {
    final lines = text.split('\n');
    double? total;
    List<String> items = [];
    String? merchant;

    // Improved parsing: iterate lines for merchant, items and try to find total.
    for (int i = 0; i < lines.length; i++) {
      final String line = lines[i].trim();
      if (line.isEmpty) continue;

      // Merchant: pick first non-numeric short line near the top (first 6 lines)
      if (merchant == null && i < 6 && line.length > 2 && line.length < 40 && !_isNumeric(line) && !line.toLowerCase().contains('cash') && !line.toLowerCase().contains('pos') ) {
        merchant = line;
      }

      // Items: capture lines that have a trailing number (price) or look like item descriptions
      final itemMatch = _extractItem(line);
      if (itemMatch != null) {
        items.add(itemMatch);
      }
    }

    // If we didn't find total via patterns, fallback: look for the largest numeric value in the entire text
    if (total == null) {
      final double? fallback = _extractLargestAmount(text);
      if (fallback != null) total = fallback;
    }

    return ReceiptData(
      merchant: merchant ?? 'Unknown Merchant',
      total: total ?? 0.0,
      items: items,
      rawText: text,
      imagePath: null,
    );
  }

  static double? _extractTotal(String line) {
    // Patterns for total: "Total: Rp 50,000", "TOTAL 50000", "Rp 50.000", etc.
    final patterns = [
      RegExp(r'total[:\s]*rp[:\s]*([0-9.,]+)', caseSensitive: false),
      RegExp(r'total[:\s]*([0-9.,]+)', caseSensitive: false),
      RegExp(r'rp[:\s]*([0-9.,]+)', caseSensitive: false),
      RegExp(r'([0-9.,]+)\s*rp', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(line);
      if (match != null) {
        final amountStr = match.group(1)?.replaceAll(',', '').replaceAll('.', '');
        if (amountStr != null) {
          final amount = double.tryParse(amountStr);
          if (amount != null && amount > 0) {
            return amount;
          }
        }
      }
    }
    return null;
  }

  static String? _extractItem(String line) {
    // Look for lines that might be items (contain price and description)
    if (line.contains('Rp') || line.contains('IDR') || RegExp(r'\d+').hasMatch(line)) {
      // Clean up the line
      final cleanLine = line.trim();
      if (cleanLine.length > 3 && cleanLine.length < 100) {
        return cleanLine;
      }
    }
    return null;
  }

  static double? _extractLargestAmount(String text) {
    // Find all numeric groups and return the largest plausible amount
    final Iterable<RegExpMatch> matches = RegExp(r'([0-9][0-9.,]{1,})').allMatches(text);
    double? maxVal;
    for (final m in matches) {
      String s = m.group(0) ?? '';
      // strip non-digits
      final String digits = s.replaceAll(RegExp(r'[^0-9]'), '');
      if (digits.isEmpty) continue;
      final double? v = double.tryParse(digits);
      if (v == null) continue;
      if (maxVal == null || v > maxVal) maxVal = v;
    }
    return maxVal;
  }

  static bool _isNumeric(String str) {
    return RegExp(r'^[0-9.,\s]+$').hasMatch(str);
  }

  static void dispose() {
    _textRecognizer.close();
  }
}

class ReceiptData {
  final String merchant;
  final double total;
  final List<String> items;
  final String rawText;
  final String? imagePath;

  ReceiptData({
    required this.merchant,
    required this.total,
    required this.items,
    required this.rawText,
    this.imagePath,
  });

  @override
  String toString() {
    return 'ReceiptData(merchant: $merchant, total: $total, items: ${items.length})';
  }
}

