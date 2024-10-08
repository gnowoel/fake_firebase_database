import 'package:flutter_test/flutter_test.dart';

import 'package:fake_firebase_database/fake_firebase_database.dart';

void main() {
  final database = FakeFirebaseDatabase.instance;

  setUp(() async {
    final ref = database.ref();
    await ref.set(null);
  });

  group('FakeDataSnapshot', () {
    group('get value', () {
      test('returns the correct value', () {
        final ref = database.ref('users/123');
        final value = {'name': 'John', 'age': 18};
        final snapshot = FakeDataSnapshot(ref, value);

        expect(snapshot.value, value);
      });

      test('can be null', () {
        final ref = database.ref('users/123');
        final snapshot = FakeDataSnapshot(ref, null);

        expect(snapshot.value, null);
      });

      test('can be a primitive type', () {
        final ref = database.ref('users/123/name');
        const value = 'John';
        final snapshot = FakeDataSnapshot(ref, value);

        expect(snapshot.value, value);
      });

      test('value can be a complex nested structure', () {
        final ref = database.ref('users');
        final value = {
          '123': {
            'name': 'John',
            'age': 30,
            'address': {'city': 'New York', 'country': 'USA'}
          },
          '456': {
            'name': 'Jane',
            'age': 25,
            'address': {'city': 'London', 'country': 'UK'}
          }
        };
        final snapshot = FakeDataSnapshot(ref, value);

        expect(snapshot.value, value);
      });
    });

    group('child()', () {
      test('returns a new DataSnapshot for the specified path', () {
        final ref = database.ref('users');
        final value = {
          '123': {'name': 'John', 'age': 30}
        };
        final snapshot = FakeDataSnapshot(ref, value);

        final childSnapshot = snapshot.child('123/name');
        expect(childSnapshot.value, 'John');
      });
    });

    group('get exists', () {
      test('returns true when value is not null', () {
        final ref = database.ref('users/123');
        final value = {'name': 'John', 'age': 30};
        final snapshot = FakeDataSnapshot(ref, value);

        expect(snapshot.exists, true);
      });

      test('returns false when value is null', () {
        final ref = database.ref('users/123');
        final snapshot = FakeDataSnapshot(ref, null);

        expect(snapshot.exists, false);
      });
    });

    group('get key', () {
      test('returns null if at the root path', () {
        final ref = database.ref('/');
        final snapshot = FakeDataSnapshot(ref, null);

        expect(snapshot.key, null);
      });

      test('returns non-null if at a non-root path', () {
        final ref = database.ref('users/123');
        final snapshot = FakeDataSnapshot(ref, null);

        expect(snapshot.key, '123');
      });
    });

    group('get ref', () {
      test('returns the correct DatabaseReference', () {
        final ref = database.ref('users/123');
        final snapshot = FakeDataSnapshot(ref, null);

        expect(snapshot.ref, ref);
      });
    });
  });
}
