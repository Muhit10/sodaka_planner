import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/sadaka_item.dart';
import '../providers/sadaka_provider.dart';

class DayScreen extends StatelessWidget {
  final DateTime date;

  const DayScreen({Key? key, required this.date}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM d, yyyy');
    final formattedDate = dateFormat.format(date);

    return Scaffold(
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback:
              (bounds) => LinearGradient(
                colors: const [
                  Color(0xFFF66A4B),
                  Color(0xFFA24AE7),
                  Color(0xFF4859F3),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(bounds),
          child: Text(
            formattedDate,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        leading: ShaderMask(
          shaderCallback:
              (bounds) => LinearGradient(
                colors: const [
                  Color(0xFFF66A4B),
                  Color(0xFFA24AE7),
                  Color(0xFF4859F3),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(bounds),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        actions: [
          Consumer<SadakaProvider>(
            builder: (context, provider, child) {
              final items = provider.getItemsForDate(date);
              final totalAmount = items.fold(
                0.0,
                (sum, item) => sum + item.amount,
              );

              return Container(
                margin: const EdgeInsets.only(right: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '৳',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      totalAmount.toStringAsFixed(2),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        backgroundColor: Colors.blue.shade50,
      ),
      body: Consumer<SadakaProvider>(
        builder: (context, sodakaProvider, child) {
          final items = sodakaProvider.getItemsForDate(date);

          return items.isEmpty
              ? const Center(child: Text('No items for this day'))
              : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return SadakaItemCard(
                    item: item,
                    onDelete: () {
                      final provider = Provider.of<SadakaProvider>(
                        context,
                        listen: false,
                      );
                      provider.deleteItem(item.id);
                    },
                    onEdit: () {
                      final provider = Provider.of<SadakaProvider>(
                        context,
                        listen: false,
                      );
                      _showEditItemDialog(context, item, provider);
                    },
                  );
                },
              );
        },
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF66A4B), Color(0xFFA24AE7), Color(0xFF4859F3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: FloatingActionButton(
          onPressed: () {
            _showAddItemDialog(context, date);
          },
          backgroundColor: Colors.transparent,
          elevation: 8,
          child: const Icon(Icons.add, color: Color(0xffFFFFFF)),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _showAddItemDialog(BuildContext context, DateTime date) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AddItemDialog(date: date),
    );
  }

  void _showEditItemDialog(
    BuildContext context,
    SadakaItem item,
    SadakaProvider provider,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => EditItemDialog(item: item, provider: provider),
    );
  }
}

class SadakaItemCard extends StatelessWidget {
  final SadakaItem item;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const SadakaItemCard({
    Key? key,
    required this.item,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  Color _getTitleColor() {
    switch (item.title) {
      case 'Daily Sadaka':
        return Colors.green;
      case 'Daily Kaffara':
        return Colors.red;
      case 'Rida Allahi':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      // Add glass effect with transparency
      color: Colors.white.withOpacity(0.8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            width: double.infinity,
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _getTitleColor(),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 16),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: onEdit,
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 14,
                          ),
                          onPressed: () {
                            // Show confirmation dialog
                            showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder:
                                  (ctx) => Center(
                                    child: AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      title: const Text('Confirm Delete'),
                                      content: const Text(
                                        'Are you sure you want to delete this item?',
                                      ),
                                      actions: [
                                        TextButton(
                                          child: const Text('Cancel'),
                                          onPressed: () {
                                            Navigator.of(ctx).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: const Text('Delete'),
                                          onPressed: () {
                                            Navigator.of(ctx).pop();
                                            onDelete();
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // const SizedBox(height: 2),
                Text(
                  'Amount: ৳${item.amount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AddItemDialog extends StatefulWidget {
  final DateTime date;

  const AddItemDialog({Key? key, required this.date}) : super(key: key);

  @override
  _AddItemDialogState createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  String _title = 'Daily Sadaka';
  final _amountController = TextEditingController();

  final List<String> _titleOptions = [
    'Daily Sadaka',
    'Daily Kaffara',
    'Rida Allahi',
  ];

  final List<double> _suggestedAmounts = [1.0, 2.0, 5.0];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: SingleChildScrollView(
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.blue.shade900,
            title: const Text(
              'Add Item',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: _title,
                    dropdownColor: Colors.blue.shade800,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      labelStyle: TextStyle(fontSize: 14, color: Colors.white),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                    items:
                        _titleOptions.map((title) {
                          return DropdownMenuItem(
                            value: title,
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _title = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      labelStyle: TextStyle(fontSize: 14, color: Colors.white),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8.0,
                    children:
                        _suggestedAmounts.map((amount) {
                          return ActionChip(
                            backgroundColor: Colors.blue.shade700,
                            label: Text(
                              '৳${amount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _amountController.text = amount.toString();
                              });
                            },
                          );
                        }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text(
                  'Save',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final provider = Provider.of<SadakaProvider>(
                      context,
                      listen: false,
                    );
                    provider.addItem(
                      SadakaItem(
                        title: _title,
                        amount: double.parse(_amountController.text),
                        date: widget.date,
                      ),
                    );
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditItemDialog extends StatefulWidget {
  final SadakaItem item;
  final SadakaProvider provider;

  const EditItemDialog({Key? key, required this.item, required this.provider})
    : super(key: key);

  @override
  _EditItemDialogState createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<EditItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late TextEditingController _amountController;

  final List<String> _titleOptions = [
    'Daily Sadaka',
    'Daily Kaffara',
    'Rida Allahi',
  ];

  @override
  void initState() {
    super.initState();
    _title = widget.item.title;
    _amountController = TextEditingController(
      text: widget.item.amount.toString(),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.blue.shade900,
        title: ShaderMask(
          shaderCallback:
              (bounds) => const LinearGradient(
                colors: [
                  Color(0xFFF66A4B),
                  Color(0xFFA24AE7),
                  Color(0xFF4859F3),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(bounds),
          child: const Text(
            'Edit Sadaka',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _title,
                dropdownColor: Colors.blue.shade800,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  labelStyle: TextStyle(fontSize: 14, color: Colors.white),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: const TextStyle(fontSize: 14, color: Colors.white),
                items:
                    _titleOptions.map((title) {
                      return DropdownMenuItem(
                        value: title,
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _title = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  labelStyle: TextStyle(fontSize: 14, color: Colors.white),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: const TextStyle(fontSize: 14, color: Colors.white),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text(
              'Save',
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                widget.provider.updateItem(
                  widget.item.id,
                  _title,
                  double.parse(_amountController.text),
                );
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }
}
