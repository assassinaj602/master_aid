import 'package:flutter_test/flutter_test.dart';
import 'package:master_aid/services/character_import_mapper.dart';
import 'package:master_aid/models/pdf_character_data.dart';

void main() {
  group('CharacterImportMapper', () {
    late PdfCharacterData sampleData;

    setUp(() {
      sampleData = PdfCharacterData(
        name: 'Aragorn',
        classLevel: 'Fighter 5',
        race: 'Human',
        background: 'Soldier',
        playerName: 'Player1',
        level: 5,
        strength: 16,
        dexterity: 14,
        constitution: 15,
        intelligence: 10,
        wisdom: 12,
        charisma: 11,
        skills: {'Athletics': 1, 'Perception': 1, 'Survival': 1},
        armorClass: 18,
        initiative: 2,
        speed: 30,
        maxHitPoints: 45,
        hitDice: 5,
      );
    });

    test('converts PdfCharacterData to PGBase', () {
      final pgBase = CharacterImportMapper.toPgBase(sampleData);

      expect(pgBase.nome, 'Aragorn');
      expect(pgBase.classe, 'Fighter');
      expect(pgBase.livello, 5);
      expect(pgBase.specie, 'Human');
      expect(pgBase.puntiVita, 45);
      expect(pgBase.caratteristiche['FOR'], 16);
      expect(pgBase.caratteristiche['DES'], 14);
      expect(pgBase.caratteristiche['COS'], 15);
      expect(pgBase.competenze, contains('Athletics'));
      expect(pgBase.competenze, contains('Perception'));
    });

    test('parses class from classLevel string', () {
      expect(_parseClassTest('Wizard 5'), 'Wizard');
      expect(_parseClassTest('Fighter'), 'Fighter');
      expect(_parseClassTest('Rogue 3'), 'Rogue');
    });

    test('validates complete data as valid', () {
      expect(CharacterImportMapper.isValidForImport(sampleData), true);
    });

    test('identifies missing fields', () {
      final incompleteData = PdfCharacterData(
        name: '',
        classLevel: '',
        race: '',
        background: '',
        playerName: '',
        level: 0,
        strength: 0,
        dexterity: 0,
        constitution: 0,
        intelligence: 0,
        wisdom: 0,
        charisma: 0,
        skills: {},
        armorClass: 0,
        initiative: 0,
        speed: 0,
        maxHitPoints: 0,
        hitDice: 0,
      );

      final missing = CharacterImportMapper.getMissingFields(incompleteData);
      expect(missing, contains('Nome'));
      expect(missing, contains('Classe/Livello'));
      expect(missing, contains('Razza'));
      expect(missing, contains('Forza'));
      expect(missing, contains('PF Massimi'));
    });
  });
}

// Helper for testing parsing
String _parseClassTest(String classLevel) {
  final parts = classLevel.trim().split(' ');
  if (parts.isNotEmpty) {
    if (int.tryParse(parts.last) != null) {
      return parts.sublist(0, parts.length - 1).join(' ');
    }
    return classLevel;
  }
  return 'Unknown';
}
