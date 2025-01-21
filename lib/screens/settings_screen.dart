import 'package:cashflow/screens/security_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';
import '../utils/utils.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  final int utilisateurId;

  const SettingsScreen({super.key, required this.utilisateurId});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String _currency = 'XAF';
  String _language = 'Français';
  bool isLoading = false;

  final Map<String, String> _currencySymbols = {
    'XAF': 'FCFA',
    'USD': '\$',
    'EUR': '€',
  };

  final Map<String, String> _languages = {
    'Français': 'fr',
    'English': 'en',
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showCurrencyPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Choisir une devise',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            ...['XAF']
                // ...['XAF', 'USD', 'EUR']
                .map((currency) => ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            Theme.of(context).primaryColor.withOpacity(0.1),
                        child: Text(
                          _currencySymbols[currency] ?? currency,
                          style: TextStyle(
                            color: Theme.of(context).iconTheme.color,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(currency),
                      subtitle: Text(_getCurrencyName(currency)),
                      trailing: _currency == currency
                          ? Icon(Icons.check_circle,
                              color: Theme.of(context).iconTheme.color)
                          : null,
                      onTap: () {
                        setState(() => _currency = currency);
                        Navigator.pop(context);
                      },
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  String _getCurrencyName(String currency) {
    switch (currency) {
      case 'XAF':
        return 'Franc CFA';
      case 'USD':
        return 'Dollar américain';
      case 'EUR':
        return 'Euro';
      default:
        return currency;
    }
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Choisir une langue',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            ...['Français']
                // ...['Français', 'English']
                .map((language) => ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            Theme.of(context).primaryColor.withOpacity(0.1),
                        child: Text(
                          _languages[language]?.toUpperCase() ?? language[0],
                          style: TextStyle(
                            color: Theme.of(context).iconTheme.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(language),
                      trailing: _language == language
                          ? Icon(Icons.check_circle,
                              color: Theme.of(context).iconTheme.color)
                          : null,
                      onTap: () {
                        setState(() => _language = language);
                        Navigator.pop(context);
                      },
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    setState(() => isLoading = true);
    try {
      await AuthService().clearUserId();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const LoginScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Déconnexion',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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
        applicationIcon: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.account_balance_wallet,
            size: 50,
            color: Colors.blue,
          ),
        ),
        children: [
          const Text(
            'CashFlow est votre compagnon de gestion financière personnelle. '
            'Suivez vos dépenses, définissez des objectifs et prenez le contrôle de vos finances.',
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 24),
          _buildContactCard(),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'NOUBISSIE K. WILFRIED',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: Icon(
                  Icons.phone,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () => lienExterne("https://wa.me/+237690232120"),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  '+237 690 232 120',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
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
              children: children.map((child) {
                final index = children.indexOf(child);
                final isLast = index == children.length - 1;

                if (child is Divider) return child;

                if (child is ListTile) {
                  return Container(
                    decoration: BoxDecoration(
                      border: !isLast
                          ? Border(
                              bottom: BorderSide(
                                color: Theme.of(context)
                                    .dividerColor
                                    .withOpacity(0.1),
                              ),
                            )
                          : null,
                    ),
                    child: child,
                  );
                }

                return child;
              }).toList(),
            ),
          ),
        ],
      ),
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
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          _buildSection(
            'THÈME ET AFFICHAGE',
            [
              SwitchListTile(
                title: const Text('Mode sombre'),
                subtitle: Text(
                  'Activer le thème sombre',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                secondary: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Icon(
                    themeService.isDarkMode
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    color: Theme.of(context).iconTheme.color,
                  ),
                ),
                value: themeService.isDarkMode,
                onChanged: (value) => themeService.toggleTheme(),
              ),
              _buildSettingsTile(
                title: 'Devise',
                subtitle: '${_currencySymbols[_currency]} ($_currency)',
                icon: Icons.currency_exchange,
                onTap: _showCurrencyPicker,
              ),
              _buildSettingsTile(
                title: 'Langue',
                subtitle: _language,
                icon: Icons.language,
                onTap: _showLanguagePicker,
                isLast: true,
              ),
            ],
          ),
          _buildSection(
            'SÉCURITÉ',
            [
              _buildSettingsTile(
                title: 'Changer le mot de passe',
                icon: Icons.lock_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SecurityScreen(
                        utilisateurId: widget.utilisateurId,
                      ),
                    ),
                  );
                },
                isLast: true,
              ),
            ],
          ),
          _buildSection(
            'À PROPOS',
            [
              _buildSettingsTile(
                title: 'À propos de CashFlow',
                icon: Icons.info_outline,
                onTap: _showAboutDialog,
              ),
              _buildSettingsTile(
                title: 'Politique de confidentialité',
                icon: Icons.privacy_tip_outlined,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Politique de confidentialité'),
                      content: SingleChildScrollView(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                              fontSize: 16,
                              height: 1.5,
                            ),
                            children: [
                              const TextSpan(
                                text: '''
Politique de Confidentialité

Dernière mise à jour : 21-01-2024

1. Introduction
Bienvenue dans CashFlow. Nous nous engageons à protéger votre vie privée et à garantir la sécurité de vos informations personnelles. Cette politique de confidentialité explique comment nous collectons, utilisons, partageons et protégeons vos données lorsque vous utilisez notre application.

En utilisant CashFlow, vous acceptez les pratiques décrites dans cette politique. Si vous n'êtes pas d'accord avec cette politique, veuillez ne pas utiliser notre application.

2. Données que nous collectons
Nous collectons les types de données suivants :

- Informations personnelles : Lorsque vous créez un compte, nous collectons votre nom, votre adresse e-mail et d'autres informations nécessaires pour vous identifier.
- Données financières : Nous collectons des informations sur vos économies, vos dépenses, vos objectifs financiers et vos transactions pour vous aider à gérer vos finances.
- Données d'utilisation : Nous collectons des informations sur la manière dont vous utilisez l'application, telles que les fonctionnalités que vous utilisez et les pages que vous consultez.
- Données techniques : Nous collectons des informations sur votre appareil, telles que le modèle, le système d'exploitation et l'adresse IP.

3. Utilisation des données
Nous utilisons vos données pour les finalités suivantes :

- Fournir et améliorer nos services : Nous utilisons vos données pour vous permettre d'enregistrer et de suivre vos économies, de définir des objectifs financiers et de suivre vos progrès.
- Personnaliser votre expérience : Nous utilisons vos données pour personnaliser les fonctionnalités et les recommandations en fonction de vos besoins.
- Communication : Nous utilisons votre adresse e-mail pour vous envoyer des notifications, des mises à jour et des informations importantes concernant votre compte.
- Sécurité : Nous utilisons vos données pour protéger votre compte et prévenir les activités frauduleuses.

4. Partage des données
Nous ne partageons vos données personnelles qu'avec votre consentement ou dans les cas suivants :

- Fournisseurs de services : Nous pouvons partager vos données avec des tiers qui nous aident à fournir nos services, tels que des hébergeurs de données ou des services d'analyse.
- Obligations légales : Nous pouvons divulguer vos données si la loi l'exige ou pour protéger nos droits, notre propriété ou notre sécurité.

5. Protection des données
Nous mettons en place des mesures de sécurité techniques et organisationnelles pour protéger vos données contre tout accès non autorisé, toute modification, toute divulgation ou toute destruction.

6. Vos droits
Vous avez les droits suivants concernant vos données :

- Accès : Vous pouvez demander une copie des données que nous détenons à votre sujet.
- Rectification : Vous pouvez demander à corriger ou à mettre à jour vos données.
- Suppression : Vous pouvez demander la suppression de vos données, sous réserve des obligations légales.
- Opposition : Vous pouvez vous opposer à l'utilisation de vos données à des fins de marketing.

Pour exercer ces droits, veuillez nous contacter à l'adresse suivante : ''',
                              ),
                              TextSpan(
                                text: 'wilfried.noubissie@facsciences-uy1.cm',
                                style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic),
                              ),
                              const TextSpan(
                                text: '''

7. Conservation des données
Nous conservons vos données aussi longtemps que nécessaire pour fournir nos services et respecter nos obligations légales. Si vous supprimez votre compte, vos données seront supprimées conformément à notre politique de conservation.

8. Modifications de la politique
Nous pouvons mettre à jour cette politique de confidentialité de temps à autre. Nous vous informerons de toute modification importante en publiant la nouvelle politique sur notre application ou en vous envoyant une notification.

9. Contact
Si vous avez des questions concernant cette politique de confidentialité, veuillez nous contacter à l'adresse suivante : ''',
                              ),
                              TextSpan(
                                text: 'wilfried.noubissie@facsciences-uy1.cm',
                                style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic),
                              ),
                              const TextSpan(
                                text: '.',
                              ),
                            ],
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Fermer'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              _buildSettingsTile(
                title: 'Conditions d\'utilisation',
                icon: Icons.description_outlined,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Conditions d\'utilisation'),
                      content: SingleChildScrollView(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                              fontSize: 16,
                              height: 1.5,
                            ),
                            children: [
                              const TextSpan(
                                text: '''
Conditions d'Utilisation

Dernière mise à jour : 21-01-2024

1. Acceptation des conditions
En utilisant CashFlow, vous acceptez les présentes conditions d'utilisation. Si vous n'êtes pas d'accord avec ces conditions, veuillez ne pas utiliser notre application.

2. Utilisation de l'application
Vous acceptez d'utiliser CashFlow uniquement à des fins légales et conformément à ces conditions. Vous ne devez pas :
- Utiliser l'application de manière à nuire à autrui.
- Tenter d'accéder à des parties non autorisées de l'application.
- Utiliser l'application pour des activités frauduleuses.

3. Compte utilisateur
Vous êtes responsable de la sécurité de votre compte et de vos informations de connexion. Vous devez nous informer immédiatement de toute utilisation non autorisée de votre compte.

4. Propriété intellectuelle
Tout le contenu de l'application, y compris les textes, les images et les logos, est la propriété de CashFlow ou de ses concédants de licence. Vous ne pouvez pas utiliser ce contenu sans notre autorisation écrite.

5. Limitation de responsabilité
CashFlow ne sera pas responsable des dommages indirects, accessoires ou consécutifs résultant de l'utilisation de l'application.

6. Modifications des conditions
Nous pouvons modifier ces conditions à tout moment. Nous vous informerons des changements importants en publiant les nouvelles conditions sur l'application.

7. Contact
Pour toute question concernant ces conditions, veuillez nous contacter à l'adresse suivante : ''',
                              ),
                              TextSpan(
                                text: '\nwilfried.noubissie@facsciences-uy1.cm',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const TextSpan(
                                text: ' ou via WhatsApp au \n',
                              ),
                              TextSpan(
                                text: '+237 690232120',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const TextSpan(
                                text: '.',
                              ),
                            ],
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Fermer'),
                        ),
                      ],
                    ),
                  );
                },
                isLast: true,
              ),
            ],
          ),
          _buildSection(
            'COMPTE',
            [
              ListTile(
                title: const Text(
                  'Se déconnecter',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFFEBEE),
                  child: Icon(Icons.logout, color: Colors.red, size: 20),
                ),
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

  Widget _buildSettingsTile({
    required String title,
    String? subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: !isLast
            ? Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                ),
              )
            : null,
      ),
      child: ListTile(
        title: Text(title),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              )
            : null,
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(
            icon,
            color: Theme.of(context).iconTheme.color,
            size: 20,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Theme.of(context).iconTheme.color,
        ),
        onTap: onTap,
      ),
    );
  }
}
