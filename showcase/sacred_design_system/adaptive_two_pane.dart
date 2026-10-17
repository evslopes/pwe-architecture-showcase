import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pwe/core/theme/sacred_theme_colors.dart';
import 'package:pwe/core/utils/responsive_utils.dart';

/// Widget adaptativo que renderiza o conteúdo em coluna única no modo Retrato (Portrait)
/// ou em duas colunas proporcionais lado a lado no modo Paisagem (Landscape).
///
/// **Scriptorium Sacro** — Componente canônico de dois painéis do Design System do pwE.
///
/// Aprimoramentos sobre o layout adaptativo básico:
/// - [respectSafeArea]: protege automaticamente contra entalhes laterais em landscape.
/// - [compactVerticalMode]: adapta espaçamentos quando a altura é < 500dp.
/// - Divisor sacro dourado padrão quando [showDivider] é `true` e [customDivider] é nulo.
class AdaptiveTwoPane extends StatelessWidget {
  /// Widget exibido no topo (Portrait) ou à esquerda (Landscape).
  final Widget paneStart;

  /// Widget exibido abaixo (Portrait) ou à direita (Landscape).
  final Widget paneEnd;

  /// Proporção do painel esquerdo em landscape (padrão: 1).
  final int paneStartFlex;

  /// Proporção do painel direito em landscape (padrão: 1).
  final int paneEndFlex;

  /// Espaçamento entre os dois painéis (padrão: 16.0).
  final double spacing;

  /// Espaçamento interno (padding) ao redor do layout.
  final EdgeInsetsGeometry padding;

  /// Se deve exibir um divisor entre os painéis em modo paisagem.
  final bool showDivider;

  /// Divisor customizado em modo paisagem. Se nulo e [showDivider] for true,
  /// usa um divisor vertical sacro dourado sutil.
  final Widget? customDivider;

  /// Alinhamento vertical dos painéis em landscape.
  final CrossAxisAlignment crossAxisAlignment;

  /// Se o painel inicial deve ser envolvido em um `SingleChildScrollView` em landscape.
  final bool scrollableStart;

  /// Se o painel final deve ser envolvido em um `SingleChildScrollView` em landscape.
  final bool scrollableEnd;

  /// Se verdadeiro, respeita automaticamente os insets horizontais de segurança
  /// (notch, Dynamic Island) adicionando SafeArea horizontal em landscape.
  /// Padrão: `false` para manter retrocompatibilidade.
  final bool respectSafeArea;

  /// Se verdadeiro, reduz automaticamente espaçamentos e paddings quando a
  /// altura disponível é compacta (< 500dp, típico de smartphones em landscape).
  /// Padrão: `false` para manter retrocompatibilidade.
  final bool compactVerticalMode;

  /// Largura máxima opcional do container em telas grandes.
  /// Se nulo, utiliza [ResponsiveContext.maxTwoPaneWidth] (1180dp) em landscape.
  final double? maxWidth;

  const AdaptiveTwoPane({
    super.key,
    required this.paneStart,
    required this.paneEnd,
    this.paneStartFlex = 1,
    this.paneEndFlex = 1,
    this.spacing = 16.0,
    this.padding = EdgeInsets.zero,
    this.showDivider = false,
    this.customDivider,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.scrollableStart = false,
    this.scrollableEnd = false,
    this.respectSafeArea = false,
    this.compactVerticalMode = false,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    if (!context.isLandscape) {
      Widget column = Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            paneStart,
            SizedBox(height: spacing),
            paneEnd,
          ],
        ),
      );
      if (maxWidth != null || context.screenWidth > 760) {
        column = Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth ?? context.maxSinglePaneWidth,
            ),
            child: column,
          ),
        );
      }
      return column;
    }

    // Adapta espaçamento em modo compacto (altura reduzida)
    final effectiveSpacing = compactVerticalMode && context.isCompactHeight
        ? spacing * 0.75
        : (context.isDesktopOrWide ? math.max(spacing, 28.0) : spacing);

    final Widget effectiveStart = scrollableStart
        ? SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: paneStart,
          )
        : paneStart;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = context.sacred.goldAccent.withValues(
      alpha: isDark ? 0.22 : 0.28,
    );
    final bool needsBorderFallback =
        showDivider &&
        customDivider == null &&
        crossAxisAlignment != CrossAxisAlignment.stretch;

    Widget effectiveEnd = scrollableEnd
        ? SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: paneEnd,
          )
        : paneEnd;

    if (needsBorderFallback) {
      effectiveEnd = DecoratedBox(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: dividerColor, width: 1)),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: effectiveSpacing / 2),
          child: effectiveEnd,
        ),
      );
    }

    // Divisor sacro dourado padrão — filigrana vertical sutil
    final Widget? effectiveDivider = showDivider
        ? (customDivider ??
              VerticalDivider(
                width: 1,
                thickness: 1,
                color: needsBorderFallback ? Colors.transparent : dividerColor,
              ))
        : null;

    Widget rowContent = Row(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Expanded(flex: paneStartFlex, child: effectiveStart),
        if (effectiveDivider != null) ...[
          SizedBox(width: effectiveSpacing / 2),
          effectiveDivider,
          SizedBox(width: needsBorderFallback ? 0 : effectiveSpacing / 2),
        ] else
          SizedBox(width: effectiveSpacing),
        Expanded(flex: paneEndFlex, child: effectiveEnd),
      ],
    );

    Widget row = LayoutBuilder(
      builder: (context, constraints) {
        Widget content = rowContent;
        if (crossAxisAlignment == CrossAxisAlignment.stretch &&
            !scrollableStart &&
            !scrollableEnd &&
            !constraints.hasBoundedHeight) {
          content = IntrinsicHeight(child: content);
        }
        return Padding(padding: padding, child: content);
      },
    );

    // Centraliza e limita a largura máxima em notebooks e monitores grandes
    final effectiveMaxWidth = maxWidth ?? context.maxTwoPaneWidth;
    row = Center(
      heightFactor: 1.0,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
        child: row,
      ),
    );

    // Aplica SafeArea horizontal para entalhes laterais em landscape
    if (respectSafeArea) {
      final safePad = MediaQuery.paddingOf(context);
      row = Padding(
        padding: EdgeInsets.only(
          left: math.max(safePad.left, 0),
          right: math.max(safePad.right, 0),
        ),
        child: row,
      );
    }

    return row;
  }
}
