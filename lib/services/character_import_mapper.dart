import '../models/pdf_character_data.dart';
import '../factory_pg_base.dart';

/// Maps WotC PDF character data to PGBase model
class CharacterImportMapper {
  /// Converts PdfCharacterData to PGBase
  static PGBase toPgBase(PdfCharacterData pdfData) {
    final characteristics = {
      'FOR': pdfData.strength,
      'DES': pdfData.dexterity,
      'COS': pdfData.constitution,
      'INT': pdfData.intelligence,
      'SAG': pdfData.wisdom,
      'CAR': pdfData.charisma,
    };

    final modifiers = characteristics.map((key, value) {
      return MapEntry(key, ((value - 10) / 2).floor());
    });

    final competenze = <String>[];
    pdfData.skills.forEach((skill, value) {
      if (value > 0) {
        competenze.add(skill);
      }
    });

    return PGBase(
      nome: pdfData.name,
      specie: pdfData.race,
      classe: _parseClass(pdfData.classLevel),
      livello: pdfData.level > 0 ? pdfData.level : 1,
      background: pdfData.background,
      allineamento: '',
      competenze: competenze,
      caratteristiche: characteristics,
      modificatori: modifiers,
      caratteristicheImpostate: true,
      velocita: pdfData.speed,
      linguaggi: const [],
      capacitaSpeciali: const [],
      dadoVita: pdfData.hitDice > 0 ? pdfData.hitDice : 8,
      puntiVita: pdfData.maxHitPoints,
      tiriSalvezza: const [],
      competenzeArmi: const [],
      competenzeArmature: const [],
      competenzeStrumenti: const [],
      abilitaClasse: competenze,
      equipaggiamento: const [],
    );
  }

  static String _parseClass(String classLevel) {
    final parts = classLevel.trim().split(' ');
    if (parts.isNotEmpty) {
      if (int.tryParse(parts.last) != null) {
        return parts.sublist(0, parts.length - 1).join(' ');
      }
      return classLevel;
    }
    return 'Unknown';
  }

  /// Validates if PDF data is complete enough for import
  static bool isValidForImport(PdfCharacterData data) {
    return data.name.isNotEmpty &&
        data.classLevel.isNotEmpty &&
        data.race.isNotEmpty &&
        data.strength > 0 &&
        data.dexterity > 0 &&
        data.constitution > 0 &&
        data.intelligence > 0 &&
        data.wisdom > 0 &&
        data.charisma > 0 &&
        data.maxHitPoints > 0;
  }

  /// Provides a summary of missing fields
  static List<String> getMissingFields(PdfCharacterData data) {
    final List<String> missing = [];
    if (data.name.isEmpty) missing.add('Nome');
    if (data.classLevel.isEmpty) missing.add('Classe/Livello');
    if (data.race.isEmpty) missing.add('Razza');
    if (data.strength == 0) missing.add('Forza');
    if (data.dexterity == 0) missing.add('Destrezza');
    if (data.constitution == 0) missing.add('Costituzione');
    if (data.intelligence == 0) missing.add('Intelligenza');
    if (data.wisdom == 0) missing.add('Saggezza');
    if (data.charisma == 0) missing.add('Carisma');
    if (data.maxHitPoints == 0) missing.add('PF Massimi');
    return missing;
  }
}
