import 'package:flutter_test/flutter_test.dart';

import 'package:fake_firebase_database/fake_firebase_database.dart';

void main() {
  final database = FakeFirebaseDatabase.instance;

  setUp(() async {
    final ref = database.ref();
    await ref.set(null);
  });

  group('FakeQuery', () {
    group('get path', () {
      test('returns the correct path value', () async {
        final ref1 = database.ref();
        final ref2 = database.ref('');
        final ref3 = database.ref('/');
        final ref4 = database.ref('/users');
        final ref5 = database.ref('/users/123');

        expect(ref1.path, '/');
        expect(ref2.path, '/');
        expect(ref3.path, '/');
        expect(ref4.path, '/users');
        expect(ref5.path, '/users/123');
      });
    });

    group('orderByChild()', () {
      setUp(() async {
        final usersRef = database.ref('users');
        await usersRef.set({
          '1': {'name': 'Alice', 'age': 25},
          '2': {'name': 'Bob', 'age': 35 as dynamic}, // Mimic a model property
          '3': {'name': 'Charlie', 'age': 30},
        });
      });

      test('returns a list ordered by specified child`', () async {
        final query = database.ref('users').orderByChild('age');
        final snapshot = await query.get();
        final children = snapshot.children.toList();

        expect(children.length, 3);
        expect(children[0].child('name').value, 'Alice');
        expect(children[1].child('name').value, 'Charlie');
        expect(children[2].child('name').value, 'Bob');
      });

      test('works correctly for `null` values', () async {
        await database.ref('users/2').update({'age': null});

        final query = database.ref('users').orderByChild('age');
        final snapshot = await query.get();
        final children = snapshot.children.toList();

        expect(children.length, 3);
        expect(children[0].child('name').value, 'Bob');
        expect(children[1].child('name').value, 'Alice');
        expect(children[2].child('name').value, 'Charlie');
      });
    });
  });
}
