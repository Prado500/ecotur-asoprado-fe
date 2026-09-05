import 'package:flutter/material.dart';

/// Wrapper that provides a highly efficient hardware-accelerated
/// zoom hover effect for web and desktop environments.
class HoverZoomWrapper extends StatefulWidget {
  final Widget child;

  const HoverZoomWrapper({super.key, required this.child});

  @override
  State<HoverZoomWrapper> createState() => _HoverZoomWrapperState();
}

class _HoverZoomWrapperState extends State<HoverZoomWrapper> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        scale: _isHovered ? 1.03 : 1.0, // zoom to 3% when hoovering
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: widget.child,
      ),
    );
  }
}