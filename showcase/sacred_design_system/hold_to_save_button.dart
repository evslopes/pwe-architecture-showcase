import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pwe/core/l10n/l10n_extensions.dart';

/// Botão de submissão por pressão prolongada (hold-to-complete).
///
/// O utilizador deve pressionar e segurar durante [holdDuration] (2s por padrão)
/// para confirmar a ação. Fornece feedback visual (anel de progresso
/// circular animado) e háptico ([HapticFeedback.mediumImpact]).
class HoldToSaveButton extends StatefulWidget {
  /// Texto exibido no centro do botão.
  final String? label;

  /// Ícone exibido acima do label.
  final IconData icon;

  /// Callback invocado quando a pressão prolongada é concluída com sucesso.
  final VoidCallback onCompleted;

  /// Duração necessária de pressão para completar.
  final Duration holdDuration;

  const HoldToSaveButton({
    super.key,
    this.label,
    this.icon = Icons.favorite,
    required this.onCompleted,
    this.holdDuration = const Duration(seconds: 2),
  });

  @override
  State<HoldToSaveButton> createState() => _HoldToSaveButtonState();
}

class _HoldToSaveButtonState extends State<HoldToSaveButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isHolding = false;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.holdDuration,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_isCompleted) {
        _isCompleted = true;
        HapticFeedback.mediumImpact();
        widget.onCompleted();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onLongPressStart(LongPressStartDetails details) {
    if (_isCompleted) return;
    setState(() => _isHolding = true);
    _controller.forward(from: 0.0);
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    if (_isCompleted) return;
    setState(() => _isHolding = false);
    if (_controller.status != AnimationStatus.completed) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final effectiveLabel = widget.label ?? l10n.holdToSaveLabel;

    return Center(
      child: Semantics(
        identifier: 'hold_to_save_button',
        button: true,
        label: effectiveLabel,
        hint: l10n.holdToSaveHint,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return GestureDetector(
              onTap: () {
                if (_isCompleted) return;
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(
                          Icons.touch_app,
                          color: theme.colorScheme.onPrimary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(l10n.holdToSaveHint)),
                      ],
                    ),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              onLongPressStart: _onLongPressStart,
              onLongPressEnd: _onLongPressEnd,
              child: AnimatedScale(
                scale: _isHolding ? 0.95 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isCompleted
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest.withValues(
                            alpha: 0.5,
                          ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Anel de progresso
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: CustomPaint(
                          painter: _ProgressRingPainter(
                            progress: _controller.value,
                            color: _isCompleted
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.primary,
                            strokeWidth: 4.0,
                          ),
                        ),
                      ),
                      // Ícone e texto
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isCompleted ? Icons.check : widget.icon,
                            size: 36,
                            color: _isCompleted
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isCompleted
                                ? l10n.savedExclamation
                                : effectiveLabel,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: _isCompleted
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                          if (!_isCompleted)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                _isHolding
                                    ? l10n.holdingState
                                    : l10n.pressAndHoldPrompt,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: _isHolding
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurfaceVariant,
                                  fontWeight: _isHolding
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Painter que desenha um anel de progresso circular.
class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _ProgressRingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track (fundo)
    final trackPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2, // Começa do topo
        2 * pi * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
