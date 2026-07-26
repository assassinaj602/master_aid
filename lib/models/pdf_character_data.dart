/// Model representing parsed data from a WotC PDF character sheet
class PdfCharacterData {
  // Basic Info
  final String name;
  final String classLevel;
  final String race;
  final String background;
  final String playerName;
  final int level;

  // Ability Scores
  final int strength;
  final int dexterity;
  final int constitution;
  final int intelligence;
  final int wisdom;
  final int charisma;

  // Skills (0 = not proficient, 1 = proficient, 2 = expertise)
  final Map<String, int> skills;

  // Combat Stats
  final int armorClass;
  final int initiative;
  final int speed;
  final int maxHitPoints;
  final int hitDice;

  // Spellcasting (if applicable)
  final String? spellcastingClass;
  final int? spellSaveDC;
  final int? spellAttackBonus;
  final List<String>? spells;

  PdfCharacterData({
    required this.name,
    required this.classLevel,
    required this.race,
    required this.background,
    required this.playerName,
    required this.level,
    required this.strength,
    required this.dexterity,
    required this.constitution,
    required this.intelligence,
    required this.wisdom,
    required this.charisma,
    this.skills = const {},
    required this.armorClass,
    required this.initiative,
    required this.speed,
    required this.maxHitPoints,
    required this.hitDice,
    this.spellcastingClass,
    this.spellSaveDC,
    this.spellAttackBonus,
    this.spells,
  });

  /// Creates a PdfCharacterData from raw AcroForm field values
  factory PdfCharacterData.fromFieldMap(Map<String, String> fields) {
    int parseIntSafe(String key) {
      final value = fields[key] ?? '0';
      return int.tryParse(value) ?? 0;
    }

    String getStringSafe(String key) {
      return fields[key] ?? '';
    }

    return PdfCharacterData(
      name: getStringSafe('charactername'),
      classLevel: getStringSafe('classlevel'),
      race: getStringSafe('race'),
      background: getStringSafe('background'),
      playerName: getStringSafe('playername'),
      level: parseIntSafe('level'),
      strength: parseIntSafe('STR'),
      dexterity: parseIntSafe('DEX'),
      constitution: parseIntSafe('CON'),
      intelligence: parseIntSafe('INT'),
      wisdom: parseIntSafe('WIS'),
      charisma: parseIntSafe('CHA'),
      skills: _extractSkills(fields),
      armorClass: parseIntSafe('AC'),
      initiative: parseIntSafe('Initiative'),
      speed: parseIntSafe('Speed'),
      maxHitPoints: parseIntSafe('HP'),
      hitDice: parseIntSafe('Hit Dice'),
      spellcastingClass:
          getStringSafe('Spellcasting Class').isNotEmpty
              ? getStringSafe('Spellcasting Class')
              : null,
      spellSaveDC:
          getStringSafe('Spell Save DC').isNotEmpty
              ? int.tryParse(getStringSafe('Spell Save DC'))
              : null,
      spellAttackBonus:
          getStringSafe('Spell Attack Bonus').isNotEmpty
              ? int.tryParse(getStringSafe('Spell Attack Bonus'))
              : null,
      spells: _extractSpells(fields),
    );
  }

  static Map<String, int> _extractSkills(Map<String, String> fields) {
    final Map<String, int> skillMap = {};
    const List<String> skillNames = [
      'Acrobatics',
      'Animal Handling',
      'Arcana',
      'Athletics',
      'Deception',
      'History',
      'Insight',
      'Intimidation',
      'Investigation',
      'Medicine',
      'Nature',
      'Perception',
      'Performance',
      'Persuasion',
      'Religion',
      'Sleight of Hand',
      'Stealth',
      'Survival',
    ];

    for (String skill in skillNames) {
      final key = skill.replaceAll(' ', '');
      final value = fields[key] ?? '0';
      skillMap[skill] = int.tryParse(value) ?? 0;
    }

    return skillMap;
  }

  static List<String> _extractSpells(Map<String, String> fields) {
    final List<String> spells = [];
    for (int i = 1; i <= 50; i++) {
      final spell = fields['Spell$i'] ?? '';
      if (spell.isNotEmpty) {
        spells.add(spell);
      }
    }
    return spells;
  }

  /// Converts to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'classLevel': classLevel,
      'race': race,
      'background': background,
      'playerName': playerName,
      'level': level,
      'strength': strength,
      'dexterity': dexterity,
      'constitution': constitution,
      'intelligence': intelligence,
      'wisdom': wisdom,
      'charisma': charisma,
      'skills': skills,
      'armorClass': armorClass,
      'initiative': initiative,
      'speed': speed,
      'maxHitPoints': maxHitPoints,
      'hitDice': hitDice,
      'spellcastingClass': spellcastingClass,
      'spellSaveDC': spellSaveDC,
      'spellAttackBonus': spellAttackBonus,
      'spells': spells,
    };
  }
}
