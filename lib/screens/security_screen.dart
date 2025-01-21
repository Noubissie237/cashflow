import 'package:flutter/material.dart';
import 'package:cashflow/services/database.dart';
import 'package:cashflow/widgets/theme.dart';

class SecurityScreen extends StatefulWidget {
  final int utilisateurId;
  const SecurityScreen({super.key, required this.utilisateurId});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<Map<String, String>> _getUserById(int utilisateurId) async {
    final dbService = DatabaseService();
    final utilisateur = await dbService.getUserById(utilisateurId);
    if (utilisateur != null) {
      return {
        'id': utilisateur.id.toString(),
        'motDePasse': utilisateur.motDePasse,
      };
    }
    throw Exception('Utilisateur non trouvé');
  }

  Future<void> _updatePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final user = await _getUserById(widget.utilisateurId);

        if (_oldPasswordController.text != user['motDePasse']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Ancien mot de passe incorrect'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
          return;
        }

        final dbService = DatabaseService();
        await dbService.updatePassword(
          widget.utilisateurId,
          _newPasswordController.text,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Mot de passe mis à jour avec succès'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );

        _oldPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Sécurité',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Changement de mot de passe',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mettez à jour votre mot de passe pour sécuriser votre compte',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildPasswordField(
                        controller: _oldPasswordController,
                        label: 'Ancien mot de passe',
                        obscureText: _obscureOldPassword,
                        onToggleVisibility: () {
                          setState(
                              () => _obscureOldPassword = !_obscureOldPassword);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Entrez votre ancien mot de passe';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildPasswordField(
                        controller: _newPasswordController,
                        label: 'Nouveau mot de passe',
                        obscureText: _obscureNewPassword,
                        onToggleVisibility: () {
                          setState(
                              () => _obscureNewPassword = !_obscureNewPassword);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Entrez un nouveau mot de passe';
                          }
                          if (value.length < 5) {
                            return 'Minimum 5 requis !';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildPasswordField(
                        controller: _confirmPasswordController,
                        label: 'Confirmez le mot de passe',
                        obscureText: _obscureConfirmPassword,
                        onToggleVisibility: () {
                          setState(() => _obscureConfirmPassword =
                              !_obscureConfirmPassword);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Confirmez le nouveau mot de passe';
                          }
                          if (value != _newPasswordController.text) {
                            return 'Les mots de passes ne correspondent pas';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _updatePassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: appColors.savingsColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Changez le mot de passe',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required String? Function(String?) validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: TextInputType.number,
        maxLength: 5,
        style: TextStyle(
          fontSize: 16,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: 14,
          ),
          floatingLabelStyle: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(context).cardColor,
          counterText: "",
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            onPressed: onToggleVisibility,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        validator: validator,
      ),
    );
  }
}
