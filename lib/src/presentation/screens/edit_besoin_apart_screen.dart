import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/besoin_apart.dart';
import '../../domain/category.dart';
import '../../application/besoin_apart_notifier.dart';
import '../../application/category_notifier.dart';
import '../widgets/shared/app_card.dart';
import '../widgets/shared/app_text_field.dart';

class EditBesoinApartScreen extends ConsumerStatefulWidget {
  final BesoinApart besoinApart;

  const EditBesoinApartScreen({
    super.key,
    required this.besoinApart,
  });

  @override
  ConsumerState<EditBesoinApartScreen> createState() => _EditBesoinApartScreenState();
}

class _EditBesoinApartScreenState extends ConsumerState<EditBesoinApartScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _groupTitleController;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  bool _isLoading = false;
  Category? _selectedCategory;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data
    _groupTitleController = TextEditingController(text: widget.besoinApart.groupTitle);
    _titleController = TextEditingController(text: widget.besoinApart.titre);
    _descriptionController = TextEditingController(text: widget.besoinApart.description);
    _priceController = TextEditingController(text: widget.besoinApart.prix.toString());
    _selectedCategory = widget.besoinApart.category;
  }

  @override
  void dispose() {
    _groupTitleController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _updateBesoinApart() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedBesoin = widget.besoinApart;
      updatedBesoin.titre = _titleController.text.trim();
      updatedBesoin.description = _descriptionController.text.trim();
      updatedBesoin.prix = double.parse(_priceController.text.trim());
      updatedBesoin.category = _selectedCategory;
      updatedBesoin.groupTitle = _groupTitleController.text.trim();

      await ref.read(besoinApartNotifierProvider.notifier).updateBesoinApart(updatedBesoin);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Besoin mis à jour avec succès!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la mise à jour: $e'),
            backgroundColor: Colors.red,
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

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoryNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le besoin'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informations du besoin',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _groupTitleController,
                      labelText: 'Titre du groupe',
                      hintText: 'Ex: Équipement sportif, Cuisine, etc.',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez saisir un titre de groupe';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _titleController,
                      labelText: 'Titre du besoin',
                      hintText: 'Ex: Ballon de football, Casserole, etc.',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez saisir un titre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _descriptionController,
                      labelText: 'Description',
                      hintText: 'Description détaillée du besoin',
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez saisir une description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _priceController,
                      labelText: 'Prix (€)',
                      hintText: '0.00',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez saisir un prix';
                        }
                        if (double.tryParse(value.trim()) == null) {
                          return 'Veuillez saisir un prix valide';
                        }
                        if (double.parse(value.trim()) < 0) {
                          return 'Le prix ne peut pas être négatif';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    categoriesState.when(
                      data: (categories) {
                        return Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: categories.map((category) {
                            final isSelected = _selectedCategory?.key == category.key;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCategory = isSelected ? null : category;
                                });
                              },
                              child: Chip(
                                label: Text(category.name),
                                backgroundColor: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
                              ),
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (error, stack) => Text('Erreur: $error'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateBesoinApart,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Mettre à jour',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
