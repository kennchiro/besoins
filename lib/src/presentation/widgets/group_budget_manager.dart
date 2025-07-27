import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/besoin_apart.dart';
import '../../application/besoin_apart_notifier.dart';

class GroupBudgetManager extends ConsumerStatefulWidget {
  final String groupTitle;
  final List<BesoinApart> groupBesoins;
  final double totalCost;

  const GroupBudgetManager({
    super.key,
    required this.groupTitle,
    required this.groupBesoins,
    required this.totalCost,
  });

  @override
  ConsumerState<GroupBudgetManager> createState() => _GroupBudgetManagerState();
}

class _GroupBudgetManagerState extends ConsumerState<GroupBudgetManager> {
  final TextEditingController _budgetController = TextEditingController();
  Timer? _debounceTimer;
  bool _hasBudget = false;
  double? _budgetAmount;

  @override
  void initState() {
    super.initState();
    _initializeBudgetInfo();
  }

  @override
  void dispose() {
    _budgetController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeBudgetInfo() async {
    if (widget.groupBesoins.isNotEmpty) {
      final firstBesoin = widget.groupBesoins.first;
      setState(() {
        _hasBudget = firstBesoin.hasBudget;
        _budgetAmount = firstBesoin.budgetAmount;
        _budgetController.text = _budgetAmount?.toString() ?? '';
      });
    }
  }

  Future<void> _toggleBudget(bool value) async {
    setState(() {
      _hasBudget = value;
      if (!value) {
        _budgetAmount = null;
        _budgetController.clear();
      }
    });
    
    await ref.read(besoinApartNotifierProvider.notifier)
        .updateGroupBudget(widget.groupTitle, value, value ? _budgetAmount : null);
  }

  Future<void> _updateBudget(String value) async {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () async {
      final amount = double.tryParse(value);
      if (amount != null && _hasBudget) {
        setState(() {
          _budgetAmount = amount;
        });
        await ref.read(besoinApartNotifierProvider.notifier)
            .updateGroupBudget(widget.groupTitle, true, amount);
      }
    });
  }

  Widget _buildBudgetCard(String title, double amount, IconData icon, Color color) {
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Budget Toggle Section
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
              Row(
                children: [
                  const Icon(Icons.account_balance_wallet, color: Color(0xFF8B5CF6), size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Gestion du budget',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const Spacer(),
                  Switch(
                    value: _hasBudget,
                    onChanged: _toggleBudget,
                    activeColor: const Color(0xFF8B5CF6),
                  ),
                ],
              ),
              if (_hasBudget) ...[
                const SizedBox(height: 16),
                
                // Budget Overview Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildBudgetCard(
                        'Budget',
                        _budgetAmount ?? 0.0,
                        Icons.account_balance_wallet,
                        const Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildBudgetCard(
                        'Dépensé',
                        widget.totalCost,
                        Icons.trending_up,
                        const Color(0xFFEF4444),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildBudgetCard(
                        'Reste',
                        (_budgetAmount ?? 0.0) - widget.totalCost,
                        Icons.savings,
                        ((_budgetAmount ?? 0.0) - widget.totalCost) >= 0 
                          ? const Color(0xFF10B981) 
                          : const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Budget Input Field
                TextFormField(
                  controller: _budgetController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Montant du budget en MGA',
                    hintText: 'Ex: 500000',
                    prefixIcon: const Icon(Icons.attach_money, color: Color(0xFF8B5CF6)),
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
                      borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  onChanged: _updateBudget,
                ),
                const SizedBox(height: 12),
                
                // Progress Bar
                if (_budgetAmount != null && _budgetAmount! > 0) ...[
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
                            '${((widget.totalCost / _budgetAmount!) * 100).toStringAsFixed(0)}%',
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
                        value: (widget.totalCost / _budgetAmount!).clamp(0.0, 1.0),
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          (widget.totalCost / _budgetAmount!) > 0.9 
                            ? const Color(0xFFEF4444) 
                            : const Color(0xFF8B5CF6),
                        ),
                        minHeight: 6,
                      ),
                    ],
                  ),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }
}
