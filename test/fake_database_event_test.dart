import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_firebase_database/fake_firebase_database.dart';

void main() {
  group('FakeDatabaseEvent', () {
    late FakeFirebaseDatabase database;
    late DatabaseReference ref;
    late DataSnapshot snapshot;

    setUp(() {
      database = FakeFirebaseDatabase.instance;
      ref = database.ref('test');
      snapshot = FakeDataSnapshot(ref, {'key': 'value'});
    });

    tearDown(() {
      database.clear();
    });

    test('constructor sets properties correctly', () {
      final event = FakeDatabaseEvent(
        type: DatabaseEventType.childAdded,
        snapshot: snapshot,
        previousChildKey: 'prev',
      );

      expect(event.type, DatabaseEventType.childAdded);
      expect(event.snapshot, snapshot);
      expect(event.previousChildKey, 'prev');
    });

    test('childAdded factory creates correct event', () {
      final event = FakeDatabaseEvent.childAdded(snapshot, 'prev');

      expect(event.type, DatabaseEventType.childAdded);
      expect(event.snapshot, snapshot);
      expect(event.previousChildKey, 'prev');
    });

    test('childChanged factory creates correct event', () {
      final event = FakeDatabaseEvent.childChanged(snapshot, 'prev');

      expect(event.type, DatabaseEventType.childChanged);
      expect(event.snapshot, snapshot);
      expect(event.previousChildKey, 'prev');
    });

    test('childMoved factory creates correct event', () {
      final event = FakeDatabaseEvent.childMoved(snapshot, 'prev');

      expect(event.type, DatabaseEventType.childMoved);
      expect(event.snapshot, snapshot);
      expect(event.previousChildKey, 'prev');
    });

    test('childRemoved factory creates correct event', () {
      final event = FakeDatabaseEvent.childRemoved(snapshot);

      expect(event.type, DatabaseEventType.childRemoved);
      expect(event.snapshot, snapshot);
      expect(event.previousChildKey, null);
    });

    test('value factory creates correct event', () {
      final event = FakeDatabaseEvent.value(snapshot);

      expect(event.type, DatabaseEventType.value);
      expect(event.snapshot, snapshot);
      expect(event.previousChildKey, null);
    });

    test('previousChildKey is nullable', () {
      final event = FakeDatabaseEvent(
        type: DatabaseEventType.childAdded,
        snapshot: snapshot,
      );

      expect(event.previousChildKey, null);
    });
  });
}
