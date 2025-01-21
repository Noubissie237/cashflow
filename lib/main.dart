import 'package:cashflow/services/auth_service.dart';
import 'package:cashflow/services/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/goals_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authService = AuthService();
  final userId = await authService.getUserId();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeService(),
      child: MyApp(userId: userId),
    ),
  );
}

class MyApp extends StatelessWidget {
  final int? userId;

  const MyApp({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CashFlow',
      theme: themeService.currentTheme.copyWith(
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
        ),
      ),
      home: userId != null
          ? NavigationWrapper(utilisateurId: userId!)
          : const LoginScreen(),
    );
  }
}

class NavigationWrapper extends StatefulWidget {
  final int utilisateurId;

  const NavigationWrapper({super.key, required this.utilisateurId});

  @override
  State<NavigationWrapper> createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeScreen(utilisateurId: widget.utilisateurId),
      GoalsScreen(utilisateurId: widget.utilisateurId),
      HistoryScreen(utilisateurId: widget.utilisateurId),
      SettingsScreen(utilisateurId: widget.utilisateurId),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.blueGrey[900]
              : Colors.white,
          selectedItemColor: Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).primaryColor
              : Theme.of(context).primaryColorDark,
          unselectedItemColor:
              Theme.of(context).iconTheme.color?.withOpacity(0.7),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.flag_outlined),
              activeIcon: Icon(Icons.flag_rounded),
              label: 'Objectifs',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history_rounded),
              label: 'Historique',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings_rounded),
              label: 'Paramètres',
            ),
          ],
        ),
      ),
    );
  }
}
