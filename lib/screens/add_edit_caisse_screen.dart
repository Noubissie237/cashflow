import 'package:flutter/material.dart';
import '../models/caisse.dart';
import '../services/database.dart';

class AddEditCaisseScreen extends StatefulWidget {
  final Caisse? caisse;
  final int utilisateurId;

  const AddEditCaisseScreen({
    super.key,
    this.caisse,
    required this.utilisateurId,
  });

  @override
  State<AddEditCaisseScreen> createState() => _AddEditCaisseScreenState();
}

class _AddEditCaisseScreenState extends State<AddEditCaisseScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descriptionController;
  late final TextEditingController _montantController;
  late DateTime _selectedDate;
  final _dbService = DatabaseService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _descriptionController =
        TextEditingController(text: widget.caisse?.description ?? '');
    _montantController =
        TextEditingController(text: widget.caisse?.montant.toString() ?? '');
    _selectedDate = widget.caisse?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _montantController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
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

  Future<void> _saveCaisse() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final caisse = Caisse(
        id: widget.caisse?.id,
        description: _descriptionController.text.trim(),
        montant: double.parse(_montantController.text),
        date: _selectedDate,
        utilisateurId: widget.utilisateurId,
      );

      widget.caisse == null
          ? await _dbService.insertCaisse(caisse)
          : await _dbService.updateCaisse(caisse);

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
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        widget.caisse == null ? 'Ajouter une entrée' : 'Modifier une entrée',
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      elevation: 0,
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildMontantField(),
              const SizedBox(height: 20),
              _buildDescriptionField(),
              const SizedBox(height: 20),
              _buildDateSelector(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMontantField() {
    return TextFormField(
      controller: _montantController,
      decoration: InputDecoration(
        labelText: 'Montant',
        prefixIcon: const Icon(Icons.euro),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: _validateMontant,
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: 'Description (optionnel)',
        prefixIcon: const Icon(Icons.description),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
      ),
      validator: _validateDescription,
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
          const SizedBox(width: 16),
          Text(
            'Date : ',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            '${_selectedDate.toLocal()}'.split(' ')[0],
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () => _selectDate(context),
            icon: const Icon(Icons.edit_calendar),
            label: const Text('Modifier'),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _saveCaisse,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }

  String? _validateMontant(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer un montant';
    }
    final montant = double.tryParse(value);
    if (montant == null) {
      return 'Veuillez entrer un nombre valide';
    }
    if (montant < 0) {
      return 'Le montant ne peut pas être négatif';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    if (value != null && value.isNotEmpty && value.length < 3) {
      return 'Minimum 3 caractères requis';
    }
    return null;
  }
}
