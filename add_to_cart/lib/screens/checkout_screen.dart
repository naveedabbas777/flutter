import 'package:add_to_cart/routes/app_routes.dart';
import 'package:flutter/material.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String address = '';
  String phone = '';

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.sizeOf(context).width < 360;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final contentWidth =
              constraints.maxWidth > 760 ? 760.0 : constraints.maxWidth;

          return Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: contentWidth,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(isNarrow ? 14 : 16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Delivery Details',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Name is required';
                              }
                              return null;
                            },
                            onSaved: (value) => name = value!.trim(),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Address',
                              prefixIcon: Icon(Icons.location_on_outlined),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Address is required';
                              }
                              return null;
                            },
                            onSaved: (value) => address = value!.trim(),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Phone Number',
                              prefixIcon: Icon(Icons.phone_outlined),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Phone number is required';
                              }
                              if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
                                return 'Enter only numbers';
                              }
                              return null;
                            },
                            onSaved: (value) => phone = value!.trim(),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.confirmation,
                                    arguments: {
                                      'name': name,
                                      'address': address,
                                      'phone': phone,
                                    },
                                  );
                                }
                              },
                              child: const Text('Continue'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
