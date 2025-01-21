import 'package:flutter/material.dart';
import '../services/database.dart';
import '../models/objectif.dart';
import 'add_edit_objectif_screen.dart';
import 'package:intl/intl.dart';

class GoalsScreen extends StatefulWidget {
  final int utilisateurId;

  const GoalsScreen({super.key, required this.utilisateurId});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final DatabaseService _dbService = DatabaseService();
  List<Objectif> _objectifList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final objectifList =
          await _dbService.getObjectifsByUtilisateur(widget.utilisateurId);
      setState(() {
        _objectifList = objectifList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement des objectifs : $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteObjectif(Objectif objectif) async {
    try {
      await _dbService.deleteObjectif(objectif.id!);
      setState(() {
        _objectifList.removeWhere((item) => item.id == objectif.id);
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Objectif supprimé'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la suppression : $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatMontant(double montant) {
    final formatter = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: 'FCFA',
      decimalDigits: 0,
    );
    return formatter.format(montant);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          'Mes Objectifs',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _objectifList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.flag_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun objectif défini',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddEditObjectifScreen(
                              utilisateurId: widget.utilisateurId,
                            ),
                          ),
                        ).then((_) => _loadData()),
                        child: const Text('Créer un objectif'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _objectifList.length,
                    itemBuilder: (context, index) {
                      final objectif = _objectifList[index];
                      final daysLeft =
                          objectif.dateLimite.difference(DateTime.now()).inDays;
                      final isCompleted = daysLeft < 0;

                      return Dismissible(
                        key: Key(objectif.id.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirmation'),
                              content: const Text(
                                  'Voulez-vous vraiment supprimer cet objectif ?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Annuler'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Supprimer'),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (direction) async {
                          await _deleteObjectif(objectif);
                        },
                        child: Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 16),
                          color: isCompleted ? Colors.grey[200] : null,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddEditObjectifScreen(
                                    objectif: objectif,
                                    utilisateurId: widget.utilisateurId,
                                  ),
                                ),
                              ).then((_) => _loadData());
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      if (objectif.estPrincipal)
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 20,
                                        ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _formatMontant(objectif.montantCible),
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: isCompleted
                                              ? Colors.grey[600]
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (objectif.description != null &&
                                      objectif.description!.isNotEmpty)
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
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Échéance : ${DateFormat('dd/MM/yyyy').format(objectif.dateLimite)}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isCompleted
                                              ? Colors.grey[300]
                                              : daysLeft > 30
                                                  ? Colors.green[100]
                                                  : daysLeft > 7
                                                      ? Colors.orange[100]
                                                      : Colors.red[100],
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          isCompleted
                                              ? 'Terminé'
                                              : daysLeft == 0
                                                  ? "Aujourd'hui"
                                                  : 'J-$daysLeft',
                                          style: TextStyle(
                                            color: isCompleted
                                                ? Colors.grey[700]
                                                : daysLeft > 30
                                                    ? Colors.green[900]
                                                    : daysLeft > 7
                                                        ? Colors.orange[900]
                                                        : Colors.red[900],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditObjectifScreen(
                utilisateurId: widget.utilisateurId,
              ),
            ),
          ).then((_) => _loadData());
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouvel objectif'),
      ),
    );
  }
}
