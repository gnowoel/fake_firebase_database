part of '../fake_firebase_database.dart';

class FakeDataSnapshot implements DataSnapshot {
  final DatabaseReference _ref;
  final Object? _value;

  FakeDataSnapshot(this._ref, this._value);

  @override
  DataSnapshot child(String path) {
    // TODO: implement child
    throw UnimplementedError();
  }

  @override
  // TODO: implement children
  Iterable<DataSnapshot> get children => throw UnimplementedError();

  @override
  // TODO: implement exists
  bool get exists => throw UnimplementedError();

  @override
  bool hasChild(String path) {
    // TODO: implement hasChild
    throw UnimplementedError();
  }

  @override
  // TODO: implement key
  String? get key => throw UnimplementedError();

  @override
  // TODO: implement priority
  Object? get priority => throw UnimplementedError();

  @override
  // TODO: implement ref
  DatabaseReference get ref => throw UnimplementedError();

  @override
  Object? get value => _value;
}
