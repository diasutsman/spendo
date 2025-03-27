import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:spendo/db.dart'
    show
        Transaction,
        TransactionCategoriesCompanion,
        TransactionCategory,
        TransactionsCompanion;
import 'package:spendo/main.dart' show databaseProvider;

class TransactionForm extends ConsumerStatefulWidget {
  final Transaction? existingTransaction;

  const TransactionForm({super.key, this.existingTransaction});

  @override
  ConsumerState<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends ConsumerState<TransactionForm> {
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  DateTime? _selectedDate;
  int? _selectedCategoryId;
  List<TransactionCategory> _categories = [];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.existingTransaction?.amount.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.existingTransaction?.description ?? '',
    );
    _selectedDate = widget.existingTransaction?.date;
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final db = ref.read(databaseProvider);
    final categories = await db.select(db.transactionCategories).get();
    setState(() {
      _categories = categories;
      if (widget.existingTransaction != null) {
        _selectedCategoryId = widget.existingTransaction!.categoryId;
      }
    });
  }

  Future<void> _saveTransaction() async {
    final db = ref.read(databaseProvider);

    if (_selectedCategoryId == null || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    if (widget.existingTransaction == null) {
      final transaction = TransactionsCompanion.insert(
        description: _descriptionController.text,
        amount: double.parse(_amountController.text),
        date: _selectedDate!,
        categoryId: _selectedCategoryId!,
      );
      await db.transactions.insertOne(transaction);
    } else {
      final transaction = TransactionsCompanion.insert(
        id: Value(widget.existingTransaction?.id ?? 0),
        description: _descriptionController.text,
        amount: double.parse(_amountController.text),
        date: _selectedDate!,
        categoryId: _selectedCategoryId!,
      );
      await db.transactions.replaceOne(transaction);
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingTransaction == null
            ? 'Add Transaction'
            : 'Edit Transaction'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          child: ListView(
            children: [
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 5,
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedDate == null
                          ? 'No date chosen'
                          : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _selectedDate = pickedDate;
                        });
                      }
                    },
                    child: Text('Choose Date'),
                  ),
                ],
              ),
              DropdownButtonFormField<int>(
                value: _selectedCategoryId,
                hint: Text('Select Category'),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category.id,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
              ),
              ElevatedButton(
                onPressed: _saveTransaction,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryForm extends ConsumerStatefulWidget {
  final TransactionCategory? existingCategory;

  const CategoryForm({super.key, this.existingCategory});

  @override
  _CategoryFormState createState() => _CategoryFormState();
}

class _CategoryFormState extends ConsumerState<CategoryForm> {
  late TextEditingController _nameController;
  bool _isIncome = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingCategory?.name ?? '',
    );
    _isIncome = widget.existingCategory?.isIncome ?? false;
  }

  Future<void> _saveCategory() async {
    final db = ref.read(databaseProvider);

    if (widget.existingCategory == null) {
      final category = TransactionCategoriesCompanion.insert(
        name: _nameController.text,
        isIncome: _isIncome,
      );
      await db.transactionCategories.insertOne(category);
    } else {
      final category = TransactionCategoriesCompanion.insert(
        id: Value(widget.existingCategory?.id ?? 0),
        name: _nameController.text,
        isIncome: _isIncome,
      );
      await db.transactionCategories.replaceOne(category);
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.existingCategory == null ? 'Add Category' : 'Edit Category'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Category Name'),
              ),
              DropdownButtonFormField<bool>(
                value: _isIncome,
                hint: Text('Category Type'),
                items: [
                  DropdownMenuItem(
                    value: false,
                    child: Text('Expense'),
                  ),
                  DropdownMenuItem(
                    value: true,
                    child: Text('Income'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _isIncome = value ?? false;
                  });
                },
              ),
              ElevatedButton(
                onPressed: _saveCategory,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
