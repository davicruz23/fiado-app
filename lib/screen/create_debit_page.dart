import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/database_helper.dart';

class CreateDebtPage extends StatefulWidget {
  final int? clientId;
  const CreateDebtPage({super.key, this.clientId});

  @override
  State<CreateDebtPage> createState() => _CreateDebtPageState();
}

class _CreateDebtPageState extends State<CreateDebtPage> {
  final _nameController = TextEditingController();
  final _valueController = TextEditingController();
  final _numberPhone = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final dbHelper = DatabaseHelper.instance;

  static const _coral = Color(0xFFD85A30);
  static const _coralLight = Color(0xFFFAECE7);

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final value = double.tryParse(_valueController.text.replaceAll(',', '.'));
    final phone = _numberPhone.text.trim();

    if (value == null) return;

    final db = await dbHelper.database;

    final existingClient = await db.query(
      'clients',
      where: 'name = ?',
      whereArgs: [name],
    );

    int clientId;
    if (existingClient.isEmpty) {
      clientId = await db.insert('clients', {
        'name': name,
        'phone': phone,
        'created_at': DateTime.now().toIso8601String(),
      });
    } else {
      clientId = existingClient.first['id'] as int;
    }

    await db.insert('debts', {
      'client_id': clientId,
      'amount': value,
      'description': null,
      'created_at': DateTime.now().toIso8601String(),
      'is_paid': 0,
    });

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              shape: BoxShape.circle,
              border: Border.all(color: scheme.outlineVariant, width: 0.5),
            ),
            child: const Icon(Icons.chevron_left_rounded, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Novo fiado',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            // Header card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _coralLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _coral.withOpacity(0.2), width: 0.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: _coral,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Novo cliente',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF993C1D),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Preencha os dados abaixo',
                        style: TextStyle(fontSize: 12, color: _coral),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _buildLabel('NOME DO CLIENTE'),
            const SizedBox(height: 6),
            _buildField(
              controller: _nameController,
              hint: 'Ex: João Silva',
              icon: Icons.person_outline_rounded,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Informe o nome' : null,
            ),

            const SizedBox(height: 16),

            _buildLabel('CELULAR'),
            const SizedBox(height: 6),
            _buildField(
              controller: _numberPhone,
              hint: '(00) 00000-0000',
              icon: Icons.smartphone_rounded,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Informe o celular' : null,
            ),

            const SizedBox(height: 16),

            _buildLabel('VALOR DO FIADO'),
            const SizedBox(height: 6),
            _buildField(
              controller: _valueController,
              hint: '0,00',
              prefix: 'R\$',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
              ],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Informe o valor';
                if (double.tryParse(v.replaceAll(',', '.')) == null) {
                  return 'Valor inválido';
                }
                return null;
              },
              highlighted: true,
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(child: Divider(color: scheme.outlineVariant)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'ou',
                    style: TextStyle(
                      fontSize: 11,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: scheme.outlineVariant)),
              ],
            ),

            const SizedBox(height: 14),

            OutlinedButton.icon(
              onPressed: () {
                // TODO: buscar cliente existente
              },
              icon: const Icon(Icons.search_rounded, size: 16),
              label: const Text('Buscar cliente existente'),
              style: OutlinedButton.styleFrom(
                foregroundColor: scheme.onSurfaceVariant,
                side: BorderSide(color: scheme.outlineVariant, width: 0.5),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 28),

            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text(
                'Salvar fiado',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: _coral,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
    text,
    style: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.4,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    ),
  );

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    String? prefix,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    bool highlighted = false,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: scheme.onSurfaceVariant.withOpacity(0.5)),
        prefixIcon: icon != null
            ? Icon(icon, size: 18, color: scheme.onSurfaceVariant)
            : null,
        prefixText: prefix,
        prefixStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: _coral,
        ),
        filled: true,
        fillColor: highlighted
            ? _coralLight.withOpacity(0.3)
            : scheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.outlineVariant, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: highlighted
              ? const BorderSide(color: _coral, width: 1.5)
              : BorderSide(color: scheme.outlineVariant, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _coral, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }
}
