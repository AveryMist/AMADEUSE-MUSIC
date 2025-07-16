import 'package:flutter/material.dart';

/// A reusable widget that displays the AMADEUSE MUSIC logo with consistent rounded corners
/// across both Android and PC platforms.
class RoundedLogoWidget extends StatelessWidget {
  const RoundedLogoWidget({
    super.key,
    this.size = 60.0,
    this.borderRadius = 12.0,
    this.logoPath = 'assets/icons/amadeuse_music.png',
  });

  /// The size of the logo (width and height)
  final double size;
  
  /// The border radius for rounded corners
  final double borderRadius;
  
  /// The path to the logo asset
  final String logoPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Image.asset(
        logoPath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Fallback in case the logo fails to load
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: Icon(
              Icons.music_note,
              color: Colors.white,
              size: size * 0.6,
            ),
          );
        },
      ),
    );
  }
}
