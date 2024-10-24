part of '../fake_firebase_database.dart';

class FakeTransactionResult implements TransactionResult {
  final bool _committed;
  final DataSnapshot _snapshot;

  FakeTransactionResult(this._committed, this._snapshot);

  @override
  bool get committed => _committed;

  @override
  DataSnapshot get snapshot => _snapshot;
}
