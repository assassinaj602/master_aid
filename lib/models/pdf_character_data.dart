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
    // Helper that trims trailing spaces from keys (some WotC fields have them)
    String getWotcField(String key) {
      return fields[key] ?? fields[key.trimRight()] ?? '';
    }

    int parseWotcInt(String key) {
      final raw = getWotcField(key);
      return int.tryParse(raw.trim()) ?? 0;
    }

    // Parse level from ClassLevel string e.g. "Wizard 5"
    int parseLevel(String classLevel) {
      final parts = classLevel.trim().split(' ');
      if (parts.length >= 2) {
        return int.tryParse(parts.last) ?? 1;
      }
      return 1;
    }

    final classLevelStr = getWotcField('ClassLevel');

    return PdfCharacterData(
      name: getWotcField('CharacterName'),
      classLevel: classLevelStr,
      race: getWotcField('Race ').trim(),
      background: getWotcField('Background'),
      playerName: getWotcField('PlayerName'),
      level: parseLevel(classLevelStr),
      strength: parseWotcInt('STR'),
      dexterity: parseWotcInt('DEX'),
      constitution: parseWotcInt('CON'),
      intelligence: parseWotcInt('INT'),
      wisdom: parseWotcInt('WIS'),
      charisma: parseWotcInt('CHA'),
      skills: _extractSkills(fields),
      armorClass: parseWotcInt('AC'),
      initiative: parseWotcInt('Initiative'),
      speed: parseWotcInt('Speed'),
      maxHitPoints: parseWotcInt('HPMax'),
      hitDice: parseWotcInt('HD'),
      spellcastingClass:
          getWotcField('Spellcasting Class 2').isNotEmpty
              ? getWotcField('Spellcasting Class 2')
              : null,
      spellSaveDC:
          getWotcField('SpellSaveDC  2').isNotEmpty
              ? int.tryParse(getWotcField('SpellSaveDC  2').trim())
              : null,
      spellAttackBonus:
          getWotcField('SpellAtkBonus 2').isNotEmpty
              ? int.tryParse(getWotcField('SpellAtkBonus 2').trim())
              : null,
      spells: _extractSpells(fields),
    );
  }

  static Map<String, int> _extractSkills(Map<String, String> fields) {
    final Map<String, int> skillMap = {};

    // Real WotC PDF field names (verified against official fillable sheet)
    // Some have trailing spaces in the actual PDF field names
    final Map<String, String> skillFieldMap = {
      'Acrobatics': 'Acrobatics',
      'Animal Handling': 'Animal', // special case
      'Arcana': 'Arcana',
      'Athletics': 'Athletics',
      'Deception': 'Deception ', // trailing space
      'History': 'History ', // trailing space
      'Insight': 'Insight',
      'Intimidation': 'Intimidation',
      'Investigation': 'Investigation ', // trailing space
      'Medicine': 'Medicine',
      'Nature': 'Nature',
      'Perception': 'Perception ', // trailing space
      'Performance': 'Performance',
      'Persuasion': 'Persuasion',
      'Religion': 'Religion',
      'Sleight of Hand': 'SleightofHand',
      'Stealth': 'Stealth ', // trailing space
      'Survival': 'Survival',
    };

    for (final entry in skillFieldMap.entries) {
      final raw = fields[entry.value] ?? '';
      skillMap[entry.key] = int.tryParse(raw.trim()) ?? 0;
    }

    return skillMap;
  }

  static List<String> _extractSpells(Map<String, String> fields) {
    final List<String> spells = [];
    // WotC PDFs use 'Spells XXXX' non-sequential IDs — extract all matching keys
    for (final entry in fields.entries) {
      if (entry.key.startsWith('Spells ') && entry.value.isNotEmpty) {
        spells.add(entry.value);
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
