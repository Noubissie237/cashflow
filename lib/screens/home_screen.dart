import 'package:cashflow/screens/home_widgets/build_item_info.dart';
import 'package:cashflow/screens/home_widgets/build_progress_info_simple.dart';
import 'package:cashflow/screens/home_widgets/no_objectives_card.dart';
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
    final themeService = Provider.of<ThemeService>(context);
    final isDark = themeService.isDarkMode;

    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    Colors.grey[900]!,
                    Colors.grey[850]!,
                    Colors.grey[800]!,
                  ]
                : [
                    Colors.white,
                    Colors.grey[50]!,
                    Colors.grey[100]!,
                  ],
          ),
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [Colors.blue[700]!, Colors.blue[900]!]
                  : [Colors.blue[300]!, Colors.blue[500]!],
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.dashboard_rounded,
            color: isDark ? Colors.white : Colors.white,
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Dashboard',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.blue[700]!.withOpacity(0.2)
                      : Colors.blue[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '2025',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.blue[300] : Colors.blue[700],
                  ),
                ),
              ),
            ],
          ),
          Text(
            'Gérez vos finances intelligemment',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 11,
                ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [Colors.grey[800]!, Colors.grey[900]!]
                    : [Colors.grey[200]!, Colors.grey[300]!],
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return RotationTransition(
                    turns:
                        Tween<double>(begin: 0.5, end: 1.0).animate(animation),
                    child: ScaleTransition(
                      scale: animation,
                      child: child,
                    ),
                  );
                },
                child: Icon(
                  isDark ? Icons.light_mode : Icons.dark_mode,
                  key: ValueKey<bool>(isDark),
                  color: isDark ? Colors.orange[300] : Colors.blueGrey[600],
                ),
              ),
              onPressed: themeService.toggleTheme,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [Colors.grey[800]!, Colors.grey[900]!]
                    : [Colors.grey[200]!, Colors.grey[300]!],
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                Icons.help,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
              ),
              onPressed: () => lienExterneWithMessage(
                "https://wa.me/+237690232120",
                message:
                    "Salut Wilfried 👋, j'ai une question ou une suggestion d'amélioration à proposer concernant l'application *CashFlow* 💰",
              ),
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: isDark
                  ? [
                      Colors.blue[700]!.withOpacity(0.1),
                      Colors.blue[700]!.withOpacity(0.3),
                      Colors.blue[700]!.withOpacity(0.1),
                    ]
                  : [
                      Colors.blue[200]!.withOpacity(0.1),
                      Colors.blue[200]!.withOpacity(0.3),
                      Colors.blue[200]!.withOpacity(0.1),
                    ],
            ),
          ),
          height: 1.0,
        ),
      ),
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
          return ErrorView(
            message: 'Erreur de chargement des données : ${snapshot.error}',
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
              NoObjectivesCard(
                  caisseList: caisseList, utilisateurId: utilisateurId)
            else
              ObjectivesOverview(
                objectifList: objectifList,
                caisseList: caisseList,
                utilisateurId: utilisateurId,
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
  final int utilisateurId;

  const ObjectivesOverview({
    super.key,
    required this.utilisateurId,
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
          objectifList: objectifList,
          isFirst: index == 0,
          utilisateurId: utilisateurId,
        );
      },
    );
  }
}

class ObjectiveCard extends StatelessWidget {
  final Objectif objectif;
  final List<Caisse> caisseList;
  final List<Objectif> objectifList;
  final bool isFirst;
  final int utilisateurId;

  const ObjectiveCard({
    super.key,
    required this.utilisateurId,
    required this.objectif,
    required this.caisseList,
    required this.objectifList,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    final totalEconomise = calculateTotal(caisseList);
    final daysLeft = objectif.dateLimite.isAfter(DateTime.now())
        ? objectif.dateLimite.difference(DateTime.now()).inDays
        : 0; // Si la date est dépassée, afficher 0 jours restants
    final progress = (totalEconomise / objectif.montantCible).clamp(0.0, 1.0);

    // Sélectionner l'objectif à afficher dans le header
    final objectiveToDisplay =
        _getClosestOrPrincipalObjective(objectifList, totalEconomise);

    return Column(
      children: [
        // Première carte : Header, SavingsChart, ProgressInfoSimple, LinearProgressIndicator
        if (isFirst)
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (objectiveToDisplay != null) ...[
                    _buildHeader(context,
                        objectiveToDisplay), // Afficher l'objectif sélectionné
                    const SizedBox(height: 16),
                    SavingsChart(
                      totalEconomise: totalEconomise,
                      montantCible: objectiveToDisplay.montantCible,
                    ),
                    const SizedBox(height: 16),
                    buildProgressInfoSimple(context, totalEconomise, daysLeft),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor),
                    ),
                    const SizedBox(height: 8),
                  ] else
                    const Center(
                      child: Text(
                        'Tous les objectifs sont atteints !',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  NoObjectivesCard(
                      caisseList: caisseList, utilisateurId: utilisateurId),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

        // Deuxième carte : ProgressInfoWithDescription
        if (!isFirst)
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildProgressInfoWithDescription(
                    context,
                    objectif.montantCible, // Utiliser montantCible
                    daysLeft,
                    objectif.description ?? '',
                  ),
                  const SizedBox(height: 8), // Espace réduit
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget buildProgressInfoWithDescription(
    BuildContext context,
    double montantCible, // Utiliser montantCible au lieu de totalEconomise
    int daysLeft,
    String description,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildInfoItem(
              context,
              'Montant cible',
              '$montantCible FCFA', // Afficher le montant cible
              Icons.flag_outlined, // Icône pour le montant cible
            ),
            buildInfoItem(
              context,
              'Jours restants',
              '$daysLeft jours',
              Icons.timer_outlined,
            ),
          ],
        ),
        if (description.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
      ],
    );
  }

  Objectif? _getClosestOrPrincipalObjective(
      List<Objectif> objectifList, double totalEconomise) {
    // Étape 1 : Filtrer les objectifs dont le montantCible est supérieur à totalEconomise
    final filteredObjectives = objectifList
        .where((objectif) => objectif.montantCible > totalEconomise)
        .toList();

    // Si aucun objectif ne reste après le filtrage, retourner null
    if (filteredObjectives.isEmpty) {
      return null;
    }

    // Étape 2 : Filtrer les objectifs principaux parmi les objectifs restants
    final principalObjectifs =
        filteredObjectives.where((objectif) => objectif.estPrincipal).toList();

    // Si des objectifs principaux existent, prendre celui avec la dateLimite la plus proche
    if (principalObjectifs.isNotEmpty) {
      principalObjectifs.sort((a, b) => a.dateLimite.compareTo(b.dateLimite));
      return principalObjectifs.first;
    }

    // Sinon, prendre l'objectif avec la dateLimite la plus proche parmi tous les objectifs restants
    final allObjectifs = List<Objectif>.from(filteredObjectives);
    allObjectifs.sort((a, b) => a.dateLimite.compareTo(b.dateLimite));
    return allObjectifs.isNotEmpty ? allObjectifs.first : null;
  }

  Widget _buildHeader(BuildContext context, Objectif objectif) {
    final formatter = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: 'FCFA',
      decimalDigits: 0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'Objectif : ${formatter.format(objectif.montantCible)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                overflow: TextOverflow
                    .ellipsis, // Ajouter un ellipsis si le texte est trop long
              ),
            ),
          ],
        ),
        if (objectif.description != null && objectif.description!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              objectif.description!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
      ],
    );
  }

  // Widget _buildRecommendation(
  //   BuildContext context,
  //   double totalEconomise,
  //   int daysLeft,
  // ) {
  //   final montantRestant = objectif.montantCible - totalEconomise;
  //   final montantParJour = daysLeft > 0 ? montantRestant / daysLeft : 0;

  //   String message;
  //   IconData icon;
  //   Color? color;

  //   if (montantRestant <= 0) {
  //     message = 'Félicitations ! Objectif atteint !';
  //     icon = Icons.celebration;
  //     color = Theme.of(context).colorScheme.secondary;
  //   } else if (daysLeft <= 0) {
  //     message = 'Date limite dépassée. Redéfinissez un nouvel objectif.';
  //     icon = Icons.warning;
  //     color = Theme.of(context).colorScheme.error;
  //   } else {
  //     message =
  //         'Épargnez ${montantParJour.toStringAsFixed(0)} FCFA/jour pour atteindre votre objectif.';
  //     icon = Icons.tips_and_updates;
  //     color = Theme.of(context).colorScheme.primary;
  //   }

  //   return Card(
  //     color: color.withOpacity(0.1),
  //     child: Padding(
  //       padding: const EdgeInsets.all(16),
  //       child: Row(
  //         children: [
  //           Icon(icon, color: color),
  //           const SizedBox(width: 16),
  //           Expanded(
  //             child: Text(
  //               message,
  //               style: TextStyle(
  //                 color: color,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
