import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:master_aid/models/pdf_character_data.dart';
import 'package:master_aid/services/pdf_import_service.dart';

void main() {
  group('PdfImportService', () {
    test('extracts AcroForm data from PDF fixture', () async {
      final pdfFile = File('test/fixtures/sample_character.pdf');

      if (!await pdfFile.exists()) {
        debugPrint('Sample PDF not found - skipping fixture test');
        return;
      }

      final fields = await PdfImportService.extractAcroFormData(pdfFile);
      expect(fields, isA<Map<String, String>>());
      // Fixture must contain at least the key WotC fields
      expect(fields.containsKey('CharacterName'), isTrue);
      expect(fields.containsKey('ClassLevel'), isTrue);
      expect(fields.containsKey('HPMax'), isTrue);
      expect(fields.containsKey('STR'), isTrue);
    });

    test('identifies official WotC character sheet as true', () async {
      final pdfFile = File('test/fixtures/sample_character.pdf');

      if (!await pdfFile.exists()) {
        debugPrint('Sample PDF not found - skipping fixture test');
        return;
      }

      final isWotc = await PdfImportService.isWotcCharacterSheet(pdfFile);
      expect(isWotc, isTrue);
    });
  });

  group('PdfCharacterData', () {
    test('creates from real WotC field names', () {
      // Field names verified against official D&D Beyond fillable PDF
      final fields = {
        'CharacterName': 'Gandalf',
        'ClassLevel': 'Wizard 5',
        'Race ': 'Human', // trailing space as in real PDF
        'Background': 'Sage',
        'PlayerName': 'Bilbo',
        'STR': '10',
        'DEX': '14',
        'CON': '12',
        'INT': '18',
        'WIS': '16',
        'CHA': '13',
        'AC': '15',
        'HPMax': '32',
        'HD': '5',
        'Initiative': '2',
        'Speed': '30',
      };

      final data = PdfCharacterData.fromFieldMap(fields);
      expect(data.name, 'Gandalf');
      expect(data.classLevel, 'Wizard 5');
      expect(data.race, 'Human');
      expect(data.background, 'Sage');
      expect(data.playerName, 'Bilbo');
      expect(data.level, 5); // parsed from 'Wizard 5'
      expect(data.strength, 10);
      expect(data.dexterity, 14);
      expect(data.constitution, 12);
      expect(data.intelligence, 18);
      expect(data.wisdom, 16);
      expect(data.charisma, 13);
      expect(data.armorClass, 15);
      expect(data.maxHitPoints, 32);
      expect(data.hitDice, 5);
      expect(data.initiative, 2);
      expect(data.speed, 30);
    });

    test('parses level from ClassLevel string', () {
      final fields = {'ClassLevel': 'Fighter 10'};
      final data = PdfCharacterData.fromFieldMap(fields);
      expect(data.level, 10);
    });

    test('extracts skills with correct WotC field names', () {
      final fields = {
        'Acrobatics': '4',
        'Animal': '2', // real field name for Animal Handling
        'Deception ': '3', // trailing space
        'Perception ': '5', // trailing space
        'Stealth ': '6', // trailing space
        'SleightofHand': '1',
      };

      final data = PdfCharacterData.fromFieldMap(fields);
      expect(data.skills['Acrobatics'], 4);
      expect(data.skills['Animal Handling'], 2);
      expect(data.skills['Deception'], 3);
      expect(data.skills['Perception'], 5);
      expect(data.skills['Stealth'], 6);
      expect(data.skills['Sleight of Hand'], 1);
    });

    test('extracts spells with non-sequential WotC field names', () {
      final fields = {
        'Spells 1014': 'Fireball',
        'Spells 1015': 'Magic Missile',
        'Spells 1099': 'Wish',
      };

      final data = PdfCharacterData.fromFieldMap(fields);
      expect(data.spells, containsAll(['Fireball', 'Magic Missile', 'Wish']));
    });
  });
}
