import 'package:flutter/material.dart';

import '../data/database_helper.dart';

class ClientFormScreen extends StatefulWidget {
  const ClientFormScreen({super.key, this.client});

  final Map<String, Object?>? client;

  @override
  State<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends State<ClientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyController = TextEditingController();
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  bool get _isEdit => widget.client != null;

  @override
  void initState() {
    super.initState();
    final client = widget.client;
    if (client != null) {
      _nameController.text = (client['name'] ?? '').toString();
      _phoneController.text = (client['phone'] ?? '').toString();
      _companyController.text = (client['company'] ?? '').toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  Future<void> _saveClient() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final company = _companyController.text.trim();

    if (_isEdit) {
      await _databaseHelper.updateClient(
        id: widget.client!['id'] as int,
        name: name,
        phone: phone,
        company: company,
      );
    } else {
      await _databaseHelper.insertClient(
        name: name,
        phone: phone,
        company: company,
      );
    }

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Client' : 'Add Client'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration:
                            const InputDecoration(labelText: 'Client Name'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Client name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _companyController,
                        decoration: const InputDecoration(labelText: 'Company'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(labelText: 'Phone'),
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _saveClient,
                icon: const Icon(Icons.save_outlined),
                label: Text(_isEdit ? 'Update Client' : 'Save Client'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
