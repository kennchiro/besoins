import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../application/besoin_notifier.dart';
import '../../application/category_notifier.dart';
import '../../domain/besoin.dart';
import '../../domain/category.dart';

class EditBesoinScreen extends ConsumerStatefulWidget {
  const EditBesoinScreen({super.key, required this.besoin});

  final Besoin besoin;

  @override
  ConsumerState<EditBesoinScreen> createState() => _EditBesoinScreenState();
}

class _EditBesoinScreenState extends ConsumerState<EditBesoinScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titreController;
  late TextEditingController _descriptionController;
  late TextEditingController _prixController;
  late DateTime _selectedDate;
  bool _isLoading = false;
  bool _hasChanges = false;

  Category? _selectedCategory;

  // Define a list of colors to cycle through for categories
  final List<Color> categoryColors = [
    Colors.blue.shade400,
    Colors.green.shade400,
    Colors.orange.shade400,
    Colors.red.shade400,
    Colors.purple.shade400,
    Colors.teal.shade400,
    Colors.pink.shade400,
    Colors.indigo.shade400,
  ];

  @override
  void initState() {
    super.initState();
    _titreController = TextEditingController(text: widget.besoin.titre);
    _descriptionController = TextEditingController(text: widget.besoin.description ?? '');
    _prixController = TextEditingController(text: widget.besoin.prix.toString());
    _selectedDate = widget.besoin.date;
    
    // Initialize _selectedCategory from widget.besoin.category
    _selectedCategory = widget.besoin.category;
    
    // Listen for changes
    _titreController.addListener(_onFormChanged);
    _descriptionController.addListener(_onFormChanged);
    _prixController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    final hasChanges = _titreController.text != widget.besoin.titre ||
        _descriptionController.text != (widget.besoin.description ?? '') ||
        _prixController.text != widget.besoin.prix.toString() ||
        _selectedDate != widget.besoin.date ||
        _selectedCategory?.key != widget.besoin.category?.key; // Use .key for Hive objects
    
    if (hasChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  @override
  void dispose() {
    _titreController.removeListener(_onFormChanged);
    _descriptionController.removeListener(_onFormChanged);
    _prixController.removeListener(_onFormChanged);
    _titreController.dispose();
    _descriptionController.dispose();
    _prixController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoryNotifierProvider);

    return WillPopScope(
      onWillPop: () async {
        if (_hasChanges) {
          return await _showUnsavedChangesDialog();
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF2D3748),
          title: const Text(
            'Modifier le besoin',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              TextButton(
                onPressed: _hasChanges ? _submitForm : null,
                child: Text(
                  'Sauvegarder',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _hasChanges ? const Color(0xFF6B73FF) : Colors.grey,
                  ),
                ),
              ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Color(0xFFF59E0B),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Modifier le besoin',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF2D3748),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Créé le ${DateFormat('dd/MM/yyyy').format(widget.besoin.date)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_hasChanges)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Modifié',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFF59E0B),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Form Section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title Field
                      _buildSectionTitle('Informations générales'),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _titreController,
                        label: 'Titre du besoin',
                        hint: 'Ex: Achat de riz',
                        icon: Icons.title,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un titre';
                          }
                          if (value.length < 3) {
                            return 'Le titre doit contenir au moins 3 caractères';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Description Field
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Description (optionnel)',
                        hint: 'Ajoutez des détails sur ce besoin...',
                        icon: Icons.description,
                        maxLines: 3,
                        isOptional: true,
                      ),

                      const SizedBox(height: 24),

                      // Price and Date Section
                      _buildSectionTitle('Prix et date'),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _prixController,
                        label: 'Prix',
                        hint: '0',
                        icon: Icons.attach_money,
                        keyboardType: TextInputType.number,
                        suffix: 'MGA',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un prix';
                          }
                          final price = double.tryParse(value);
                          if (price == null) {
                            return 'Prix invalide';
                          }
                          if (price <= 0) {
                            return 'Le prix doit être positif';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildDateSelector(),
                        const SizedBox(height: 16),
                          // Category Selection
                      _buildSectionTitle('Catégorie'),
                      const SizedBox(height: 16),
                      categoriesState.when(
                        data: (categories) {
                          return _buildCategorySelector(categories); // Pass categories to selector
                        },
                        loading: () => const CircularProgressIndicator(),
                        error: (error, stack) => Text('Erreur de chargement des catégories: $error'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Changes Summary (if any)
                if (_hasChanges)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFF59E0B).withOpacity(0.3),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFFF59E0B)),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Des modifications non sauvegardées sont en cours',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFF59E0B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () async {
                          if (_hasChanges) {
                            final shouldDiscard = await _showUnsavedChangesDialog();
                            if (shouldDiscard) {
                              if(context.mounted) context.pop();
                            }
                          } else {
                            context.pop();
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Annuler',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isLoading || !_hasChanges ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B73FF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Sauvegarder',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Danger Zone
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.05),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.warning_amber, color: Color(0xFFEF4444)),
                          SizedBox(width: 8),
                          Text(
                            'Zone dangereuse',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'La suppression de ce besoin est irréversible.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : _showDeleteConfirmation,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: Color(0xFFEF4444)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Supprimer ce besoin',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFEF4444),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
   
    Future<void> _showDeleteConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_forever, color: Color(0xFFEF4444)),
            SizedBox(width: 8),
            Text('Supprimer le besoin'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Êtes-vous sûr de vouloir supprimer ce besoin ?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.besoin.titre,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.besoin.prix} MGA',
                    style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Cette action est irréversible.',
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        setState(() {
          _isLoading = true;
        });
        
        await ref.read(besoinNotifierProvider.notifier).deleteBesoin(widget.besoin.key); // Use .id for Hive objects
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Besoin supprimé avec succès'),
                ],
              ),
              backgroundColor: Color(0xFF10B981),
              duration: Duration(seconds: 2),
            ),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Erreur: ${e.toString()}'),
                ],
              ),
              backgroundColor: const Color(0xFFEF4444),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
  

   Future<bool> _showUnsavedChangesDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Color(0xFFF59E0B)),
            SizedBox(width: 8),
            Text('Modifications non sauvegardées'),
          ],
        ),
        content: const Text(
          'Vous avez des modifications non sauvegardées. Voulez-vous vraiment quitter sans sauvegarder ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.white,
            ),
            child: const Text('Quitter sans sauvegarder'),
          ),
        ],
      ),
    ) ?? false;
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF2D3748),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool isOptional = false,
    String? suffix,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF6B73FF)),
        suffixText: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6B73FF), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildCategorySelector(List<Category> categories) { // Now takes categories as parameter
    // Define a list of colors to cycle through for categories
    final List<Color> categoryColors = [
      Colors.blue.shade400,
      Colors.green.shade400,
      Colors.orange.shade400,
      Colors.red.shade400,
      Colors.purple.shade400,
      Colors.teal.shade400,
      Colors.pink.shade400,
      Colors.indigo.shade400,
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: categories.map((category) {
        final isSelected = _selectedCategory?.key == category.key; // Use .key for Hive objects
        final categoryColor = categoryColors[categories.indexOf(category) % categoryColors.length];

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCategory = isSelected ? null : category;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? categoryColor : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? categoryColor : const Color(0xFFE2E8F0),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.category, color: isSelected ? Colors.white : categoryColor, size: 18), // Generic icon
                const SizedBox(width: 8),
                Text(
                  category.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Color(0xFF6B73FF), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Date',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('dd/MM/yyyy').format(_selectedDate),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6B73FF),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF2D3748),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final updatedBesoin = widget.besoin
          ..titre = _titreController.text.trim()
          ..description = _descriptionController.text.trim().isEmpty 
              ? null 
              : _descriptionController.text.trim()
          ..prix = double.parse(_prixController.text)
          ..date = _selectedDate;

        // Link category to besoin
        updatedBesoin.category = _selectedCategory; // Direct assignment for Hive

        await ref.read(besoinNotifierProvider.notifier).updateBesoin(updatedBesoin);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Besoin modifié avec succès'),
                ],
              ),
              backgroundColor: Color(0xFF10B981),
              duration: Duration(seconds: 2),
            ),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Erreur: ${e.toString()}'),
                ],
              ),
              backgroundColor: const Color(0xFFEF4444),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}
