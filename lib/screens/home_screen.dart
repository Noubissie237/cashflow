import 'package:cashflow/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/theme_service.dart';
import '../services/database.dart';
import '../models/caisse.dart';
import '../models/objectif.dart';
import '../models/utilisateur.dart';
import '../widgets/savings_chart.dart';
import '../widgets/error_view.dart';
import 'add_edit_caisse_screen.dart';


class HomeScreen extends StatelessWidget {
  final int utilisateurId;

  const HomeScreen({super.key, required this.utilisateurId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _HomeContent(utilisateurId: utilisateurId),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddCaisse(context),
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle épargne'),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Text(
        'Dashboard',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.titleLarge?.color,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Provider.of<ThemeService>(context).isDarkMode
                ? Icons.light_mode
                : Icons.dark_mode,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () {
            Provider.of<ThemeService>(context, listen: false).toggleTheme();
          },
        ),
      ],
    );
  }

  void _navigateToAddCaisse(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditCaisseScreen(utilisateurId: utilisateurId),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final int utilisateurId;

  const _HomeContent({required this.utilisateurId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const ErrorView(
            message: 'Erreur de chargement des données',
            icon: Icons.error_outline,
          );
        }

        final data = snapshot.data!;
        return _HomeDataView(
          utilisateurId: utilisateurId,
          caisseList: data['caisseList'] as List<Caisse>,
          objectifList: data['objectifList'] as List<Objectif>,
          utilisateur: data['utilisateur'] as Utilisateur?,
        );
      },
    );
  }

  Future<Map<String, dynamic>> _loadData() async {
    final DatabaseService dbService = DatabaseService();
    final futures = await Future.wait([
      dbService.getCaisseByUtilisateur(utilisateurId),
      dbService.getObjectifsByUtilisateur(utilisateurId),
      dbService.getUserById(utilisateurId),
    ]);

    return {
      'caisseList': futures[0] as List<Caisse>,
      'objectifList': futures[1] as List<Objectif>,
      'utilisateur': futures[2] as Utilisateur?,
    };
  }
}

class _HomeDataView extends StatelessWidget {
  final int utilisateurId;
  final List<Caisse> caisseList;
  final List<Objectif> objectifList;
  final Utilisateur? utilisateur;

  const _HomeDataView({
    required this.utilisateurId,
    required this.caisseList,
    required this.objectifList,
    required this.utilisateur,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => Future.delayed(const Duration(seconds: 1)),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WelcomeCard(prenom: getLastName(utilisateur?.nom)),
            if (objectifList.isEmpty)
              const NoObjectivesCard()
            else
              ObjectivesOverview(
                objectifList: objectifList,
                caisseList: caisseList,
              ),
          ],
        ),
      ),
    );
  }
}

class WelcomeCard extends StatelessWidget {
  final String? prenom;

  const WelcomeCard({super.key, this.prenom});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bonjour${prenom != null ? ', $prenom' : ''}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bienvenue sur votre espace personnel',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }
}

class ObjectivesOverview extends StatelessWidget {
  final List<Objectif> objectifList;
  final List<Caisse> caisseList;

  const ObjectivesOverview({
    super.key,
    required this.objectifList,
    required this.caisseList,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: objectifList.length,
      itemBuilder: (context, index) {
        final objectif = objectifList[index];
        return ObjectiveCard(
          objectif: objectif,
          caisseList: caisseList,
          isFirst: index == 0,
        );
      },
    );
  }
}

class ObjectiveCard extends StatelessWidget {
  final Objectif objectif;
  final List<Caisse> caisseList;
  final bool isFirst;

  const ObjectiveCard({
    super.key,
    required this.objectif,
    required this.caisseList,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    final totalEconomise = _calculateTotal(caisseList);
    final daysLeft = objectif.dateLimite.difference(DateTime.now()).inDays;
    //final progress = (totalEconomise / objectif.montantCible).clamp(0.0, 1.0);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isFirst) ...[
              _buildHeader(context),
              const SizedBox(height: 16),
              SavingsChart(
                totalEconomise: totalEconomise,
                montantCible: objectif.montantCible,
              ),
              const SizedBox(height: 16),
            ],
            _buildProgressInfo(context, totalEconomise, daysLeft),
            const SizedBox(height: 16),
            if (isFirst)
              _buildRecommendation(context, totalEconomise, daysLeft),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: 'FCFA',
      decimalDigits: 0,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Objectif : ${formatter.format(objectif.montantCible)}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Principal',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressInfo(
    BuildContext context,
    double totalEconomise,
    int daysLeft,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildInfoItem(
          context,
          'Épargné',
          '$totalEconomise FCFA',
          Icons.savings_outlined,
        ),
        _buildInfoItem(
          context,
          'Jours restants',
          '$daysLeft jours',
          Icons.timer_outlined,
        ),
      ],
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildRecommendation(
    BuildContext context,
    double totalEconomise,
    int daysLeft,
  ) {
    final montantRestant = objectif.montantCible - totalEconomise;
    final montantParJour = daysLeft > 0 ? montantRestant / daysLeft : 0;

    String message;
    IconData icon;
    Color? color;

    if (montantRestant <= 0) {
      message = 'Félicitations ! Objectif atteint !';
      icon = Icons.celebration;
      color = Colors.green;
    } else if (daysLeft <= 0) {
      message = 'Date limite dépassée. Redéfinissez un nouvel objectif.';
      icon = Icons.warning;
      color = Colors.orange;
    } else {
      message =
          'Épargnez ${montantParJour.toStringAsFixed(0)} FCFA/jour pour atteindre votre objectif.';
      icon = Icons.tips_and_updates;
      color = Theme.of(context).primaryColor;
    }

    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateTotal(List<Caisse> caisseList) {
    return caisseList.fold(0, (sum, caisse) => sum + caisse.montant);
  }
}

class NoObjectivesCard extends StatelessWidget {
  const NoObjectivesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.flag_outlined,
              size: 48,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun objectif défini',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Définissez un objectif d\'épargne pour commencer à suivre votre progression',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigation vers la page des objectifs
              },
              child: const Text('Définir un objectif'),
            ),
          ],
        ),
      ),
    );
  }
}
