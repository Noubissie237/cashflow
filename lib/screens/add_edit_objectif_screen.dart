import 'package:flutter/material.dart';
import '../models/objectif.dart';
import '../services/database.dart';

class AddEditObjectifScreen extends StatefulWidget {
  final Objectif? objectif;
  final int utilisateurId;

  const AddEditObjectifScreen({super.key, this.objectif, required this.utilisateurId});

  @override
  State<AddEditObjectifScreen> createState() => _AddEditObjectifScreenState();
}

class _AddEditObjectifScreenState extends State<AddEditObjectifScreen> {
  final _formKey = GlobalKey<FormState>();
  final _montantCibleController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final _dbService = DatabaseService();

  @override
  void initState() {
    super.initState();
    if (widget.objectif != null) {
      _montantCibleController.text = widget.objectif!.montantCible.toString();
      _selectedDate = widget.objectif!.dateLimite;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveObjectif() async {
    if (_formKey.currentState!.validate()) {
      final objectif = Objectif(
        id: widget.objectif?.id,
        montantCible: double.parse(_montantCibleController.text),
        dateLimite: _selectedDate,
        montantEconomise: widget.objectif?.montantEconomise ?? 0,
        utilisateurId: widget.utilisateurId,
      );

      if (widget.objectif == null) {
        await _dbService.insertObjectif(objectif);
      } else {
        await _dbService.updateObjectif(objectif);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.objectif == null
            ? 'Ajouter un objectif'
            : 'Modifier un objectif'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _montantCibleController,
                decoration: InputDecoration(labelText: 'Montant cible'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un montant cible';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Veuillez entrer un montant valide';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text('Date limite: ${_selectedDate.toLocal()}'.split(' ')[0]),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: Text('Choisir une date'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveObjectif,
                child: Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
