part of '../fake_firebase_database.dart';

class FakeDatabaseEvent implements DatabaseEvent {
  final DatabaseEventType _type;
  final DataSnapshot _snapshot;
  final String? _previousChildKey;

  FakeDatabaseEvent({
    required DatabaseEventType type,
    required DataSnapshot snapshot,
    String? previousChildKey,
  })  : _type = type,
        _snapshot = snapshot,
        _previousChildKey = previousChildKey;

  @override
  DatabaseEventType get type => _type;

  @override
  DataSnapshot get snapshot => _snapshot;

  @override
  String? get previousChildKey => _previousChildKey;

  factory FakeDatabaseEvent.childAdded(
      DataSnapshot snapshot, String? previousChildKey) {
    return FakeDatabaseEvent(
      type: DatabaseEventType.childAdded,
      snapshot: snapshot,
      previousChildKey: previousChildKey,
    );
  }

  factory FakeDatabaseEvent.childChanged(
      DataSnapshot snapshot, String? previousChildKey) {
    return FakeDatabaseEvent(
      type: DatabaseEventType.childChanged,
      snapshot: snapshot,
      previousChildKey: previousChildKey,
    );
  }

  factory FakeDatabaseEvent.childMoved(
      DataSnapshot snapshot, String? previousChildKey) {
    return FakeDatabaseEvent(
      type: DatabaseEventType.childMoved,
      snapshot: snapshot,
      previousChildKey: previousChildKey,
    );
  }

  factory FakeDatabaseEvent.childRemoved(DataSnapshot snapshot) {
    return FakeDatabaseEvent(
      type: DatabaseEventType.childRemoved,
      snapshot: snapshot,
    );
  }

  factory FakeDatabaseEvent.value(DataSnapshot snapshot) {
    return FakeDatabaseEvent(
      type: DatabaseEventType.value,
      snapshot: snapshot,
    );
  }
}
