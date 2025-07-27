import 'package:flutter/material.dart';

/// A reusable card widget with consistent styling across the app
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double elevation;
  final BorderRadius? borderRadius;
  final Border? border;
  final bool hasShadow;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation = 2.0,
    this.borderRadius,
    this.border,
    this.hasShadow = true,
    this.onTap,
  });

  /// Factory constructor for budget cards
  const AppCard.budget({
    super.key,
    required this.child,
    this.onTap,
  }) : padding = const EdgeInsets.all(16.0),
       margin = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
       backgroundColor = const Color(0xFFF8FAFC),
       elevation = 2.0,
       borderRadius = const BorderRadius.all(Radius.circular(12.0)),
       border = null,
       hasShadow = true;

  /// Factory constructor for info cards
  const AppCard.info({
    super.key,
    required this.child,
    this.onTap,
  }) : padding = const EdgeInsets.all(16.0),
       margin = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
       backgroundColor = Colors.white,
       elevation = 1.0,
       borderRadius = const BorderRadius.all(Radius.circular(12.0)),
       border = null,
       hasShadow = true;

  /// Factory constructor for list item cards
  const AppCard.listItem({
    super.key,
    required this.child,
    this.onTap,
  }) : padding = const EdgeInsets.all(12.0),
       margin = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
       backgroundColor = Colors.white,
       elevation = 1.0,
       borderRadius = const BorderRadius.all(Radius.circular(8.0)),
       border = null,
       hasShadow = true;

  /// Factory constructor for outline cards
  const AppCard.outline({
    super.key,
    required this.child,
    this.onTap,
  }) : padding = const EdgeInsets.all(16.0),
       margin = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
       backgroundColor = Colors.white,
       elevation = 0.0,
       borderRadius = const BorderRadius.all(Radius.circular(12.0)),
       border = const Border.fromBorderSide(
         BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
       ),
       hasShadow = false;

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(12.0);
    
    Widget cardContent = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: effectiveBorderRadius,
        border: border,
        boxShadow: hasShadow && elevation > 0
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: elevation * 2,
                  offset: Offset(0, elevation),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16.0),
        child: child,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: effectiveBorderRadius,
        child: cardContent,
      );
    }

    return cardContent;
  }
}

/// A specialized card for displaying budget information
class BudgetCard extends StatelessWidget {
  final String title;
  final double budget;
  final double spent;
  final String currency;
  final VoidCallback? onTap;

  const BudgetCard({
    super.key,
    required this.title,
    required this.budget,
    required this.spent,
    this.currency = '€',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = budget - spent;
    final progress = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
    final isOverBudget = spent > budget;

    return AppCard.budget(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Budget',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '$budget$currency',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Dépensé',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '$spent$currency',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isOverBudget 
                          ? const Color(0xFFEF4444) 
                          : const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              isOverBudget 
                  ? const Color(0xFFEF4444) 
                  : const Color(0xFF10B981),
            ),
            minHeight: 6,
          ),
          const SizedBox(height: 8),
          Text(
            isOverBudget
                ? 'Dépassement: ${(-remaining).toStringAsFixed(2)}$currency'
                : 'Restant: ${remaining.toStringAsFixed(2)}$currency',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isOverBudget 
                  ? const Color(0xFFEF4444) 
                  : const Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }
}
