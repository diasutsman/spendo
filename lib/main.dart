import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(PersonalBudgetApp());
}

class PersonalBudgetApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Personal Budgeting Tool',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ExpenseDashboard(),
    );
  }
}

class ExpenseDashboard extends StatefulWidget {
  @override
  _ExpenseDashboardState createState() => _ExpenseDashboardState();
}

class _ExpenseDashboardState extends State<ExpenseDashboard> {
  List<Expense> _expenses = [];
  double get totalSpending =>
      _expenses.fold(0, (sum, item) => sum + item.amount);

  void _addExpense(String title, double amount, DateTime date) {
    final newExpense = Expense(
      id: Uuid().v4(),
      title: title,
      amount: amount,
      date: date,
    );
    setState(() => _expenses.add(newExpense));
  }

  void _openAddExpenseModal() {
    showModalBottomSheet(
      context: context,
      builder: (_) => AddExpenseForm(onAdd: _addExpense),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personal Budget Tracker'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _openAddExpenseModal,
          ),
        ],
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Spending:', style: TextStyle(fontSize: 18)),
                  Text(' \$${totalSpending.toStringAsFixed(2)}',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal)),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _expenses.length,
              itemBuilder: (ctx, idx) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Text(_expenses[idx].amount.toStringAsFixed(0)),
                ),
                title: Text(_expenses[idx].title),
                subtitle: Text(
                    '${_expenses[idx].date.toLocal().toString().split(" ")[0]}'),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _openAddExpenseModal,
      ),
    );
  }
}

class AddExpenseForm extends StatefulWidget {
  final Function(String, double, DateTime) onAdd;
  AddExpenseForm({required this.onAdd});

  @override
  _AddExpenseFormState createState() => _AddExpenseFormState();
}

class _AddExpenseFormState extends State<AddExpenseForm> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  void _submitData() {
    final enteredTitle = _titleController.text;
    final enteredAmount = double.tryParse(_amountController.text) ?? 0;
    if (enteredTitle.isEmpty || enteredAmount <= 0) return;
    widget.onAdd(enteredTitle, enteredAmount, _selectedDate);
    Navigator.of(context).pop();
  }

  void _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Title'),
              controller: _titleController,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Amount'),
              controller: _amountController,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text('Date: ${_selectedDate.toLocal().toString().split(" ")[0]}'),
                TextButton(
                  onPressed: _pickDate,
                  child: Text('Pick Date'),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: _submitData,
              child: Text('Add Expense'),
            ),
          ],
        ),
      ),
    );
  }
}

class Expense {
  final String id;
  final String title;
  final double amount;
  final DateTime date;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
  });
}
