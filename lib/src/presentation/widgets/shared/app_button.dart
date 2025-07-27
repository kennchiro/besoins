import 'package:flutter/material.dart';

/// A reusable button widget with consistent styling across the app
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final ButtonVariant variant;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 56.0,
    this.variant = ButtonVariant.primary,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveBackgroundColor = backgroundColor ?? _getBackgroundColor();
    final Color effectiveTextColor = textColor ?? _getTextColor();
    
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveBackgroundColor,
          foregroundColor: effectiveTextColor,
          elevation: variant == ButtonVariant.primary ? 2 : 0,
          shadowColor: variant == ButtonVariant.primary 
              ? const Color(0xFF8B5CF6).withOpacity(0.3) 
              : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: variant == ButtonVariant.outline
                ? const BorderSide(color: Color(0xFF8B5CF6), width: 1.5)
                : BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(effectiveTextColor),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: effectiveTextColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (variant) {
      case ButtonVariant.primary:
        return const Color(0xFF8B5CF6);
      case ButtonVariant.secondary:
        return const Color(0xFFF1F5F9);
      case ButtonVariant.outline:
        return Colors.transparent;
      case ButtonVariant.danger:
        return const Color(0xFFEF4444);
    }
  }

  Color _getTextColor() {
    switch (variant) {
      case ButtonVariant.primary:
        return Colors.white;
      case ButtonVariant.secondary:
        return const Color(0xFF475569);
      case ButtonVariant.outline:
        return const Color(0xFF8B5CF6);
      case ButtonVariant.danger:
        return Colors.white;
    }
  }
}

enum ButtonVariant {
  primary,
  secondary,
  outline,
  danger,
}
