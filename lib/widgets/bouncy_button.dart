import 'package:flutter/material.dart';

class BouncyButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color color;
  final Color shadowColor;
  final bool fullWidth;
  final EdgeInsets padding;
  final BorderRadius borderRadius;

  const BouncyButton({
    Key? key,
    this.onPressed,
    required this.child,
    this.color = const Color(0xFF0EA5E9),
    this.shadowColor = const Color(0xFF0369A1),
    this.fullWidth = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  }) : super(key: key);

  @override
  State<BouncyButton> createState() => _BouncyButtonState();
}

class _BouncyButtonState extends State<BouncyButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.fullWidth ? double.infinity : null,
        margin: EdgeInsets.only(top: _isPressed ? 4 : 0),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: widget.borderRadius,
          border: Border(
            bottom: BorderSide(
              color: widget.shadowColor,
              width: _isPressed ? 0 : 4,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: widget.padding,
          child: DefaultTextStyle(
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
