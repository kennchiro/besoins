import 'package:flutter/material.dart';

/// A reusable dropdown widget with consistent styling across the app
class AppDropdown<T> extends StatelessWidget {
  final String? label;
  final String? hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;
  final bool isRequired;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final String? errorText;

  const AppDropdown({
    super.key,
    this.label,
    this.hint,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.isRequired = false,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Row(
            children: [
              Text(
                label!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151),
                ),
              ),
              if (isRequired)
                const Text(
                  ' *',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFEF4444),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: enabled ? onChanged : null,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: enabled 
                ? Colors.white 
                : const Color(0xFFF3F4F6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(
                color: Color(0xFFD1D5DB),
                width: 1.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(
                color: Color(0xFFD1D5DB),
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(
                color: Color(0xFF3B82F6),
                width: 2.0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444),
                width: 2.0,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444),
                width: 2.0,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
                width: 1.0,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 14.0,
            ),
            hintStyle: const TextStyle(
              fontSize: 16,
              color: Color(0xFF9CA3AF),
            ),
            errorText: errorText,
          ),
          style: TextStyle(
            fontSize: 16,
            color: enabled 
                ? const Color(0xFF111827) 
                : const Color(0xFF9CA3AF),
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          elevation: 4,
        ),
      ],
    );
  }
}

/// A specialized dropdown for categories
class CategoryDropdown extends StatelessWidget {
  final String? selectedCategoryId;
  final List<Map<String, dynamic>> categories;
  final ValueChanged<String?>? onChanged;
  final String? Function(String?)? validator;
  final bool isRequired;

  const CategoryDropdown({
    super.key,
    this.selectedCategoryId,
    required this.categories,
    this.onChanged,
    this.validator,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppDropdown<String>(
      label: 'Catégorie',
      hint: 'Sélectionner une catégorie',
      value: selectedCategoryId,
      isRequired: isRequired,
      validator: validator,
      onChanged: onChanged,
      prefixIcon: const Icon(
        Icons.category_outlined,
        color: Color(0xFF6B7280),
      ),
      items: categories.map((category) {
        return DropdownMenuItem<String>(
          value: category['id'],
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Color(category['color'] ?? 0xFF6B7280),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  category['name'],
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// A specialized dropdown for group titles
class GroupTitleDropdown extends StatelessWidget {
  final String? selectedGroupTitle;
  final List<String> groupTitles;
  final ValueChanged<String?>? onChanged;
  final String? Function(String?)? validator;
  final bool isRequired;
  final bool allowCustom;

  const GroupTitleDropdown({
    super.key,
    this.selectedGroupTitle,
    required this.groupTitles,
    this.onChanged,
    this.validator,
    this.isRequired = false,
    this.allowCustom = true,
  });

  @override
  Widget build(BuildContext context) {
    final items = <DropdownMenuItem<String>>[];
    
    // Add existing group titles
    for (final groupTitle in groupTitles) {
      items.add(
        DropdownMenuItem<String>(
          value: groupTitle,
          child: Text(groupTitle),
        ),
      );
    }
    
    // Add option to create new group if allowed
    if (allowCustom) {
      items.add(
        const DropdownMenuItem<String>(
          value: '__custom__',
          child: Row(
            children: [
              Icon(
                Icons.add_circle_outline,
                size: 20,
                color: Color(0xFF3B82F6),
              ),
              SizedBox(width: 8),
              Text(
                'Nouveau groupe...',
                style: TextStyle(
                  color: Color(0xFF3B82F6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return AppDropdown<String>(
      label: 'Groupe',
      hint: 'Sélectionner un groupe',
      value: selectedGroupTitle,
      isRequired: isRequired,
      validator: validator,
      onChanged: onChanged,
      prefixIcon: const Icon(
        Icons.folder_outlined,
        color: Color(0xFF6B7280),
      ),
      items: items,
    );
  }
}
