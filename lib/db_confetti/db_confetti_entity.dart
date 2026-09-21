class ConfettiShredMode {
  static const String physicalDegradation = 'physicalDegradation';
  static const String everythingToZero = 'everythingToZero';
}
class ConfettiPreference {
  final int? id;
  final String shredMode;
  final String quoteOrder;
  final int quoteIndex;
  final String createdAt;
  final int lastCountdownMinutes;
  final int countdownCompletions;
  final String lastThemeId;
  final String lastReleaseDate;
  final String lastToolId;
  final String lastOpenDate;
  const ConfettiPreference({
    this.id,
    required this.shredMode,
    required this.quoteOrder,
    required this.quoteIndex,
    required this.createdAt,
    this.lastCountdownMinutes = 3,
    this.countdownCompletions = 0,
    this.lastThemeId = '',
    this.lastReleaseDate = '',
    this.lastToolId = '',
    this.lastOpenDate = '',
  });
  factory ConfettiPreference.fromMap(Map<String, dynamic> map) {
    return ConfettiPreference(
      id: map['id'] as int?,
      shredMode: map['shred_mode'] as String,
      quoteOrder: map['quote_order'] as String,
      quoteIndex: map['quote_index'] as int,
      createdAt: map['created_at'] as String,
      lastCountdownMinutes: (map['last_countdown_minutes'] as int?) ?? 3,
      countdownCompletions: (map['countdown_completions'] as int?) ?? 0,
      lastThemeId: (map['last_theme_id'] as String?) ?? '',
      lastReleaseDate: (map['last_release_date'] as String?) ?? '',
      lastToolId: (map['last_tool_id'] as String?) ?? '',
      lastOpenDate: (map['last_open_date'] as String?) ?? '',
    );
  }
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'shred_mode': shredMode,
      'quote_order': quoteOrder,
      'quote_index': quoteIndex,
      'created_at': createdAt,
      'last_countdown_minutes': lastCountdownMinutes,
      'countdown_completions': countdownCompletions,
      'last_theme_id': lastThemeId,
      'last_release_date': lastReleaseDate,
      'last_tool_id': lastToolId,
      'last_open_date': lastOpenDate,
    };
  }
  ConfettiPreference copyWith({
    int? id,
    String? shredMode,
    String? quoteOrder,
    int? quoteIndex,
    String? createdAt,
    int? lastCountdownMinutes,
    int? countdownCompletions,
    String? lastThemeId,
    String? lastReleaseDate,
    String? lastToolId,
    String? lastOpenDate,
  }) {
    return ConfettiPreference(
      id: id ?? this.id,
      shredMode: shredMode ?? this.shredMode,
      quoteOrder: quoteOrder ?? this.quoteOrder,
      quoteIndex: quoteIndex ?? this.quoteIndex,
      createdAt: createdAt ?? this.createdAt,
      lastCountdownMinutes: lastCountdownMinutes ?? this.lastCountdownMinutes,
      countdownCompletions: countdownCompletions ?? this.countdownCompletions,
      lastThemeId: lastThemeId ?? this.lastThemeId,
      lastReleaseDate: lastReleaseDate ?? this.lastReleaseDate,
      lastToolId: lastToolId ?? this.lastToolId,
      lastOpenDate: lastOpenDate ?? this.lastOpenDate,
    );
  }
}
