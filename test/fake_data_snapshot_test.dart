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

    group('children', () {
      test('returns empty iterable for null value', () {
        final ref = database.ref('users');
        final snapshot = FakeDataSnapshot(ref, null);

        expect(snapshot.children, isEmpty);
      });

      test('returns empty iterable for non-map value', () {
        final ref = database.ref('users/123/name');
        final snapshot = FakeDataSnapshot(ref, 'John');

        expect(snapshot.children, isEmpty);
      });

      test('returns correct children for map value', () {
        final ref = database.ref('users');
        final value = {
          'user1': {'name': 'John', 'age': 30},
          'user2': {'name': 'Jane', 'age': 25},
        };
        final snapshot = FakeDataSnapshot(ref, value);

        final children = snapshot.children.toList();
        expect(children.length, 2);

        expect(children[0].key, 'user1');
        expect(children[0].value, {'name': 'John', 'age': 30});
        expect(children[0].ref.path, '/users/user1');

        expect(children[1].key, 'user2');
        expect(children[1].value, {'name': 'Jane', 'age': 25});
        expect(children[1].ref.path, '/users/user2');
      });

      test('returns correct children for nested map value', () {
        final ref = database.ref('users/user1');
        final value = {
          'name': 'John',
          'address': {
            'city': 'New York',
            'country': 'USA',
          },
        };
        final snapshot = FakeDataSnapshot(ref, value);

        final children = snapshot.children.toList();
        expect(children.length, 2);

        expect(children[0].key, 'name');
        expect(children[0].value, 'John');
        expect(children[0].ref.path, '/users/user1/name');

        expect(children[1].key, 'address');
        expect(children[1].value, {'city': 'New York', 'country': 'USA'});
        expect(children[1].ref.path, '/users/user1/address');
      });

      test('returns empty iterable for empty map', () {
        final ref = database.ref('users');
        final snapshot = FakeDataSnapshot(ref, {});

        expect(snapshot.children, isEmpty);
      });
    });

    group('hasChild()', () {
      test('returns true for existing child', () {
        final ref = database.ref('users');
        final value = {
          'user1': {'name': 'John', 'age': 30},
          'user2': {'name': 'Jane', 'age': 25},
        };
        final snapshot = FakeDataSnapshot(ref, value);

        expect(snapshot.hasChild('user1'), isTrue);
        expect(snapshot.hasChild('user2'), isTrue);
      });

      test('returns false for non-existing child', () {
        final ref = database.ref('users');
        final value = {
          'user1': {'name': 'John', 'age': 30},
          'user2': {'name': 'Jane', 'age': 25},
        };
        final snapshot = FakeDataSnapshot(ref, value);

        expect(snapshot.hasChild('user3'), isFalse);
      });

      test('returns true for existing nested child', () {
        final ref = database.ref('users');
        final value = {
          'user1': {
            'name': 'John',
            'address': {'city': 'New York'}
          },
        };
        final snapshot = FakeDataSnapshot(ref, value);

        expect(snapshot.hasChild('user1/address/city'), isTrue);
      });

      test('returns false for non-existing nested child', () {
        final ref = database.ref('users');
        final value = {
          'user1': {
            'name': 'John',
            'address': {'city': 'New York'}
          },
        };
        final snapshot = FakeDataSnapshot(ref, value);

        expect(snapshot.hasChild('user1/address/country'), isFalse);
      });

      test('returns false for child of primitive value', () {
        final ref = database.ref('users/user1/name');
        final snapshot = FakeDataSnapshot(ref, 'John');

        expect(snapshot.hasChild('firstname'), isFalse);
      });

      test('returns false for child of null value', () {
        final ref = database.ref('users/user1');
        final snapshot = FakeDataSnapshot(ref, null);

        expect(snapshot.hasChild('name'), isFalse);
      });
    });
  });
}
