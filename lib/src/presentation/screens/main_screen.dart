import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'home_screen.dart';
import 'besoins_apart_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 0 ? 'Besoins Quotidiens' : 'Besoins à Part'),
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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.calendar_today),
              text: 'Quotidiens',
            ),
            Tab(
              icon: Icon(Icons.list_alt),
              text: 'À Part',
            ),
          ],
          indicatorColor: Theme.of(context).primaryColor,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey[600],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          HomeScreenBody(), // Use the extracted body from HomeScreen
          BesoinsApartScreen(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_currentIndex == 0) {
            // Daily needs - go to existing add screen
            context.go('/add');
          } else {
            // Separate needs - go to new add screen
            context.go('/add-apart');
          }
        },
        icon: const Icon(Icons.add),
        label: Text(_currentIndex == 0 ? 'Ajouter Besoin' : 'Ajouter Groupe'),
        backgroundColor: _currentIndex == 0 ? Colors.blueAccent : const Color(0xFF8B5CF6),
        foregroundColor: Colors.white,
        tooltip: _currentIndex == 0 ? 'Ajouter un nouveau besoin quotidien' : 'Ajouter un groupe de besoins',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}

