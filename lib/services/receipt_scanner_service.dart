import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class ReceiptScannerService {
  final TextRecognizer _textRecognizer = TextRecognizer();
  final ImagePicker _imagePicker = ImagePicker();

  // Scan receipt from camera
  Future<ReceiptData?> scanFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image == null) return null;

      return await _processImage(File(image.path));
    } catch (e) {
      print('Error scanning from camera: $e');
      return null;
    }
  }

  // Scan receipt from gallery
  Future<ReceiptData?> scanFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return null;

      return await _processImage(File(image.path));
    } catch (e) {
      print('Error scanning from gallery: $e');
      return null;
    }
  }

  // Process image and extract receipt data
  Future<ReceiptData> _processImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(
        inputImage,
      );

      // Extract data from recognized text
      final amount = _extractAmount(recognizedText.text);
      final date = _extractDate(recognizedText.text);
      final merchant = _extractMerchant(recognizedText.text);
      final items = _extractItems(recognizedText.text);

      return ReceiptData(
        amount: amount,
        date: date,
        merchant: merchant,
        items: items,
        rawText: recognizedText.text,
        imagePath: imageFile.path,
      );
    } catch (e) {
      print('Error processing image: $e');
      rethrow;
    }
  }

  // Extract amount from text
  double? _extractAmount(String text) {
    try {
      // Look for patterns like: $XX.XX, XX.XX, TOTAL: XX.XX
      final patterns = [
        RegExp(r'\$\s*(\d+\.?\d*)'),
        RegExp(r'total[:\s]*\$?\s*(\d+\.?\d*)', caseSensitive: false),
        RegExp(r'amount[:\s]*\$?\s*(\d+\.?\d*)', caseSensitive: false),
        RegExp(r'(\d+\.\d{2})'),
      ];

      for (var pattern in patterns) {
        final match = pattern.firstMatch(text);
        if (match != null) {
          final amountStr = match.group(1);
          if (amountStr != null) {
            return double.tryParse(amountStr);
          }
        }
      }

      return null;
    } catch (e) {
      print('Error extracting amount: $e');
      return null;
    }
  }

  // Extract date from text
  DateTime? _extractDate(String text) {
    try {
      // Look for date patterns: MM/DD/YYYY, DD/MM/YYYY, YYYY-MM-DD
      final patterns = [
        RegExp(r'(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})'),
        RegExp(r'(\d{4})[/-](\d{1,2})[/-](\d{1,2})'),
      ];

      for (var pattern in patterns) {
        final match = pattern.firstMatch(text);
        if (match != null) {
          try {
            final part1 = int.parse(match.group(1)!);
            final part2 = int.parse(match.group(2)!);
            final part3 = int.parse(match.group(3)!);

            // Try different date formats
            if (part1 > 1000) {
              // YYYY-MM-DD
              return DateTime(part1, part2, part3);
            } else if (part3 > 1000) {
              // MM/DD/YYYY or DD/MM/YYYY
              if (part1 <= 12) {
                return DateTime(part3, part1, part2);
              } else {
                return DateTime(part3, part2, part1);
              }
            } else {
              // MM/DD/YY or DD/MM/YY
              final year = part3 < 100 ? 2000 + part3 : part3;
              if (part1 <= 12) {
                return DateTime(year, part1, part2);
              } else {
                return DateTime(year, part2, part1);
              }
            }
          } catch (e) {
            continue;
          }
        }
      }

      return null;
    } catch (e) {
      print('Error extracting date: $e');
      return null;
    }
  }

  // Extract merchant name from text
  String? _extractMerchant(String text) {
    try {
      // Usually the merchant name is at the top of the receipt
      final lines = text.split('\n');
      if (lines.isNotEmpty) {
        // Return first non-empty line
        for (var line in lines) {
          final trimmed = line.trim();
          if (trimmed.isNotEmpty && trimmed.length > 2) {
            return trimmed;
          }
        }
      }
      return null;
    } catch (e) {
      print('Error extracting merchant: $e');
      return null;
    }
  }

  // Extract items from text
  List<ReceiptItem> _extractItems(String text) {
    try {
      final items = <ReceiptItem>[];
      final lines = text.split('\n');

      for (var line in lines) {
        // Look for lines with item name and price
        final match = RegExp(r'(.+?)\s+\$?\s*(\d+\.?\d*)').firstMatch(line);
        if (match != null) {
          final name = match.group(1)?.trim();
          final priceStr = match.group(2);

          if (name != null && priceStr != null) {
            final price = double.tryParse(priceStr);
            if (price != null && price > 0 && price < 10000) {
              items.add(ReceiptItem(name: name, price: price));
            }
          }
        }
      }

      return items;
    } catch (e) {
      print('Error extracting items: $e');
      return [];
    }
  }

  // Dispose resources
  void dispose() {
    _textRecognizer.close();
  }
}

// Receipt Data Model
class ReceiptData {
  final double? amount;
  final DateTime? date;
  final String? merchant;
  final List<ReceiptItem> items;
  final String rawText;
  final String imagePath;

  ReceiptData({
    this.amount,
    this.date,
    this.merchant,
    this.items = const [],
    required this.rawText,
    required this.imagePath,
  });
}

// Receipt Item Model
class ReceiptItem {
  final String name;
  final double price;

  ReceiptItem({required this.name, required this.price});
}
