import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

// Database Setup
part 'db.g.dart';

@DriftDatabase(tables: [Transactions, TransactionCategories])
class AppDatabase extends _$AppDatabase {
  // After generating code, this class needs to define a `schemaVersion` getter
  // and a constructor telling drift where the database should be stored.
  // These are described in the getting started guide: https://drift.simonbinder.eu/setup/
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 3;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'transations',
      native: const DriftNativeOptions(
        // By default, `driftDatabase` from `package:drift_flutter` stores the
        // database files in `getApplicationDocumentsDirectory()`.
        databaseDirectory: getApplicationSupportDirectory,
      ),
      // If you need web support, see https://drift.simonbinder.eu/platforms/web/
    );
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (migrator, from, to) async {
          await migrator.drop(transactionCategories);
          await migrator.drop(transactions);
          await migrator.createTable(transactionCategories);
          await migrator.createTable(transactions);
        },
      );
}

@TableIndex(name: 'item_id', columns: {#id})
@DataClassName('Transaction')
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get description => text()();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();

  IntColumn get categoryId =>
      integer().references(TransactionCategories, #id)();
}

@DataClassName('TransactionCategory')
class TransactionCategories extends Table {
  IntColumn get id => integer().autoIncrement()();
  BoolColumn get isIncome => boolean()();
  TextColumn get name => text()();
}
