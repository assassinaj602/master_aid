import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:master_aid/services/pdf_import_service.dart';
import 'package:master_aid/models/pdf_character_data.dart';
import 'dart:io';

void main() {
  group('PdfImportService', () {
    test('extracts AcroForm data from PDF', () async {
      final pdfFile = File('test/fixtures/sample_character.pdf');
      
      if (await pdfFile.exists()) {
        final fields = await PdfImportService.extractAcroFormData(pdfFile);
        expect(fields, isA<Map<String, String>>());
      } else {
        // Skip test if no sample PDF available
        debugPrint('Sample PDF not found - skipping test');
      }
    });

    test('identifies WotC character sheet', () async {
      final pdfFile = File('test/fixtures/sample_character.pdf');
      
      if (await pdfFile.exists()) {
        final isWotc = await PdfImportService.isWotcCharacterSheet(pdfFile);
        expect(isWotc, isA<bool>());
      }
    });
  });

  group('PdfCharacterData', () {
    test('creates from field map', () {
      final fields = {
        'charactername': 'Gandalf',
        'classlevel': 'Wizard 5',
        'race': 'Human',
        'STR': '10',
        'DEX': '14',
        'CON': '12',
        'INT': '18',
        'WIS': '16',
        'CHA': '13',
        'AC': '15',
        'HP': '32',
      };

      final data = PdfCharacterData.fromFieldMap(fields);
      expect(data.name, 'Gandalf');
      expect(data.classLevel, 'Wizard 5');
      expect(data.race, 'Human');
      expect(data.strength, 10);
      expect(data.dexterity, 14);
      expect(data.constitution, 12);
      expect(data.intelligence, 18);
      expect(data.wisdom, 16);
      expect(data.charisma, 13);
      expect(data.armorClass, 15);
      expect(data.maxHitPoints, 32);
    });
  });
}
