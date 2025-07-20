import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../providers/sadaka_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Default to current month
  late int _selectedMonth;
  late int _selectedYear;
  String _viewMode = 'monthly'; // 'monthly' or 'yearly'

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = 6; // June
    _selectedYear = now.year;
  }

  String _getMonthName() {
    return DateFormat('MMMM').format(DateTime(_selectedYear, _selectedMonth));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Consumer<SadakaProvider>(
        builder: (context, provider, child) {
          final monthTotal = provider.getMonthTotal(
            _selectedMonth,
            _selectedYear,
          );
          final paidAmount = provider.getMonthPaidAmount(
            _selectedMonth,
            _selectedYear,
          );
          final remainingAmount = monthTotal - paidAmount;
          final isFullyPaid = provider.isMonthFullyPaid(
            _selectedMonth,
            _selectedYear,
          );

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Month selector
                GestureDetector(
                  onTap: () {
                    _showMonthPicker(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 16.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${_getMonthName()} $_selectedYear',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Total amount
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.white.withOpacity(0.8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.2),
                              Colors.white.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total Amount',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                // Filter dropdown
                                GestureDetector(
                                  onTap: () {
                                    _showFilterOptions(context);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4.0,
                                      horizontal: 8.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _viewMode == 'monthly'
                                              ? 'Monthly'
                                              : 'Yearly',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.blue.shade700,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.filter_list,
                                          size: 16,
                                          color: Colors.blue.shade700,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _viewMode == 'monthly'
                                  ? '৳${monthTotal.toStringAsFixed(2)}'
                                  : '৳${provider.getYearTotal(_selectedYear).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Paid',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      _viewMode == 'monthly'
                                          ? '৳${paidAmount.toStringAsFixed(2)}'
                                          : '৳${provider.getYearPaidAmount(_selectedYear).toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Remaining',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      _viewMode == 'monthly'
                                          ? '৳${remainingAmount.toStringAsFixed(2)}'
                                          : '৳${(provider.getYearTotal(_selectedYear) - provider.getYearPaidAmount(_selectedYear)).toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color:
                                            _viewMode == 'monthly'
                                                ? (remainingAmount > 0
                                                    ? Colors.red
                                                    : Colors.green)
                                                : ((provider.getYearTotal(
                                                              _selectedYear,
                                                            ) -
                                                            provider
                                                                .getYearPaidAmount(
                                                                  _selectedYear,
                                                                )) >
                                                        0
                                                    ? Colors.red
                                                    : Colors.green),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Payment button
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_viewMode == 'monthly') {
                        if (!isFullyPaid) {
                          _showPaymentDialog(
                            context,
                            provider,
                            remainingAmount,
                          );
                        }
                      } else {
                        // For yearly view, show month selection dialog
                        _showMonthSelectionForPayment(context, provider);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _viewMode == 'monthly' && isFullyPaid
                              ? Colors.green
                              : Colors.blue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      _viewMode == 'monthly' && isFullyPaid ? 'Paid' : 'Pay',
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Category breakdown
                Row(
                  children: [
                    const Text(
                      'Category Breakdown',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _viewMode == 'monthly'
                          ? '(${_getMonthName()})'
                          : '($_selectedYear)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildCategoryBreakdown(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryBreakdown(SadakaProvider provider) {
    // Get all items for the selected month or year
    final items =
        _viewMode == 'monthly'
            ? provider.items
                .where(
                  (item) =>
                      item.date.month == _selectedMonth &&
                      item.date.year == _selectedYear,
                )
                .toList()
            : provider.items
                .where((item) => item.date.year == _selectedYear)
                .toList();

    // Calculate totals by category
    final Map<String, double> categoryTotals = {};
    for (var item in items) {
      categoryTotals[item.title] =
          (categoryTotals[item.title] ?? 0) + item.amount;
    }

    if (categoryTotals.isEmpty) {
      return const Center(child: Text('No data for this month'));
    }

    return Column(
      children:
          categoryTotals.entries.map((entry) {
            final Color color;
            switch (entry.key) {
              case 'Daily Sadaka':
                color = Colors.green;
                break;
              case 'Daily Kaffara':
                color = Colors.red;
                break;
              case 'Rida Allahi':
                color = Colors.blue;
                break;
              default:
                color = Colors.grey;
            }

            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: Colors.white.withOpacity(0.8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
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
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: color.withOpacity(0.2),
                        radius: 16,
                        child: Text(
                          '৳',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                      title: Text(
                        entry.key,
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: Text(
                        '৳${entry.value.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  void _showMonthPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Month'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: 12,
              itemBuilder: (context, index) {
                final month = index + 1;
                final monthName = DateFormat(
                  'MMMM',
                ).format(DateTime(2022, month));
                return ListTile(
                  title: Text(monthName),
                  selected: month == _selectedMonth,
                  onTap: () {
                    setState(() {
                      _selectedMonth = month;
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showFilterOptions(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Center(
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Select View'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Monthly'),
                  selected: _viewMode == 'monthly',
                  onTap: () {
                    setState(() {
                      _viewMode = 'monthly';
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Yearly'),
                  selected: _viewMode == 'yearly',
                  onTap: () {
                    setState(() {
                      _viewMode = 'yearly';
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMonthSelectionForPayment(
    BuildContext context,
    SadakaProvider provider,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Center(
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Select Month for Payment'),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: 12,
                itemBuilder: (context, index) {
                  final month = index + 1;
                  final monthName = DateFormat(
                    'MMMM',
                  ).format(DateTime(2022, month));

                  // Calculate remaining amount for this month
                  final monthTotal = provider.getMonthTotal(
                    month,
                    _selectedYear,
                  );
                  final paidAmount = provider.getMonthPaidAmount(
                    month,
                    _selectedYear,
                  );
                  final remainingAmount = monthTotal - paidAmount;
                  final isFullyPaid = provider.isMonthFullyPaid(
                    month,
                    _selectedYear,
                  );

                  return ListTile(
                    title: Text(monthName),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '৳${remainingAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            color:
                                remainingAmount > 0 ? Colors.red : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isFullyPaid)
                          const Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                    enabled: remainingAmount > 0,
                    onTap: () {
                      Navigator.pop(context);
                      _showPaymentDialog(
                        context,
                        provider,
                        remainingAmount,
                        month: month,
                      );
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPaymentDialog(
    BuildContext context,
    SadakaProvider provider,
    double remainingAmount, {
    int? month,
  }) {
    final selectedMonth = month ?? _selectedMonth;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return PaymentDialog(
          provider: provider,
          month: selectedMonth,
          year: _selectedYear,
          remainingAmount: remainingAmount,
        );
      },
    );
  }
}

class PaymentDialog extends StatefulWidget {
  final SadakaProvider provider;
  final int month;
  final int year;
  final double remainingAmount;

  const PaymentDialog({
    Key? key,
    required this.provider,
    required this.month,
    required this.year,
    required this.remainingAmount,
  }) : super(key: key);

  @override
  _PaymentDialogState createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  bool _isFullPayment = true;
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: MediaQuery.of(context).viewInsets.bottom > 0 ? 80.0 : 24.0,
      ),
      contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0.0),
      title: const Text('Make Payment', style: TextStyle(fontSize: 18)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text(
                  'Full Payment',
                  style: TextStyle(fontSize: 14),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                leading: Radio<bool>(
                  value: true,
                  groupValue: _isFullPayment,
                  onChanged: (value) {
                    setState(() {
                      _isFullPayment = value!;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text(
                  'Partial Payment',
                  style: TextStyle(fontSize: 14),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                leading: Radio<bool>(
                  value: false,
                  groupValue: _isFullPayment,
                  onChanged: (value) {
                    setState(() {
                      _isFullPayment = value!;
                    });
                  },
                ),
              ),
              if (!_isFullPayment) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    labelStyle: const TextStyle(fontSize: 14),
                    hintText:
                        'Maximum: \$${widget.remainingAmount.toStringAsFixed(2)}',
                    hintStyle: const TextStyle(fontSize: 12),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                  ),
                  style: const TextStyle(fontSize: 14),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null) {
                      return 'Please enter a valid number';
                    }
                    if (amount <= 0) {
                      return 'Amount must be greater than zero';
                    }
                    if (amount > widget.remainingAmount) {
                      return 'Amount cannot exceed remaining balance';
                    }
                    return null;
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
    // actions: [
    //     TextButton(
    //       child: const Text('Cancel'),
    //       onPressed: () {
    //         Navigator.of(context).pop();
    //       },
    //     ),
    //     TextButton(
    //       child: const Text('Save'),
    //       onPressed: () {
    //         if (_isFullPayment) {
    //           widget.provider.makeFullPayment(widget.month, widget.year);
    //           Navigator.of(context).pop();
    //         } else if (_formKey.currentState!.validate()) {
    //           final amount = double.parse(_amountController.text);
    //           widget.provider.makePayment(widget.month, widget.year, amount);
    //           Navigator.of(context).pop();
    //         }
    //       },
    //     ),
    //   ],
    // );
  }
}
