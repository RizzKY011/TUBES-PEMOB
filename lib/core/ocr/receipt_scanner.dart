import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ReceiptScanner {
  static final TextRecognizer _textRecognizer = TextRecognizer();

  static Future<ReceiptData?> scanReceipt(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      if (!imageFile.existsSync()) return null;

      final InputImage inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      return _parseReceiptText(recognizedText.text);
    } catch (e) {
      print('OCR Error: $e');
      return null;
    }
  }

  static ReceiptData? _parseReceiptText(String text) {
    final lines = text.split('\n');
    double? total;
    List<String> items = [];
    String? merchant;

    // Look for total amount (various patterns)
    for (final line in lines) {
      final cleanLine = line.trim();
      
      // Skip empty lines
      if (cleanLine.isEmpty) continue;

      // Look for merchant name (usually at the top)
      if (merchant == null && cleanLine.length > 3 && cleanLine.length < 50) {
        if (!_isNumeric(cleanLine) && !cleanLine.contains('Rp') && !cleanLine.contains('IDR')) {
          merchant = cleanLine;
        }
      }

      // Look for total amount patterns
      if (total == null) {
        final totalMatch = _extractTotal(cleanLine);
        if (totalMatch != null) {
          total = totalMatch;
        }
      }

      // Look for item patterns (price + description)
      final itemMatch = _extractItem(cleanLine);
      if (itemMatch != null) {
        items.add(itemMatch);
      }
    }

    return ReceiptData(
      merchant: merchant ?? 'Unknown Merchant',
      total: total ?? 0.0,
      items: items,
      rawText: text,
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

  ReceiptData({
    required this.merchant,
    required this.total,
    required this.items,
    required this.rawText,
  });

  @override
  String toString() {
    return 'ReceiptData(merchant: $merchant, total: $total, items: ${items.length})';
  }
}

