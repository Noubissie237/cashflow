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
        const SnackBar(
            content: Text('Erreur lors du chargement des objectifs')),
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

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 16),
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
                                Text(
                                  _formatMontant(objectif.montantCible),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
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
                                        color: daysLeft > 30
                                            ? Colors.green[100]
                                            : daysLeft > 7
                                                ? Colors.orange[100]
                                                : Colors.red[100],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        daysLeft > 0
                                            ? 'J-$daysLeft'
                                            : daysLeft == 0
                                                ? "Aujourd'hui"
                                                : 'Terminé',
                                        style: TextStyle(
                                          color: daysLeft > 30
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
