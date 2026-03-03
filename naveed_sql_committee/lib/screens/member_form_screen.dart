import 'package:flutter/material.dart';

import '../data/database_helper.dart';

class MemberFormScreen extends StatefulWidget {
  const MemberFormScreen({
    super.key,
    required this.committeeId,
    this.member,
  });

  final int committeeId;
  final Map<String, Object?>? member;

  @override
  State<MemberFormScreen> createState() => _MemberFormScreenState();
}

class _MemberFormScreenState extends State<MemberFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _roleController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _joinedAtController = TextEditingController();
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  bool get _isEdit => widget.member != null;

  @override
  void initState() {
    super.initState();
    final member = widget.member;
    if (member != null) {
      _nameController.text = (member['name'] ?? '').toString();
      _roleController.text = (member['role'] ?? '').toString();
      _phoneController.text = (member['phone'] ?? '').toString();
      _emailController.text = (member['email'] ?? '').toString();
      _joinedAtController.text = (member['joined_at'] ?? '').toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _joinedAtController.dispose();
    super.dispose();
  }

  Future<void> _pickJoinDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 5),
    );

    if (pickedDate == null) {
      return;
    }

    _joinedAtController.text =
        '${pickedDate.year.toString().padLeft(4, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
  }

  Future<void> _saveMember() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final role = _roleController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final joinedAt = _joinedAtController.text.trim();

    if (_isEdit) {
      await _databaseHelper.updateMember(
        id: widget.member!['id'] as int,
        name: name,
        role: role,
        phone: phone,
        email: email,
        joinedAt: joinedAt.isEmpty ? null : joinedAt,
      );
    } else {
      await _databaseHelper.insertMember(
        committeeId: widget.committeeId,
        name: name,
        role: role,
        phone: phone,
        email: email,
        joinedAt: joinedAt.isEmpty ? null : joinedAt,
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
        title: Text(_isEdit ? 'Edit Member' : 'Add Member'),
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
                        decoration: const InputDecoration(labelText: 'Member Name'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Member name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _roleController,
                        decoration: const InputDecoration(labelText: 'Role'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(labelText: 'Phone'),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _joinedAtController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Join Date',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_month),
                            onPressed: _pickJoinDate,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _saveMember,
                icon: const Icon(Icons.save_outlined),
                label: Text(_isEdit ? 'Update Member' : 'Save Member'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
