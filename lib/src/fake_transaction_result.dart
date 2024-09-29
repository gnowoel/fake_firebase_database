part of '../fake_firebase_database.dart';

class FakeTransactionResult implements TransactionResult {
  @override
  // TODO: implement committed
  bool get committed => throw UnimplementedError();

  @override
  // TODO: implement snapshot
  DataSnapshot get snapshot => throw UnimplementedError();
}
