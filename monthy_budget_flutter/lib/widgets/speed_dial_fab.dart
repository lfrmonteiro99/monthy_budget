import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SpeedDialOption {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const SpeedDialOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class SpeedDialFab extends StatefulWidget {
  final List<SpeedDialOption> options;
  final GlobalKey? fabKey;

  const SpeedDialFab({
    super.key,
    required this.options,
    this.fabKey,
  });

  @override
  State<SpeedDialFab> createState() => _SpeedDialFabState();
}

class _SpeedDialFabState extends State<SpeedDialFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotationAnimation;
  OverlayEntry? _scrimEntry;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 0.125).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _removeScrim();
    _controller.dispose();
    super.dispose();
  }

  void _insertScrim() {
    _removeScrim();
    final entry = OverlayEntry(
      builder: (_) => ListenableBuilder(
        listenable: _controller,
        builder: (ctx, child) => GestureDetector(
          onTap: _close,
          child: Container(
            color: Colors.black.withValues(alpha: 0.4 * _controller.value),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(entry);
    _scrimEntry = entry;
  }

  void _removeScrim() {
    _scrimEntry?.remove();
    _scrimEntry = null;
  }

  void _toggle() {
    if (_isOpen) {
      _close();
    } else {
      _open();
    }
  }

  void _open() {
    setState(() => _isOpen = true);
    _insertScrim();
    _controller.forward();
  }

  void _close() {
    if (!_isOpen) return;
    setState(() => _isOpen = false);
    _controller.reverse().then((_) => _removeScrim());
  }

  void _onOptionTap(SpeedDialOption option) {
    _close();
    Future.delayed(const Duration(milliseconds: 150), option.onTap);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Options (top to bottom = last option first visually)
        for (var i = widget.options.length - 1; i >= 0; i--)
          _buildOption(context, widget.options[i], i),
        const SizedBox(height: 12),
        // Main FAB
        FloatingActionButton(
          key: widget.fabKey,
          onPressed: _toggle,
          backgroundColor: AppColors.primary(context),
          child: RotationTransition(
            turns: _rotationAnimation,
            child: Icon(
              Icons.add,
              color: AppColors.onPrimary(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOption(BuildContext context, SpeedDialOption option, int index) {
    final delay = (widget.options.length - 1 - index) * 0.15;
    final interval = Interval(
      delay.clamp(0.0, 0.6),
      (delay + 0.5).clamp(0.0, 1.0),
      curve: Curves.easeOutBack,
    );
    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: interval));
    final scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: interval),
    );

    return SlideTransition(
      position: slideAnimation,
      child: ScaleTransition(
        scale: scaleAnimation,
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Label chip
              Material(
                elevation: 4,
                shadowColor: Colors.black26,
                borderRadius: BorderRadius.circular(8),
                color: AppColors.surface(context),
                child: InkWell(
                  onTap: () => _onOptionTap(option),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Text(
                      option.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Mini FAB
              SizedBox(
                width: 44,
                height: 44,
                child: FloatingActionButton(
                  heroTag: 'speed_dial_$index',
                  onPressed: () => _onOptionTap(option),
                  elevation: 4,
                  backgroundColor: AppColors.primary(context),
                  child: Icon(
                    option.icon,
                    size: 20,
                    color: AppColors.onPrimary(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
