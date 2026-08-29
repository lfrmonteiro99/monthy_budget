import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monthly_management/theme/app_theme.dart';
import 'package:monthly_management/widgets/calm/calm_coach_hero_card.dart';

/// Regression coverage for issue #1324: the Coach hero card must never
/// truncate a word/number mid-token when its quote overflows 3 lines.
void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  Widget wrap(Widget child) => MaterialApp(
        theme: lightTheme(),
        home: child,
      );

  /// Finds the quote [Text] widget by matching on its known-intact prefix
  /// (the very first word of the quote is never the one that overflows).
  Text findQuoteText(WidgetTester tester, String startsWith) {
    return tester.widget<Text>(
      find.byWidgetPredicate(
        (w) => w is Text && (w.data?.startsWith(startsWith) ?? false),
      ),
    );
  }

  /// Every "word" in [rendered] (ignoring a trailing ellipsis) must be a
  /// verbatim word from [original] — never a partial prefix of one.
  void expectNoPartialWords(String rendered, String original) {
    final originalWords = original.split(' ').toSet();
    final body = rendered.endsWith('…')
        ? rendered.substring(0, rendered.length - 1)
        : rendered;
    final renderedWords =
        body.split(' ').where((w) => w.isNotEmpty).toList();
    for (final word in renderedWords) {
      expect(
        originalWords.contains(word),
        isTrue,
        reason: 'word "$word" is not a complete original word '
            '(looks truncated mid-token) — rendered: "$rendered"',
      );
    }
  }

  const seededQuote = 'O fundo de emergência já cobre 2,4 meses de despesas fixas. '
      'Manter 300 € por mês atinge a meta antes do prazo.';

  const quoteTextStyle = TextStyle(
    fontFamily: 'Fraunces',
    fontSize: 22,
    fontWeight: FontWeight.w400,
    height: 1.3,
    letterSpacing: -0.2,
  );

  /// Card width in the tests below is 220; the card pads 20px on each side
  /// (see calm_coach_hero_card.dart `EdgeInsets.all(20)`), so the quote
  /// [Text] itself is laid out with 180 logical pixels of width.
  const cardWidth = 220.0;
  const quoteMaxWidth = cardWidth - 40;

  bool overflowsThreeLines(String text) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: quoteTextStyle),
      maxLines: 3,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: quoteMaxWidth);
    return painter.didExceedMaxLines;
  }

  testWidgets(
      'seeded quote: narrow card never truncates a word/number mid-token',
      (tester) async {
    // Precondition: this quote must genuinely overflow 3 lines at this
    // width, otherwise the test would pass vacuously without exercising
    // any truncation logic at all.
    expect(overflowsThreeLines(seededQuote), isTrue,
        reason: 'test precondition: seeded quote must overflow 3 lines '
            'at $quoteMaxWidth px for this test to be meaningful');

    await tester.pumpWidget(wrap(Scaffold(
      body: SizedBox(
        width: cardWidth,
        child: CalmCoachHeroCard(
          eyebrow: 'coach',
          quote: seededQuote,
          ctaLabel: 'ver',
          onTap: () {},
        ),
      ),
    )));
    await tester.pumpAndSettle();

    final rendered = findQuoteText(tester, 'O fundo').data!;

    // The widget must actually shorten the rendered string — relying on
    // Flutter's native per-glyph ellipsis (which never changes `.data`)
    // is exactly the defect reported in issue #1324.
    expect(rendered, isNot(equals(seededQuote)));
    // The specific manifestation reported in the issue: '300' clipped to '30'.
    expect(rendered, isNot(contains('30…')));
    expectNoPartialWords(rendered, seededQuote);
  });

  testWidgets(
      'synthetic quote with a different numeral: truncation stays word-safe',
      (tester) async {
    const quote = 'Este mês já poupaste bastante, considera guardar '
        'ainda 1.250 € extra até ao fim do mês para reforçar a meta anual.';
    expect(overflowsThreeLines(quote), isTrue,
        reason: 'test precondition: quote must overflow 3 lines '
            'at $quoteMaxWidth px for this test to be meaningful');

    await tester.pumpWidget(wrap(Scaffold(
      body: SizedBox(
        width: cardWidth,
        child: CalmCoachHeroCard(
          eyebrow: 'coach',
          quote: quote,
          ctaLabel: 'ver',
          onTap: () {},
        ),
      ),
    )));
    await tester.pumpAndSettle();

    final rendered = findQuoteText(tester, 'Este mês').data!;
    expect(rendered, isNot(equals(quote)));
    expectNoPartialWords(rendered, quote);
  });

  testWidgets(
      'seeded quote at larger text scale: truncation is measured at the '
      'real textScaler, not at scale 1.0', (tester) async {
    const scaler = TextScaler.linear(1.3);
    final mediaQueryData = MediaQueryData(textScaler: scaler);

    await tester.pumpWidget(MaterialApp(
      theme: lightTheme(),
      home: MediaQuery(
        data: mediaQueryData,
        child: Scaffold(
          body: SizedBox(
            width: cardWidth,
            child: CalmCoachHeroCard(
              eyebrow: 'coach',
              quote: seededQuote,
              ctaLabel: 'ver',
              onTap: () {},
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    final rendered = findQuoteText(tester, 'O fundo').data!;

    // Re-measure the *rendered* string at the *real* scaler the Text widget
    // will actually paint with. If truncation was decided at scale 1.0 (the
    // defect), the same string can still overflow 3 lines once painted at
    // the user's real text-scale factor.
    final painter = TextPainter(
      text: TextSpan(text: rendered, style: quoteTextStyle),
      maxLines: 3,
      textDirection: TextDirection.ltr,
      textScaler: scaler,
    )..layout(maxWidth: quoteMaxWidth);

    expect(
      painter.didExceedMaxLines,
      isFalse,
      reason: 'truncated text "$rendered" still overflows 3 lines when '
          'measured at the real textScaler ($scaler) — truncation must be '
          'computed at the same scale the Text widget paints with',
    );
  });

  testWidgets('quote that fits within 3 lines is rendered unchanged',
      (tester) async {
    const quote = 'Tudo em dia este mês.';
    await tester.pumpWidget(wrap(Scaffold(
      body: SizedBox(
        width: 400,
        child: CalmCoachHeroCard(
          eyebrow: 'coach',
          quote: quote,
          ctaLabel: 'ver',
          onTap: () {},
        ),
      ),
    )));
    await tester.pumpAndSettle();

    final rendered = findQuoteText(tester, 'Tudo em dia').data!;
    expect(rendered, quote);
  });
}
