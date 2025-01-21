import 'package:cashflow/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';
// import '../models/utilisateur.dart';
// import '../services/database.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  final int utilisateurId;

  const SettingsScreen({super.key, required this.utilisateurId});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // final _dbService = DatabaseService();
  bool _biometricEnabled = false;
  String _currency = 'XAF';
  String _language = 'Français';
  // ignore: unused_field
  bool _isLoading = false;

  Future<void> _logout() async {
    setState(() => _isLoading = true);
    try {
      await AuthService().clearUserId();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Déconnecter'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AboutDialog(
        applicationName: 'CashFlow',
        applicationVersion: '1.0.0',
        applicationIcon: const Icon(
          Icons.account_balance_wallet,
          size: 50,
          color: Colors.blue,
        ),
        children: [
          const Text(
            'CashFlow est votre compagnon de gestion financière personnelle. '
            'Suivez vos dépenses, définissez des objectifs et prenez le contrôle de vos finances.',
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.person, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'NOUBISSIE K. WILFRIED',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.phone, color: Colors.blue),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () =>
                          lienExterne("https://wa.me/+237690232120"),
                      child: const Text(
                        '+237 690 232 120',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Paramètres',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        children: [
          // Section Thème et Affichage
          _buildSection(
            'THÈME ET AFFICHAGE',
            [
              SwitchListTile(
                title: const Text('Mode sombre'),
                subtitle: const Text('Activer le thème sombre'),
                secondary: Icon(
                  themeService.isDarkMode
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  color: Theme.of(context).primaryColor,
                ),
                value: themeService.isDarkMode,
                onChanged: (value) => themeService.toggleTheme(),
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('Devise'),
                subtitle: Text(_currency),
                leading: const Icon(Icons.currency_exchange),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Implémenter le changement de devise
                },
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('Langue'),
                subtitle: Text(_language),
                leading: const Icon(Icons.language),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Implémenter le changement de langue
                },
              ),
            ],
          ),

          // Section Sécurité
          _buildSection(
            'SÉCURITÉ',
            [
              SwitchListTile(
                title: const Text('Authentification biométrique'),
                subtitle:
                    const Text('Utiliser l\'empreinte digitale ou Face ID'),
                secondary: const Icon(Icons.fingerprint),
                value: _biometricEnabled,
                onChanged: (value) => setState(() => _biometricEnabled = value),
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('Changer le mot de passe'),
                leading: const Icon(Icons.lock_outlined),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Implémenter le changement de mot de passe
                },
              ),
            ],
          ),

          // Section À propos
          _buildSection(
            'À PROPOS',
            [
              ListTile(
                title: const Text('À propos de CashFlow'),
                leading: const Icon(Icons.info_outline),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _showAboutDialog,
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('Politique de confidentialité'),
                leading: const Icon(Icons.privacy_tip_outlined),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Implémenter l'ouverture de la politique de confidentialité
                },
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('Conditions d\'utilisation'),
                leading: const Icon(Icons.description_outlined),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Implémenter l'ouverture des conditions d'utilisation
                },
              ),
            ],
          ),

          // Section Compte
          _buildSection(
            'COMPTE',
            [
              ListTile(
                title: const Text('Se déconnecter'),
                leading: const Icon(Icons.logout, color: Colors.red),
                onTap: _showLogoutDialog,
              ),
            ],
          ),

          const SizedBox(height: 32),
          Center(
            child: Text(
              'Version 1.0.0',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
