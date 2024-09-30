import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fake_firebase_database/fake_firebase_database.dart';

void main() {
  late FakeFirebaseDatabase database;

  setUp(() {
    database = FakeFirebaseDatabase.instance;
  });

  group('FakeFirebaseDatabase', () {
    test('can create a FirebaseDatabase instance', () {
      final instance = FakeFirebaseDatabase.instance;

      expect(instance, isA<FirebaseDatabase>());
    });

    test('should return a singleton instance', () {
      final instance1 = FakeFirebaseDatabase.instance;
      final instance2 = FakeFirebaseDatabase.instance;

      expect(instance1, same(instance2));
    });

    test('ref() returns a DatabaseReference with root path', () {
      final ref = database.ref();

      expect(ref, isA<DatabaseReference>());
      expect(ref.path, '/');
    });

    test('ref(path) returns a DatabaseReference with specified path', () {
      final ref = database.ref('users/123');

      expect(ref, isA<DatabaseReference>());
      expect(ref.path, 'users/123');
    });
  });

  group('FakeDatabaseReference', () {
    test('can set() and get() at root path', () async {
      final ref = database.ref();
      final value = {'name': 'John', 'age': 18};

      await ref.set(value);

      final snapshot = await ref.get();
      expect(snapshot.value, value);
    });

    test('can set() and get() a complex object at root path', () async {
      final ref = database.ref();
      final value = {
        'name': 'John',
        'age': 18,
        'addresses': {
          'line1': '100 Mountain View',
        },
      };

      await ref.set(value);

      final snapshot = await ref.get();
      expect(snapshot.value, value);
    });
  });
}
