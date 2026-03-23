/// Regex patterns for parsing LLM delimiters in coach responses.
///
/// Extracted from [_CoachScreenState] so they can be unit-tested.
final sessionInsightRegex = RegExp(
  r'\[SESSION_INSIGHT\](.*?)\|(.*?)\[/SESSION_INSIGHT\]',
  dotAll: true,
);

final microActionRegex = RegExp(
  r'\[MICRO_ACTION\](.*?)\[/MICRO_ACTION\]',
  dotAll: true,
);
