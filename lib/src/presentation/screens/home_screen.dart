import 'dart:async'; // Import for Timer
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import '../../application/besoin_notifier.dart';
import '../../application/daily_budget_notifier.dart';
import '../../domain/besoin.dart';
import '../../domain/daily_budget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Besoins Quotidiens'),
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard),
            onPressed: () => context.go('/dashboard'),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => context.go('/summary'),
          ),
        ],
      ),
      body: const HomeScreenBody(),
      floatingActionButton: FloatingActionButton.extended(
      onPressed: () => context.go('/add'),
      icon: const Icon(Icons.post_add),
      label: const Text('Ajouter'),
      backgroundColor: Colors.blueAccent,
      foregroundColor: Theme.of(context).colorScheme.onSecondary,
      tooltip: 'Ajouter un nouveau besoin',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}

class HomeScreenBody extends ConsumerStatefulWidget {
  const HomeScreenBody({super.key});

  @override
  ConsumerState<HomeScreenBody> createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends ConsumerState<HomeScreenBody> {
  final Map<String, TextEditingController> _budgetControllers = {};
  final Map<String, Timer?> _debounceTimers = {}; // Map to hold timers for each date

  @override
  void dispose() {
    _budgetControllers.forEach((key, controller) => controller.dispose());
    _debounceTimers.forEach((key, timer) => timer?.cancel()); // Cancel all active timers
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final besoinsState = ref.watch(besoinNotifierProvider);



// Helper Widgets
Widget buildBudgetCard(String title, double amount, IconData icon, Color color) {
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
          '${amount.toStringAsFixed(0)} MGA',
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
      content: const Text('Voulez-vous vraiment supprimer ce besoin ?'),
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


    return besoinsState.when(
        data: (besoins) {
          if (besoins.isEmpty) {
            return const Center(
              child: Text('Aucun besoin pour le moment.'),
            );
          }

          final groupedBesoins = groupBy(besoins, (Besoin b) => DateFormat('dd MMMM yyyy', 'fr_FR').format(b.date));

          return ListView.builder(
            itemCount: groupedBesoins.length,
            itemBuilder: (context, index) {
              final dateString = groupedBesoins.keys.elementAt(index);
              // Ensure the date used for the provider key is date-only (midnight)
              final date = DateTime(DateFormat('dd MMMM yyyy', 'fr_FR').parse(dateString).year,
                                    DateFormat('dd MMMM yyyy', 'fr_FR').parse(dateString).month,
                                    DateFormat('dd MMMM yyyy', 'fr_FR').parse(dateString).day);

              final besoinsDuJour = groupedBesoins[dateString]!;
              final totalDepense = besoinsDuJour.fold<double>(0, (prev, element) => prev + element.prix);

              final dailyBudgetState = ref.watch(dailyBudgetNotifierProvider(date));

              // Initialize or update controller for this date
              if (!_budgetControllers.containsKey(dateString)) {
                _budgetControllers[dateString] = TextEditingController();
              }
              dailyBudgetState.whenOrNull(
                data: (dailyBudget) {
                  final newText = (dailyBudget?.amount ?? 0.0).toString();
                  if (_budgetControllers[dateString]!.text != newText) {
                    _budgetControllers[dateString]!.text = newText;
                  }
                },
              );

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
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
                    iconColor: const Color(0xFF6B73FF),
                    collapsedIconColor: const Color(0xFF6B73FF),
                    shape: const Border(),
                    collapsedShape: const Border(),
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6B73FF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: const Icon(
                            Icons.calendar_today,
                            color: Color(0xFF6B73FF),
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          dateString,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 12.0, left: 5.0),
                      child: dailyBudgetState.when(
                        data: (dailyBudget) {
                          final budgetAmount = dailyBudget?.amount ?? 0.0;
                          final reste = budgetAmount - totalDepense;
                          final budgetProgress = budgetAmount > 0 ? (totalDepense / budgetAmount).clamp(0.0, 1.0) : 0.0;
                          
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Budget Overview Cards
                              Row(
                                children: [
                                  Expanded(
                                    child: buildBudgetCard(
                                      'Budget',
                                      budgetAmount,
                                      Icons.account_balance_wallet,
                                      const Color(0xFF10B981),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: buildBudgetCard(
                                      'Dépensé',
                                      totalDepense,
                                      Icons.trending_up,
                                      const Color(0xFFEF4444),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: buildBudgetCard(
                                      'Reste',
                                      reste,
                                      Icons.savings,
                                      reste >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Progress Bar
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Utilisation du budget',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        '${(budgetProgress * 100).toStringAsFixed(0)}%',
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
                                    value: budgetProgress,
                                    backgroundColor: Colors.grey[200],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      budgetProgress > 0.9 ? const Color(0xFFEF4444) : const Color(0xFF6B73FF),
                                    ),
                                    minHeight: 6,
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                        loading: () => const _LoadingBudgetCard(),
                        error: (error, stackTrace) => _ErrorBudgetCard(error: error.toString()),
                      ),
                    ),
                    children: [
                      Container(
                        color: const Color(0xFFF8FAFC),
                        child: Column(
                          children: [
                            // Budget Input Section
                            Container(
                              padding: const EdgeInsets.all(20.0),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                border: Border(
                                  top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Définir le budget quotidien',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2D3748),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _budgetControllers[dateString],
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Montant en MGA',
                                      hintText: 'Ex: 50000',
                                      prefixIcon: const Icon(Icons.attach_money, color: Color(0xFF6B73FF)),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.0),
                                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.0),
                                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.0),
                                        borderSide: const BorderSide(color: Color(0xFF6B73FF), width: 2),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                    ),
                                    onChanged: (value) {
                                      _debounceTimers[dateString]?.cancel();
                                      _debounceTimers[dateString] = Timer(const Duration(milliseconds: 800), () {
                                        final amount = double.tryParse(value);
                                        if (amount != null) {
                                          final budget = DailyBudget()
                                            ..date = date
                                            ..amount = amount;
                                          ref.read(dailyBudgetNotifierProvider(date).notifier).saveDailyBudget(budget);
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            // Needs List Section
                            if (besoinsDuJour.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.list_alt, color: Color(0xFF6B73FF), size: 20),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Besoins du jour',
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
                                        color: const Color(0xFF6B73FF).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${besoinsDuJour.length}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF6B73FF),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ...besoinsDuJour.asMap().entries.map((entry) {
                                final index = entry.key;
                                final besoin = entry.value;
                                final isLast = index == besoinsDuJour.length - 1;
                                
                                return Container(
                                  margin: EdgeInsets.only(
                                    left: 20,
                                    right: 20,
                                    bottom: isLast ? 20 : 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12.0),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    leading: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF6B73FF).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.shopping_cart,
                                        color: Color(0xFF6B73FF),
                                        size: 20,
                                      ),
                                    ),
                                    title: Text(
                                      besoin.titre,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2D3748),
                                      ),
                                    ),
                                    subtitle: besoin.description?.isNotEmpty == true
                                        ? Padding(
                                            padding: const EdgeInsets.only(top: 4),
                                            child: Text(
                                              besoin.description!,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          )
                                        : null,
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
                                          icon: const Icon(Icons.more_vert, color: Color(0xFF6B73FF)),
                                          onSelected: (value) async {
                                            if (value == 'edit') {
                                              context.go('/edit', extra: besoin);
                                            } else if (value == 'delete') {
                                              final confirm = await _showDeleteDialog(context);
                                              if (confirm == true) {
                                                ref.read(besoinNotifierProvider.notifier).deleteBesoin(besoin.key);
                                              }
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            const PopupMenuItem(
                                              value: 'edit',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.edit, color: Color(0xFF6B73FF), size: 18),
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
                                      'Aucun besoin ajouté',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Commencez par ajouter vos besoins quotidiens',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[500],
                                      ),
                                      textAlign: TextAlign.center,
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
      );
  }
}

class _ErrorBudgetCard extends StatelessWidget {
  final String error;
  
  const _ErrorBudgetCard({required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Erreur: $error',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFEF4444),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingBudgetCard extends StatelessWidget {
  const _LoadingBudgetCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(
            'Chargement du budget...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}