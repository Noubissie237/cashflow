import 'package:cashflow/widgets/empty_state.dart';
import 'package:cashflow/widgets/savings_summary.dart';
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
      _showErrorDialog('Erreur lors du chargement des données : $e');
    }
  }

  Future<void> _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 7)),
        end: DateTime.now(),
      ),
    );

    if (picked != null) {
      _filterCaisseListByDateRange(picked.start, picked.end);
    }
  }

  void _filterCaisseListByDateRange(DateTime startDate, DateTime endDate) {
    setState(() {
      _caisseList = _caisseList.where((caisse) {
        return caisse.date
                .isAfter(startDate.subtract(const Duration(days: 1))) &&
            caisse.date.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();
    });
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
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Historique des économies',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              '${_caisseList.length} opérations',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          child: const Hero(
            tag: 'savings_icon',
            child: CircleAvatar(
              backgroundColor: Colors.white24,
              child: Icon(
                Icons.savings,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.filter_list,
              color: Colors.white,
            ),
            onPressed: () {
              _showDateRangePicker();
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: () {
              _loadData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Données actualisées'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(milliseconds: 1500),
                ),
              );
            },
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
      return EmptyStateWidget(
        title: 'Aucune entrée enregistrée',
        message:
            'Commencez à enregistrer vos économies pour suivre votre progression financière',
        icon: Icons.savings_outlined,
        buttonText: 'Ajouter une entrée',
        iconColor: Theme.of(context).colorScheme.primary,
        buttonColor: Theme.of(context).colorScheme.primary,
        onActionPressed: () => _navigateToEditCaisseScreen(null),
      );
    }

    double totalMontant = _caisseList.fold(
      0,
      (sum, item) => sum + item.montant,
    );

    return Column(
      children: [
        SavingsSummaryWidget(
          totalAmount: totalMontant,
          formatter: _formatMonnaie,
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
          _showErrorDialog('Erreur lors de la suppression : $e');
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
            caisse.description!.isNotEmpty
                ? caisse.description!
                : "Aucune description",
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
