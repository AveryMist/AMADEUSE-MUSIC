import 'package:flutter/material.dart';

/// Thème moderne pour les boutons avec effets de relief et animations
class ModernButtonTheme {
  // Couleurs pour les effets de relief
  static const Color _shadowColor = Color(0x40000000);
  static const Color _highlightColor = Color(0x20FFFFFF);
  
  /// Style pour les boutons principaux avec effet de relief
  static ButtonStyle elevatedButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      elevation: 8,
      shadowColor: _shadowColor,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ).copyWith(
      overlayColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.pressed)) {
            return Theme.of(context).colorScheme.primary.withOpacity(0.3);
          }
          if (states.contains(WidgetState.hovered)) {
            return Theme.of(context).colorScheme.primary.withOpacity(0.1);
          }
          return null;
        },
      ),
      elevation: WidgetStateProperty.resolveWith<double>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.pressed)) return 4;
          if (states.contains(WidgetState.hovered)) return 12;
          return 8;
        },
      ),
    );
  }

  /// Style pour les IconButton avec effet de relief moderne
  static Widget modernIconButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required BuildContext context,
    double size = 24,
    double? iconSize,
    Color? color,
    bool isSelected = false,
    String? tooltip,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isSelected
              ? [
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  Theme.of(context).colorScheme.primary,
                ]
              : [
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).colorScheme.surface.withOpacity(0.8),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: _shadowColor,
            offset: const Offset(2, 2),
            blurRadius: 6,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: _highlightColor,
            offset: const Offset(-1, -1),
            blurRadius: 3,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              icon,
              size: iconSize ?? size,
              color: color ??
                  (isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).iconTheme.color),
            ),
          ),
        ),
      ),
    );
  }

  /// Bouton de lecture/pause avec animation et relief
  static Widget modernPlayButton({
    required Widget child,
    required VoidCallback? onPressed,
    required BuildContext context,
    double size = 70,
    double? iconSize,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.9),
            Theme.of(context).colorScheme.primary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: _shadowColor,
            offset: const Offset(2, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: _highlightColor,
            offset: const Offset(-2, -2),
            blurRadius: 6,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(size / 2),
          onTap: onPressed,
          child: Center(child: child),
        ),
      ),
    );
  }

  /// Bouton de navigation avec effet de relief
  static Widget modernNavButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isSelected
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(context).colorScheme.primaryContainer.withOpacity(0.8),
                ],
              )
            : null,
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).iconTheme.color,
                ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Bouton flottant moderne avec effet de relief
  static Widget modernFloatingActionButton({
    required Widget child,
    required VoidCallback? onPressed,
    required BuildContext context,
    double elevation = 12,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.secondary,
            Theme.of(context).colorScheme.secondary.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.4),
            offset: const Offset(0, 4),
            blurRadius: elevation,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: _shadowColor,
            offset: const Offset(2, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: child,
      ),
    );
  }

  /// Style pour les boutons de liste avec effet de relief subtil
  static Widget modernListTile({
    required Widget leading,
    required Widget title,
    Widget? subtitle,
    Widget? trailing,
    required VoidCallback? onTap,
    required BuildContext context,
    bool isSelected = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
            : Theme.of(context).colorScheme.surface,
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              offset: const Offset(0, 1),
              blurRadius: 4,
              spreadRadius: 0,
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                leading,
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      title,
                      if (subtitle != null) subtitle,
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 16),
                  trailing,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}