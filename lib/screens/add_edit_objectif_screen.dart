import 'package:flutter/material.dart';
import '../models/objectif.dart';
import '../services/database.dart';

class AddEditObjectifScreen extends StatefulWidget {
  final Objectif? objectif;
  final int utilisateurId;

  const AddEditObjectifScreen({
    super.key,
    this.objectif,
    required this.utilisateurId,
  });

  @override
  State<AddEditObjectifScreen> createState() => _AddEditObjectifScreenState();
}

class _AddEditObjectifScreenState extends State<AddEditObjectifScreen> {
  final _formKey = GlobalKey<FormState>();
  final _montantCibleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late DateTime _selectedDate;
  final _dbService = DatabaseService();
  bool _isLoading = false;
  bool _estPrincipal = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _selectedDate = widget.objectif?.dateLimite ?? DateTime.now();
    if (widget.objectif != null) {
      _montantCibleController.text = widget.objectif!.montantCible.toString();
      _descriptionController.text = widget.objectif!.description!;
      _estPrincipal = widget.objectif!.estPrincipal;
    }
  }

  @override
  void dispose() {
    _montantCibleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Theme.of(context).cardColor,
              onSurface:
                  Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveObjectif() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final objectif = Objectif(
        id: widget.objectif?.id,
        description: _descriptionController.text.trim(),
        montantCible: double.parse(_montantCibleController.text),
        dateLimite: _selectedDate,
        montantEconomise: widget.objectif?.montantEconomise ?? 0,
        utilisateurId: widget.utilisateurId,
        estPrincipal: _estPrincipal,
      );

      await (widget.objectif == null
          ? _dbService.insertObjectif(objectif)
          : _dbService.updateObjectif(objectif));

      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showErrorSnackBar(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.objectif == null
              ? 'Ajouter un objectif'
              : 'Modifier un objectif',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildDescriptionField(),
                const SizedBox(height: 20),
                _buildMontantCibleField(),
                const SizedBox(height: 20),
                _buildDatePicker(),
                const SizedBox(height: 20),
                _buildPrincipalSwitch(),
                const SizedBox(height: 32),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLength: 30,
      decoration: InputDecoration(
        labelText: 'Description',
        prefixIcon: const Icon(Icons.description),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
      ),
      textInputAction: TextInputAction.next,
      validator: _validateDescription,
    );
  }

  Widget _buildMontantCibleField() {
    return TextFormField(
      controller: _montantCibleController,
      decoration: InputDecoration(
        labelText: 'Montant cible',
        prefixIcon: const Icon(Icons.euro),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.done,
      validator: _validateMontant,
    );
  }

  Widget _buildDatePicker() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date limite',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${_selectedDate.toLocal()}'.split(' ')[0],
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: () => _selectDate(context),
              icon: const Icon(Icons.edit_calendar),
              label: const Text('Modifier'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrincipalSwitch() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        title: const Text('Objectif principal'),
        subtitle: Text(
          'Cet objectif sera mis en avant dans le tableau de bord',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        value: _estPrincipal,
        onChanged: (value) => setState(() => _estPrincipal = value),
        secondary: Icon(
          Icons.star,
          color: _estPrincipal
              ? Theme.of(context).primaryColor
              : Theme.of(context).disabledColor,
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _saveObjectif,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: _isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              'Enregistrer',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  String? _validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer une description';
    }
    if (value.length < 3) {
      return 'Minimum 3 caractères requis';
    }
    return null;
  }

  String? _validateMontant(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer un montant cible';
    }
    final montant = double.tryParse(value);
    if (montant == null) {
      return 'Veuillez entrer un montant valide';
    }
    if (montant < 0) {
      return 'Le montant ne peut pas être négatif';
    }
    return null;
  }
}
