import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../core/logger.dart';

/// Service for extracting AcroForm data from WotC PDF character sheets
class PdfImportService {
  /// Extracts all AcroForm field values from a PDF file
  static Future<Map<String, String>> extractAcroFormData(File pdfFile) async {
    final Map<String, String> fieldValues = {};

    try {
      // Load PDF document
      final List<int> bytes = await pdfFile.readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: bytes);

      // Get the form (if exists)
      final form = document.form;
      // Iterate through all fields
      for (int i = 0; i < form.fields.count; i++) {
        final PdfField field = form.fields[i];
        final String? fieldName = field.name;
        final String? fieldValue = _getFieldValue(field);

        if (fieldName != null && fieldName.isNotEmpty) {
          fieldValues[fieldName] = fieldValue ?? '';
        }
      }

      document.dispose();
    } catch (e) {
      AppLogger.error('Error extracting PDF data', e);
      rethrow;
    }

    return fieldValues;
  }

  /// Gets the value from a PDF field (handles different field types)
  static String? _getFieldValue(PdfField field) {
    if (field is PdfTextBoxField) {
      return field.text;
    } else if (field is PdfComboBoxField) {
      return field.selectedValue;
    } else if (field is PdfCheckBoxField) {
      return field.isChecked ? '1' : '0';
    } else if (field is PdfRadioButtonListField) {
      return field.selectedValue;
    } else if (field is PdfListBoxField) {
      return field.selectedValues.isNotEmpty ? field.selectedValues.first : '';
    } else if (field is PdfSignatureField) {
      return null;
    }
    return null;
  }

  /// Checks if a PDF file is a valid WotC character sheet
  static Future<bool> isWotcCharacterSheet(File pdfFile) async {
    try {
      final Map<String, String> fields = await extractAcroFormData(pdfFile);
      // Check for WotC-specific field names
      final wotcFields = ['charactername', 'classlevel', 'playername', 'race'];
      for (String field in wotcFields) {
        if (fields.containsKey(field)) {
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
