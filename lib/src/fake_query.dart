part of '../fake_firebase_database.dart';

class FakeQuery implements Query {
  @override
  Query endAt(Object? value, {String? key}) {
    // TODO: implement endAt
    throw UnimplementedError();
  }

  @override
  Query endBefore(Object? value, {String? key}) {
    // TODO: implement endBefore
    throw UnimplementedError();
  }

  @override
  Query equalTo(Object? value, {String? key}) {
    // TODO: implement equalTo
    throw UnimplementedError();
  }

  @override
  Future<DataSnapshot> get() {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Future<void> keepSynced(bool value) {
    // TODO: implement keepSynced
    throw UnimplementedError();
  }

  @override
  Query limitToFirst(int limit) {
    // TODO: implement limitToFirst
    throw UnimplementedError();
  }

  @override
  Query limitToLast(int limit) {
    // TODO: implement limitToLast
    throw UnimplementedError();
  }

  @override
  // TODO: implement onChildAdded
  Stream<DatabaseEvent> get onChildAdded => throw UnimplementedError();

  @override
  // TODO: implement onChildChanged
  Stream<DatabaseEvent> get onChildChanged => throw UnimplementedError();

  @override
  // TODO: implement onChildMoved
  Stream<DatabaseEvent> get onChildMoved => throw UnimplementedError();

  @override
  // TODO: implement onChildRemoved
  Stream<DatabaseEvent> get onChildRemoved => throw UnimplementedError();

  @override
  // TODO: implement onValue
  Stream<DatabaseEvent> get onValue => throw UnimplementedError();

  @override
  Future<DatabaseEvent> once(
      [DatabaseEventType eventType = DatabaseEventType.value]) {
    // TODO: implement once
    throw UnimplementedError();
  }

  @override
  Query orderByChild(String path) {
    // TODO: implement orderByChild
    throw UnimplementedError();
  }

  @override
  Query orderByKey() {
    // TODO: implement orderByKey
    throw UnimplementedError();
  }

  @override
  Query orderByPriority() {
    // TODO: implement orderByPriority
    throw UnimplementedError();
  }

  @override
  Query orderByValue() {
    // TODO: implement orderByValue
    throw UnimplementedError();
  }

  @override
  // TODO: implement path
  String get path => throw UnimplementedError();

  @override
  // TODO: implement ref
  DatabaseReference get ref => throw UnimplementedError();

  @override
  Query startAfter(Object? value, {String? key}) {
    // TODO: implement startAfter
    throw UnimplementedError();
  }

  @override
  Query startAt(Object? value, {String? key}) {
    // TODO: implement startAt
    throw UnimplementedError();
  }
}
