import 'package:flutter/material.dart';
import '../data/contracts_controller.dart';
import '../data/catalog_controller.dart';
import '../l10n.dart';
import 'dashboard_screen.dart';
import 'upload_screen.dart';
import 'observations_screen.dart';
import 'knowledge_screen.dart';
import 'settings_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  // Bewusst NICHT const: bei Sprachwechsel rebuildet ValueListenableBuilder den
  // Shell — nur frisch erzeugte (nicht-identische) Kinder bauen dann neu und
  // übernehmen die neue Sprache. Const-Kinder würde Flutter überspringen.
  List<Widget> get _screens => [
        DashboardScreen(),
        UploadScreen(),
        ObservationsScreen(),
        KnowledgeScreen(),
        SettingsScreen(),
      ];

  @override
  void initState() {
    super.initState();
    // Einmal zentral laden; alle Tabs lauschen auf den Controller.
    contractsController.load();
    catalogController.load();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appLocale,
      builder: (context, _, _) => Scaffold(
        body: IndexedStack(index: _index, children: _screens),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard_outlined),
              label: t('Übersicht', 'Overview'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.folder_copy_outlined),
              label: t('Verträge', 'Contracts'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.visibility_outlined),
              label: t('Beobachtungen', 'Observations'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.menu_book_outlined),
              label: t('Wissen', 'Learn'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              label: t('Profil', 'Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
