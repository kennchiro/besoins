import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import '../../application/besoin_apart_notifier.dart';
import '../../domain/besoin_apart.dart';

class BesoinsApartScreen extends ConsumerStatefulWidget {
  const BesoinsApartScreen({super.key});

  @override
  ConsumerState<BesoinsApartScreen> createState() => _BesoinsApartScreenState();
}

class _BesoinsApartScreenState extends ConsumerState<BesoinsApartScreen> {
  @override
  Widget build(BuildContext context) {
    final besoinsApartState = ref.watch(besoinApartNotifierProvider);

    return Scaffold(
      body: besoinsApartState.when(
        data: (besoinsApart) {
          if (besoinsApart.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.list_alt_outlined,
                    size: 64,
                    color: Color(0xFF9CA3AF),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Aucun besoin à part',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Créez des groupes de besoins sans contrainte de date',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF9CA3AF),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Group besoins by groupTitle
          final groupedBesoins = groupBy(besoinsApart, (BesoinApart b) => b.groupTitle);

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groupedBesoins.length,
            itemBuilder: (context, index) {
              final groupTitle = groupedBesoins.keys.elementAt(index);
              final groupBesoins = groupedBesoins[groupTitle]!;
              final totalCost = groupBesoins.fold<double>(0, (prev, element) => prev + element.prix);
              final completedCount = groupBesoins.where((b) => b.isCompleted).length;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    childrenPadding: const EdgeInsets.all(0),
                    backgroundColor: Colors.white,
                    collapsedBackgroundColor: Colors.white,
                    iconColor: const Color(0xFF8B5CF6),
                    collapsedIconColor: const Color(0xFF8B5CF6),
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: const Icon(
                            Icons.folder_outlined,
                            color: Color(0xFF8B5CF6),
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            groupTitle,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 12.0, left: 5.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoCard(
                                  'Total',
                                  '${totalCost.toStringAsFixed(0)} MGA',
                                  Icons.account_balance_wallet,
                                  const Color(0xFF8B5CF6),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildInfoCard(
                                  'Éléments',
                                  '${groupBesoins.length}',
                                  Icons.list_alt,
                                  const Color(0xFF06B6D4),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildInfoCard(
                                  'Complétés',
                                  '$completedCount',
                                  Icons.check_circle,
                                  const Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Progress bar
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Progression',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '${groupBesoins.isNotEmpty ? ((completedCount / groupBesoins.length) * 100).toStringAsFixed(0) : 0}%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: groupBesoins.isNotEmpty ? completedCount / groupBesoins.length : 0,
                                backgroundColor: Colors.grey[200],
                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                                minHeight: 6,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    children: [
                      Container(
                        color: const Color(0xFFF8FAFC),
                        child: Column(
                          children: [
                            if (groupBesoins.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.list_alt, color: Color(0xFF8B5CF6), size: 20),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Éléments du groupe',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2D3748),
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF8B5CF6).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${groupBesoins.length}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF8B5CF6),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ...groupBesoins.asMap().entries.map((entry) {
                                final index = entry.key;
                                final besoin = entry.value;
                                final isLast = index == groupBesoins.length - 1;
                                
                                return Container(
                                  margin: EdgeInsets.only(
                                    left: 20,
                                    right: 20,
                                    bottom: isLast ? 20 : 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12.0),
                                    border: Border.all(
                                      color: besoin.isCompleted 
                                        ? const Color(0xFF10B981).withOpacity(0.3)
                                        : const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    leading: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: besoin.isCompleted 
                                          ? const Color(0xFF10B981).withOpacity(0.1)
                                          : const Color(0xFF8B5CF6).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        besoin.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                                        color: besoin.isCompleted ? const Color(0xFF10B981) : const Color(0xFF8B5CF6),
                                        size: 20,
                                      ),
                                    ),
                                    title: Text(
                                      besoin.titre,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF2D3748),
                                        decoration: besoin.isCompleted ? TextDecoration.lineThrough : null,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (besoin.description?.isNotEmpty == true)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 4),
                                            child: Text(
                                              besoin.description!,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                                decoration: besoin.isCompleted ? TextDecoration.lineThrough : null,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Ajouté le ${DateFormat('dd/MM/yyyy', 'fr_FR').format(besoin.dateCreated)}',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF10B981).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '${besoin.prix} MGA',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF10B981),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        PopupMenuButton<String>(
                                          icon: const Icon(Icons.more_vert, color: Color(0xFF8B5CF6)),
                                          onSelected: (value) async {
                                            if (value == 'toggle') {
                                              final updatedBesoin = BesoinApart()
                                                ..titre = besoin.titre
                                                ..description = besoin.description
                                                ..prix = besoin.prix
                                                ..dateCreated = besoin.dateCreated
                                                ..category = besoin.category
                                                ..groupTitle = besoin.groupTitle
                                                ..isCompleted = !besoin.isCompleted;
                                              
                                              // Copy the key from the original
                                              if (besoin.isInBox) {
                                                await besoin.delete();
                                                await ref.read(besoinApartNotifierProvider.notifier).addBesoinApart(updatedBesoin);
                                              }
                                            } else if (value == 'edit') {
                                              // TODO: Navigate to edit screen
                                            } else if (value == 'delete') {
                                              final confirm = await _showDeleteDialog(context);
                                              if (confirm == true) {
                                                ref.read(besoinApartNotifierProvider.notifier).deleteBesoinApart(besoin.key);
                                              }
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            PopupMenuItem(
                                              value: 'toggle',
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    besoin.isCompleted ? Icons.undo : Icons.check_circle,
                                                    color: besoin.isCompleted ? const Color(0xFF8B5CF6) : const Color(0xFF10B981),
                                                    size: 18,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(besoin.isCompleted ? 'Marquer non fait' : 'Marquer fait'),
                                                ],
                                              ),
                                            ),
                                            const PopupMenuItem(
                                              value: 'edit',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.edit, color: Color(0xFF8B5CF6), size: 18),
                                                  SizedBox(width: 8),
                                                  Text('Modifier'),
                                                ],
                                              ),
                                            ),
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.delete, color: Color(0xFFEF4444), size: 18),
                                                  SizedBox(width: 8),
                                                  Text('Supprimer'),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ] else
                              Container(
                                padding: const EdgeInsets.all(40.0),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.receipt_long,
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Aucun élément dans ce groupe',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Erreur: $error'),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Color(0xFFEF4444)),
            SizedBox(width: 8),
            Text('Confirmation'),
          ],
        ),
        content: const Text('Voulez-vous vraiment supprimer cet élément ?'),
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
  }
}
