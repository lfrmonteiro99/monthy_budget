import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../constants/app_constants.dart';

/// Picks a `ContentAlign` for a tour target based on where the target
/// actually sits on screen — so the tooltip never renders off-screen
/// when the Calm layouts put targets near the top or bottom edges.
///
/// Rules:
/// - Target inside a `Scrollable`: `safeEnsureVisible` will center it
///   at alignment=0.5, so the tooltip below the target is always safe.
/// - Fixed (non-scrollable) target: probe the render box and flip:
///   - target in top 40% of viewport → tooltip below (`bottom`)
///   - target in bottom 40%         → tooltip above (`top`)
///   - middle                       → tooltip below (safer default)
/// - Context / render box not ready: default to `bottom`.
ContentAlign pickAlign(GlobalKey key) {
  final ctx = key.currentContext;
  if (ctx == null) return ContentAlign.bottom;

  if (Scrollable.maybeOf(ctx) != null) return ContentAlign.bottom;

  final render = ctx.findRenderObject();
  if (render is! RenderBox || !render.hasSize) return ContentAlign.bottom;

  final topLeft = render.localToGlobal(Offset.zero);
  final centerY = topLeft.dy + render.size.height / 2;
  final screenH = MediaQuery.of(ctx).size.height;

  if (centerY < screenH * 0.4) return ContentAlign.bottom;
  if (centerY > screenH * 0.6) return ContentAlign.top;
  return ContentAlign.bottom;
}

/// Scrolls the target into view if (and only if) it has a `Scrollable`
/// ancestor. Raw `Scrollable.ensureVisible` silently no-ops when the
/// target lives outside a scroll view, which made the old `beforeFocus`
/// hook invisible — this variant is explicit about the precondition so
/// it never fights a missing ancestor.
Future<void> safeEnsureVisible(BuildContext ctx) async {
  if (Scrollable.maybeOf(ctx) == null) return;
  await Scrollable.ensureVisible(
    ctx,
    duration: AppConstants.animPageTransition,
    alignment: 0.5,
  );
}
