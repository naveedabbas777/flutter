import 'package:flutter/material.dart';

import '../data/database_helper.dart';

class CommitteeFormScreen extends StatefulWidget {
  const CommitteeFormScreen({
    super.key,
    required this.clientId,
    this.committee,
  });

  final int clientId;
  final Map<String, Object?>? committee;

  @override
  State<CommitteeFormScreen> createState() => _CommitteeFormScreenState();
}

class _CommitteeFormScreenState extends State<CommitteeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  String _status = 'Active';

  bool get _isEdit => widget.committee != null;

  @override
  void initState() {
    super.initState();
    final committee = widget.committee;
    if (committee != null) {
      _nameController.text = (committee['name'] ?? '').toString();
      _descriptionController.text = (committee['description'] ?? '').toString();
      _startDateController.text = (committee['start_date'] ?? '').toString();
      _endDateController.text = (committee['end_date'] ?? '').toString();
      final status = (committee['status'] ?? '').toString();
      if (status.isNotEmpty) {
        _status = status;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
    );

    if (pickedDate == null) {
      return;
    }

    controller.text =
        '${pickedDate.year.toString().padLeft(4, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
  }

  Future<void> _saveCommittee() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final startDate = _startDateController.text.trim();
    final endDate = _endDateController.text.trim();

    if (_isEdit) {
      await _databaseHelper.updateCommittee(
        id: widget.committee!['id'] as int,
        name: name,
        description: description,
        status: _status,
        startDate: startDate.isEmpty ? null : startDate,
        endDate: endDate.isEmpty ? null : endDate,
      );
    } else {
      await _databaseHelper.insertCommittee(
        clientId: widget.clientId,
        name: name,
        description: description,
        status: _status,
        startDate: startDate.isEmpty ? null : startDate,
        endDate: endDate.isEmpty ? null : endDate,
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
        title: Text(_isEdit ? 'Edit Committee' : 'Add Committee'),
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
                            const InputDecoration(labelText: 'Committee Name'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Committee name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionController,
                        decoration:
                            const InputDecoration(labelText: 'Description'),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _status,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: const [
                          DropdownMenuItem(
                            value: 'Active',
                            child: Text('Active'),
                          ),
                          DropdownMenuItem(
                            value: 'Completed',
                            child: Text('Completed'),
                          ),
                          DropdownMenuItem(
                            value: 'On Hold',
                            child: Text('On Hold'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            _status = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _startDateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Start Date',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_month),
                            onPressed: () => _pickDate(_startDateController),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _endDateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'End Date',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_month),
                            onPressed: () => _pickDate(_endDateController),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _saveCommittee,
                icon: const Icon(Icons.save_outlined),
                label: Text(_isEdit ? 'Update Committee' : 'Save Committee'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
