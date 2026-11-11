class RecaseService {
  /// "PONTYPOOL SUPERSTORE" and "craven park station" -> title case. Mixed-case text is left alone.
  /// ponytail: short vowel-less words stay upper-case (BP, MFG); add an acronym list if one slips through.
  static String titleCaseIfShouting(String text) {
    if (text.toUpperCase() != text && text.toLowerCase() != text) return text;
    return text.toLowerCase().replaceAllMapped(RegExp(r"[a-z][a-z']*"), (m) {
      final word = m[0]!;
      if (word.length <= 3 && !word.contains(RegExp('[aeiouy]'))) return word.toUpperCase();
      return word[0].toUpperCase() + word.substring(1);
    });
  }
}
