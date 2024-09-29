part of '../fake_firebase_database.dart';

class FakeDatabaseEvent implements DatabaseEvent {
  @override
  // TODO: implement previousChildKey
  String? get previousChildKey => throw UnimplementedError();

  @override
  // TODO: implement snapshot
  DataSnapshot get snapshot => throw UnimplementedError();

  @override
  // TODO: implement type
  DatabaseEventType get type => throw UnimplementedError();
}
