import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  final parsed = _parseArgs(args);
  final resultsPath = parsed['results'];
  final baselinePath = parsed['baseline'];
  final summaryPath = parsed['summary'];

  if (resultsPath == null || baselinePath == null || summaryPath == null) {
    stderr.writeln(
      'Usage: dart run scripts/check_performance_results.dart '
      '--results <path> --baseline <path> --summary <path>',
    );
    exitCode = 64;
    return;
  }

  final resultsFile = File(resultsPath);
  final baselineFile = File(baselinePath);
  if (!resultsFile.existsSync()) {
    stderr.writeln('Missing benchmark results: $resultsPath');
    exitCode = 1;
    return;
  }
  if (!baselineFile.existsSync()) {
    stderr.writeln('Missing performance baseline: $baselinePath');
    exitCode = 1;
    return;
  }

  final results =
      jsonDecode(resultsFile.readAsStringSync()) as Map<String, dynamic>;
  final baseline =
      jsonDecode(baselineFile.readAsStringSync()) as Map<String, dynamic>;
  final resultMetrics =
      (results['metrics'] as Map<String, dynamic>? ?? const {})
          .cast<String, dynamic>();
  final baselineMetrics =
      (baseline['metrics'] as Map<String, dynamic>? ?? const {})
          .cast<String, dynamic>();

  final summaryLines = <String>[
    '# Performance Benchmark Summary',
    '',
    '| Metric | Current | Baseline | Budget | Delta | Status |',
    '| --- | ---: | ---: | ---: | ---: | --- |',
  ];

  var hasFailure = false;
  for (final entry in baselineMetrics.entries) {
    final metricName = entry.key;
    final config = entry.value as Map<String, dynamic>;
    final metric = resultMetrics[metricName] as Map<String, dynamic>?;
    if (metric == null) {
      hasFailure = true;
      stderr.writeln('Missing metric in benchmark results: $metricName');
      summaryLines.add(
        '| ${config['label'] ?? metricName} | missing | '
        '${_formatMs(config['baseline_ms'])} | ${_formatMs(config['budget_ms'])} | n/a | fail |',
      );
      continue;
    }

    final label = (config['label'] ?? metric['label'] ?? metricName).toString();
    final currentMs = (metric['value'] as num).toDouble();
    final baselineMs = (config['baseline_ms'] as num).toDouble();
    final budgetMs = (config['budget_ms'] as num).toDouble();
    final warningRegressionPct =
        (config['warning_regression_pct'] as num?)?.toDouble() ?? 20;
    final deltaPct = baselineMs == 0
        ? 0.0
        : ((currentMs - baselineMs) / baselineMs) * 100;
    final overBudget = currentMs > budgetMs;
    final shouldWarn =
        currentMs > baselineMs * (1 + warningRegressionPct / 100);

    var status = 'pass';
    if (overBudget) {
      status = 'fail';
      hasFailure = true;
      _emitAnnotation(
        'error',
        '$label exceeded budget: ${_formatMs(currentMs)} > ${_formatMs(budgetMs)}',
      );
    } else if (shouldWarn) {
      status = 'warning';
      _emitAnnotation(
        'warning',
        '$label regressed by ${deltaPct.toStringAsFixed(1)}% '
            '(baseline ${_formatMs(baselineMs)}, current ${_formatMs(currentMs)})',
      );
    }

    summaryLines.add(
      '| $label | ${_formatMs(currentMs)} | ${_formatMs(baselineMs)} | '
      '${_formatMs(budgetMs)} | ${_formatDelta(deltaPct)} | $status |',
    );
  }

  final generatedAt = results['generated_at'];
  if (generatedAt is String && generatedAt.isNotEmpty) {
    summaryLines
      ..add('')
      ..add('Generated at: `$generatedAt`');
  }

  final summary = summaryLines.join('\n');
  final summaryFile = File(summaryPath);
  summaryFile.parent.createSync(recursive: true);
  summaryFile.writeAsStringSync('$summary\n');

  final githubStepSummary = Platform.environment['GITHUB_STEP_SUMMARY'];
  if (githubStepSummary != null && githubStepSummary.isNotEmpty) {
    File(
      githubStepSummary,
    ).writeAsStringSync('$summary\n', mode: FileMode.append);
  }

  stdout.writeln(summary);
  if (hasFailure) {
    exitCode = 1;
  }
}

Map<String, String> _parseArgs(List<String> args) {
  final parsed = <String, String>{};
  for (var i = 0; i < args.length - 1; i += 2) {
    final key = args[i];
    final value = args[i + 1];
    switch (key) {
      case '--results':
        parsed['results'] = value;
        break;
      case '--baseline':
        parsed['baseline'] = value;
        break;
      case '--summary':
        parsed['summary'] = value;
        break;
    }
  }
  return parsed;
}

String _formatMs(Object? value) {
  if (value is num) {
    return '${value.toDouble().toStringAsFixed(1)} ms';
  }
  return 'n/a';
}

String _formatDelta(double deltaPct) {
  final sign = deltaPct > 0 ? '+' : '';
  return '$sign${deltaPct.toStringAsFixed(1)}%';
}

void _emitAnnotation(String level, String message) {
  stdout.writeln('::$level::$message');
}
