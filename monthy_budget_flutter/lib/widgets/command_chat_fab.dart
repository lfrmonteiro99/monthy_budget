import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../onboarding/command_assistant_tour.dart';

class CommandChatFab extends StatefulWidget {
  final VoidCallback onTap;
  final bool isDashboard;
  final bool isExpanded;
  final bool showTour;
  final VoidCallback? onTourComplete;

  const CommandChatFab({
    super.key,
    required this.onTap,
    this.isDashboard = false,
    this.isExpanded = false,
    this.showTour = false,
    this.onTourComplete,
  });

  @override
  State<CommandChatFab> createState() => _CommandChatFabState();
}

class _CommandChatFabState extends State<CommandChatFab>
    with SingleTickerProviderStateMixin {
  static const _prefKeyPosition = 'command_fab_position';
  static const _prefKeyFirstUse = 'command_fab_first_use_done';
  static const _fabSize = 48.0;
  static const _edgeMargin = 16.0;

  Offset? _position;
  bool _dragging = false;
  bool _firstUseDone = true;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: AppConstants.animFabPulse,
    );
    _loadState();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    _firstUseDone = prefs.getBool(_prefKeyFirstUse) ?? false;
    final posJson = prefs.getString(_prefKeyPosition);
    if (posJson != null) {
      try {
        final map = jsonDecode(posJson);
        _position = Offset(
          (map['dx'] as num).toDouble(),
          (map['dy'] as num).toDouble(),
        );
      } catch (_) {}
    }
    if (!_firstUseDone) {
      _pulseController.repeat(reverse: true);
      Future.delayed(AppConstants.fabFirstUseDismiss, () {
        if (mounted) {
          _pulseController.stop();
          _pulseController.reset();
        }
      });
    }
    if (mounted) setState(() {});
    if (widget.showTour) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _tryShowTour());
    }
  }

  Future<void> _savePosition() async {
    if (_position == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefKeyPosition,
      jsonEncode({'dx': _position!.dx, 'dy': _position!.dy}),
    );
  }

  Future<void> _markFirstUseDone() async {
    if (_firstUseDone) return;
    _firstUseDone = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyFirstUse, true);
  }

  bool _tourShown = false;

  void _tryShowTour() {
    if (_tourShown || !mounted) return;
    _tourShown = true;
    // Delay slightly so the FAB is positioned on screen
    Future.delayed(AppConstants.tourStartDelay, () {
      if (!mounted) return;
      buildCommandAssistantTour(
        context: context,
        onFinish: () => widget.onTourComplete?.call(),
        onSkip: () => widget.onTourComplete?.call(),
      ).show(context: context);
    });
  }

  Offset _defaultPosition(Size screenSize) {
    return Offset(
      _edgeMargin,
      screenSize.height - 72 - _fabSize - _edgeMargin,
    );
  }

  Offset _clampPosition(Offset pos, Size screenSize) {
    final minY = MediaQuery.of(context).padding.top + kToolbarHeight + 8;
    final maxY = screenSize.height - 72 - _fabSize - 8;
    final dx = pos.dx.clamp(
      _edgeMargin,
      screenSize.width - _fabSize - _edgeMargin,
    );
    var dy = pos.dy.clamp(minY, maxY);

    // Collision avoidance with expense FAB on dashboard
    if (widget.isDashboard) {
      final expenseFabLeft = screenSize.width - 56 - 16;
      final expenseFabTop = screenSize.height - 72 - 56 - 16;
      if (dx > expenseFabLeft - _fabSize - 8 &&
          dy > expenseFabTop - _fabSize - 8) {
        dy = expenseFabTop - _fabSize - 16;
      }
    }
    return Offset(dx, dy);
  }

  Offset _snapToEdge(Offset pos, Size screenSize) {
    final midX = screenSize.width / 2;
    final snapX = pos.dx < midX
        ? _edgeMargin
        : screenSize.width - _fabSize - _edgeMargin;
    return Offset(snapX, pos.dy);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isExpanded) return const SizedBox.shrink();

    final screenSize = MediaQuery.sizeOf(context);
    final currentPos = _position ?? _defaultPosition(screenSize);
    final clampedPos = _clampPosition(currentPos, screenSize);

    return AnimatedPositioned(
      duration: _dragging ? Duration.zero : AppConstants.animFast,
      curve: Curves.easeOut,
      left: clampedPos.dx,
      top: clampedPos.dy,
      child: Semantics(
        button: true,
        label: widget.isExpanded ? 'Close command assistant' : 'Open command assistant',
        child: GestureDetector(
        onPanStart: (_) => setState(() => _dragging = true),
        onPanUpdate: (details) {
          setState(() {
            _position = Offset(
              clampedPos.dx + details.delta.dx,
              clampedPos.dy + details.delta.dy,
            );
          });
        },
        onPanEnd: (_) {
          setState(() {
            _dragging = false;
            _position = _snapToEdge(
              _clampPosition(_position ?? clampedPos, screenSize),
              screenSize,
            );
          });
          _savePosition();
        },
        onTap: () {
          _markFirstUseDone();
          widget.onTap();
        },
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final scale = _firstUseDone
                ? 1.0
                : 1.0 + (_pulseController.value * 0.12);
            return Transform.scale(scale: scale, child: child);
          },
          child: Container(
            key: CommandAssistantTourKeys.fab,
            width: _fabSize,
            height: _fabSize,
            decoration: BoxDecoration(
              color: AppColors.ink(context),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.line(context),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.chat_bubble_rounded,
              size: 22,
              color: AppColors.bg(context),
            ),
          ),
        ),
      ),
      ),
    );
  }
}
