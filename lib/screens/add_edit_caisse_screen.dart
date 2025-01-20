import 'package:flutter/material.dart';
import '../models/caisse.dart';
import '../services/database.dart';

class AddEditCaisseScreen extends StatefulWidget {
  final Caisse? caisse;
  final int utilisateurId;

  const AddEditCaisseScreen(
      {super.key, this.caisse, required this.utilisateurId});

  @override
  State<AddEditCaisseScreen> createState() => _AddEditCaisseScreenState();
}

class _AddEditCaisseScreenState extends State<AddEditCaisseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _montantController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final _dbService = DatabaseService();

  @override
  void initState() {
    super.initState();
    if (widget.caisse != null) {
      _descriptionController.text = widget.caisse!.description;
      _montantController.text = widget.caisse!.montant.toString();
      _selectedDate = widget.caisse!.date;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveCaisse() async {
    if (_formKey.currentState!.validate()) {
      final caisse = Caisse(
        id: widget.caisse?.id,
        description: _descriptionController.text,
        montant: double.parse(_montantController.text),
        date: _selectedDate,
        utilisateurId: widget.utilisateurId,
      );

      if (widget.caisse == null) {
        await _dbService.insertCaisse(caisse);
      } else {
        await _dbService.updateCaisse(caisse);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.caisse == null
            ? 'Ajouter une entrée'
            : 'Modifier une entrée'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _montantController,
                decoration: InputDecoration(labelText: 'Montant'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un montant';
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
                  Text('Date: ${_selectedDate.toLocal()}'.split(' ')[0]),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: Text('Choisir une date'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveCaisse,
                child: Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
