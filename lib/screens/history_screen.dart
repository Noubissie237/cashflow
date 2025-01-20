import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database.dart';
import '../models/caisse.dart';
import 'add_edit_caisse_screen.dart';

class HistoryScreen extends StatefulWidget {
  final int utilisateurId;

  const HistoryScreen({super.key, required this.utilisateurId});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DatabaseService _dbService = DatabaseService();
  List<Caisse> _caisseList = [];
  bool _isLoading = true;
  final NumberFormat _formatMonnaie = NumberFormat.currency(
    locale: 'fr_FR',
    symbol: 'FCFA',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final caisseList =
          await _dbService.getCaisseByUtilisateur(widget.utilisateurId);
      setState(() {
        _caisseList = caisseList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Erreur lors du chargement des données');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erreur'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des économies'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildHistoryList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEditCaisseScreen(null),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHistoryList() {
    if (_caisseList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Aucune entrée enregistrée',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ajoutez votre première entrée en cliquant sur le bouton +',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    double totalMontant = _caisseList.fold(
      0,
      (sum, item) => sum + item.montant,
    );

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total des économies:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _formatMonnaie.format(totalMontant),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _caisseList.length,
              itemBuilder: (context, index) {
                final caisse = _caisseList[index];
                return _buildHistoryItem(caisse);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(Caisse caisse) {
    return Dismissible(
      key: Key(caisse.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            content:
                const Text('Voulez-vous vraiment supprimer cette entrée ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
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
        try {
          await _dbService.deleteCaisse(caisse.id!);
          setState(() {
            _caisseList.removeWhere((item) => item.id == caisse.id);
          });
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Entrée supprimée'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } catch (e) {
          if (!mounted) return;
          _showErrorDialog('Erreur lors de la suppression');
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        elevation: 2,
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.savings,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          title: Text(
            caisse.description,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            DateFormat('dd/MM/yyyy').format(caisse.date),
            style: TextStyle(color: Colors.grey[600]),
          ),
          trailing: Text(
            _formatMonnaie.format(caisse.montant),
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          onTap: () => _navigateToEditCaisseScreen(caisse),
        ),
      ),
    );
  }

  void _navigateToEditCaisseScreen(Caisse? caisse) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditCaisseScreen(
          caisse: caisse,
          utilisateurId: widget.utilisateurId,
        ),
      ),
    ).then((_) => _loadData());
  }
}
