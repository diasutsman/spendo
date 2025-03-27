import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:spendo/db.dart'
    show
        AppDatabase,
        TransactionCategoriesCompanion,
        TransactionCategory,
        TransactionsCompanion;

final databaseProvider = Provider((ref) => AppDatabase());

Future<void> writeDummyData() async {
  final db = ProviderContainer().read(databaseProvider);

  await db.transactionCategories.deleteAll();
  await db.transactions.deleteAll();

  List<String> expenseCategories = [
    'Food and Drinks',
    'Gifts',
    'Health/medical',
    'Home',
    'Transportation',
    'Personal',
    'Mistake',
    'Utilities',
    'MCK',
    'Debt',
    'Other',
    'Corporate bull',
    'Bank Admin',
    'Phone Bill',
  ];

  for (int i = 0; i < expenseCategories.length; i++) {
    await db.transactionCategories
        .insertOne(TransactionCategoriesCompanion.insert(
      name: expenseCategories[i],
      isIncome: false,
    ));
  }

  List<String> incomeCategories = [
    'Savings',
    'Paycheck',
    'Bonus',
    'Interest',
    'Side Hustle',
    'Freelance',
  ];

  for (int i = 0; i < incomeCategories.length; i++) {
    await db.transactionCategories
        .insertOne(TransactionCategoriesCompanion.insert(
      name: incomeCategories[i],
      isIncome: true,
    ));
  }

  for (final line in [
    '02/01/2025\tRp276,000.00\ttws soundpat\tUtilities',
    '04/01/2025\tRp1,000,000.00\tmeja kursi lampu\tUtilities',
    '04/01/2025\tRp40,000.00\tbrasso, paku\tUtilities',
    '04/01/2025\tRp40,000.00\tchitato + susu \tFood and Drinks',
    '04/01/2025\tRp7,000.00\tnaskun\tFood and Drinks',
    '04/01/2025\tRp7,000.00\tnaskun\tFood and Drinks',
    '11/01/2025\tRp10,000.00\tbubur\tFood and Drinks',
    '11/01/2025\tRp24,500.00\t   \tFood and Drinks',
    '14/01/2025\tRp20,000.00\t      \tFood and Drinks',
    '16/01/2025\tRp12,000.00\tbubur sapi\tFood and Drinks',
    '17/01/2025\tRp7,000.00\tnaskun\tFood and Drinks',
    '17/01/2025\tRp17,000.00\tsate padang\tFood and Drinks',
    '21/01/2025\tRp7,000.00\tnaskun\tFood and Drinks',
    '22/01/2025\tRp7,000.00\tnaskun\tFood and Drinks',
    '22/01/2025\tRp77,289.00\tTOEFL \tOther',
    '25/01/2025\tRp39,000.00\t    \tFood and Drinks',
    '26/01/2025\tRp10,000.00\t5 chitatos\tFood and Drinks',
    '28/01/2025\tRp6,000.00\t4 chitatos\tFood and Drinks',
    '28/01/2025\tRp12,000.00\tayam datul\tFood and Drinks',
    '28/01/2025\tRp12,000.00\t2 sambal geprek  \tFood and Drinks',
    '02/02/2025\tRp7,500.00\tbiaya admin\tBank Admin',
    '02/02/2025\tRp11,000.00\tayam datul\tFood and Drinks',
    '02/02/2025\tRp6,000.00\tsambal geprek  \tFood and Drinks',
    '02/02/2025\tRp595,600.00\tHardisk External 1TB WD ELEMENTS HDD External 500GB Portable USB\tUtilities',
    '02/02/2025\tRp75,000.00\tusb\tUtilities',
    '04/02/2025\tRp10,000.00\tsnacks\tFood and Drinks',
    '08/02/2025\tRp15,000.00\tsnacks\tFood and Drinks',
    '10/02/2025\tRp10,000.00\tsnacks\tFood and Drinks',
    '11/02/2025\tRp10,000.00\tsnacks\tFood and Drinks',
    '12/02/2025\tRp10,000.00\tsnacks\tFood and Drinks',
    '12/02/2025\tRp19,000.00\tmixue\tFood and Drinks',
    '12/02/2025\tRp11,000.00\tnikita ayam\tFood and Drinks',
    '13/02/2025\tRp17,000.00\tnikita ayam\tFood and Drinks',
    '15/02/2025\tRp7,000.00\tsnacks\tFood and Drinks',
    '15/02/2025\tRp35,000.00\tearphone\tFood and Drinks',
    '18/02/2025\tRp17,000.00\tnikita ayam\tFood and Drinks',
    '20/02/2025\tRp17,000.00\tnikita ayam\tFood and Drinks',
    '22/02/2025\tRp17,000.00\tnikita ayam\tFood and Drinks',
    '22/02/2025\tRp7,200.00\tspaghetti\tFood and Drinks',
    '22/02/2025\tRp292,700.00\tLogitech keyboard  \tUtilities',
    '13/03/2025\tRp17,000.00\tnikita chicken\tFood and Drinks',
    '14/03/2025\tRp17,000.00\tnikita chicken\tFood and Drinks',
    '23/03/2025\tRp40,000.00\tbarber + shave\tPersonal',
    '01/01/2025\tRp5,200,000.00\tgaji\tPaycheck',
    '01/02/2025\tRp5,200,000.00\tgaji\tPaycheck',
    '01/03/2025\tRp5,200,000.00\tgaji\tPaycheck',
    '01/03/2025\tRp1,000,000.00\tAlbert\'s freelance\tPaycheck',
  ]) {
    final parts = line.split('\t');
    final date = DateFormat('dd/MM/yyyy').parse(parts[0]);
    final amount =
        double.parse(parts[1].replaceAll(RegExp(r'[^\d.]'), '')) * -1;
    final description = parts[2];
    final category = parts[3];

    final categoryId = (db.transactionCategories.select()
      ..where((c) => c.name.equals(category)));

    await db.transactions.insertOne(
      TransactionsCompanion.insert(
        date: date,
        amount: amount,
        description: description,
        categoryId: (await categoryId.get()).firstOrNull!.id,
      ),
    );
  }
}

// UI
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await writeDummyData();

  runApp(
    ProviderScope(child: SpendoApp()),
  );
}

class SpendoApp extends StatelessWidget {
  const SpendoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Spendo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Spendo'),
        ),
        body: TabBarView(
          children: [
            SummaryScreen(),
            TransactionsScreen(),
          ],
        ),
        bottomNavigationBar: TabBar(
          tabs: [
            Tab(
              icon: Icon(Icons.pie_chart),
              text: 'Summary',
            ),
            Tab(
              icon: Icon(Icons.list),
              text: 'Transactions',
            ),
          ],
        ),
      ),
    );
  }
}

class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    return FutureBuilder<List<TransactionCategory>>(
      future: db.select(db.transactionCategories).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        final categories = snapshot.data!;
        final incomeCategories = categories.where((c) => c.isIncome).toList();
        final expenseCategories = categories.where((c) => !c.isIncome).toList();
        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              TabBar(
                tabs: [
                  Tab(text: 'Expenses'),
                  Tab(text: 'Income'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    ListView(
                      children: expenseCategories
                          .map((c) => ListTile(
                                title: Text(c.name),
                              ))
                          .toList(),
                    ),
                    ListView(
                      children: incomeCategories
                          .map((c) => ListTile(
                                title: Text(c.name),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Transactions'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Expenses'),
              Tab(text: 'Income'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTransactionList(context, ref, false),
            _buildTransactionList(context, ref, true),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(
      BuildContext context, WidgetRef ref, bool isIncome) {
    final db = ref.watch(databaseProvider);
    final query = db.select(db.transactions).join([
      innerJoin(db.transactionCategories,
          db.transactions.categoryId.equalsExp(db.transactionCategories.id))
    ])
      ..where(db.transactionCategories.isIncome.equals(isIncome));
    return FutureBuilder<List<TypedResult>>(
      future: query.get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        final transactions = snapshot.data!;
        return ListView(
          children: transactions
              .map((t) => ListTile(
                    title: Text(t.readTable(db.transactions).description),
                    subtitle: Text(t.readTable(db.transactionCategories).name),
                    trailing: Text(
                        'Rp${t.readTable(db.transactions).amount.toString()}'),
                  ))
              .toList(),
        );
      },
    );
  }
}
