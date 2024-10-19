import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fake_firebase_database/fake_firebase_database.dart';

void main() {
  final database = FakeFirebaseDatabase.instance;

  tearDown(() async {
    await database.ref().set(null);
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

      test('returns a list ordered by a deeply nested child', () async {
        await database.ref('scores').set({
          'player1': {
            'info': {'score': 100},
          },
          'player2': {
            'info': {'score': 50},
          },
          'player3': {
            'info': {'score': 150},
          },
        });

        final query = database.ref('scores').orderByChild('info/score');
        final snapshot = await query.get();
        final children = snapshot.children.toList();

        expect(children.length, 3);
        expect(children[0].child('info/score').value, 50);
        expect(children[1].child('info/score').value, 100);
        expect(children[2].child('info/score').value, 150);
      });
    });

    group('orderByKey()', () {
      setUp(() async {
        final usersRef = database.ref('users');
        await usersRef.set({
          'c': {'name': 'Charlie'},
          'a': {'name': 'Alice'},
          'b': {'name': 'Bob'},
        });
      });

      test('returns a list ordered by key', () async {
        final query = database.ref('users').orderByKey();
        final snapshot = await query.get();
        final children = snapshot.children.toList();

        expect(children.length, 3);
        expect(children[0].key, 'a');
        expect(children[1].key, 'b');
        expect(children[2].key, 'c');
      });
    });

    group('orderByValue()', () {
      test('returns a list ordered by value', () async {
        await database.ref('scores').set({
          'player1': 100,
          'player2': 50,
          'player3': 150,
        });

        final query = database.ref('scores').orderByValue();
        final snapshot = await query.get();
        final children = snapshot.children.toList();

        expect(children.length, 3);
        expect(children[0].key, 'player2');
        expect(children[0].value, 50);
        expect(children[1].key, 'player1');
        expect(children[1].value, 100);
        expect(children[2].key, 'player3');
        expect(children[2].value, 150);
      });

      test('works correctly for mixed value types', () async {
        await database.ref('scores').set({
          'player1': null,
          'player2': true,
          'player3': 'high',
          'player4': 100,
        });

        final query = database.ref('scores').orderByValue();
        final snapshot = await query.get();
        final children = snapshot.children.toList();

        expect(children.length, 3);
        expect(children[0].key, 'player4');
        expect(children[0].value, 100);
        expect(children[1].key, 'player3');
        expect(children[1].value, 'high');
        expect(children[2].key, 'player2');
        expect(children[2].value, true);
      });
    });

    group('startAt()', () {
      setUp(() async {
        final usersRef = database.ref('users');
        await usersRef.set({
          '1': {'name': 'Alice', 'age': 25},
          '2': {'name': 'Bob', 'age': 30},
          '3': {'name': 'Charlie', 'age': 35},
          '4': {'name': 'David', 'age': 40},
          '5': {'name': 'Eve', 'age': 45},
        });
      });

      test('works with orderByChild()', () async {
        final query = database.ref('users').orderByChild('age').startAt(35);
        final snapshot = await query.get();
        final children = snapshot.children.toList();

        expect(children.length, 3);
        expect(children[0].child('name').value, 'Charlie');
        expect(children[1].child('name').value, 'David');
        expect(children[2].child('name').value, 'Eve');
      });

      test('works with orderByChild() with deep path', () async {
        await database.ref('scores').set({
          'player1': {
            'info': {'score': 100},
          },
          'player2': {
            'info': {'score': 50},
          },
          'player3': {
            'info': {'score': 150},
          },
        });

        final query =
            database.ref('scores').orderByChild('info/score').startAt(100);
        final snapshot = await query.get();
        final children = snapshot.children.toList();

        expect(children.length, 2);
        expect(children[0].child('info/score').value, 100);
        expect(children[1].child('info/score').value, 150);
      });

      test('works with orderByKey()', () async {
        final query = database.ref('users').orderByKey().startAt('3');
        final snapshot = await query.get();
        final children = snapshot.children.toList();

        expect(children.length, 3);
        expect(children[0].key, '3');
        expect(children[1].key, '4');
        expect(children[2].key, '5');
      });

      test('works with orderByValue()', () async {
        await database.ref('scores').set({
          'player1': 50,
          'player2': 100,
          'player3': 150,
          'player4': 200,
        });

        final query = database.ref('scores').orderByValue().startAt(150);
        final snapshot = await query.get();
        final children = snapshot.children.toList();

        expect(children.length, 2);
        expect(children[0].key, 'player3');
        expect(children[0].value, 150);
        expect(children[1].key, 'player4');
        expect(children[1].value, 200);
      });

      test('works with startAt(value, key)', () async {
        final query =
            database.ref('users').orderByChild('age').startAt(35, key: '4');
        final snapshot = await query.get();
        final children = snapshot.children.toList();

        expect(children.length, 2);
        expect(children[0].child('name').value, 'David');
        expect(children[1].child('name').value, 'Eve');
      });

      test('returns empty result if no matching data', () async {
        final query = database.ref('users').orderByChild('age').startAt(50);
        final snapshot = await query.get();
        final children = snapshot.children.toList();

        expect(children.length, 0);
      });
    });

    group('startAfter()', () {
      setUp(() async {
        final usersRef = database.ref('users');
        await usersRef.set({
          '1': {'name': 'Alice', 'age': 25},
          '2': {'name': 'Bob', 'age': 30},
          '3': {'name': 'Charlie', 'age': 35},
          '4': {'name': 'David', 'age': 40},
          '5': {'name': 'Eve', 'age': 45},
        });
      });

      test('works with orderByChild()', () async {
        final query = database.ref('users').orderByChild('age').startAfter(35);
        final snapshot = await query.get();
        final children = snapshot.children.toList();

        expect(children.length, 2);
        expect(children[0].child('name').value, 'David');
        expect(children[1].child('name').value, 'Eve');
      });

      test('works with orderByChild() with deep path', () async {
        await database.ref('scores').set({
          'player1': {
            'info': {'score': 100},
          },
          'player2': {
            'info': {'score': 50},
          },
          'player3': {
            'info': {'score': 150},
          },
        });

        final query =
            database.ref('scores').orderByChild('info/score').startAfter(100);
        final snapshot = await query.get();
        final children = snapshot.children.toList();

        expect(children.length, 1);
        expect(children[0].child('info/score').value, 150);
      });

      test('works with orderByKey()', () async {
        final query = database.ref('users').orderByKey().startAfter('3');
        final snapshot = await query.get();
        final children = snapshot.children.toList();

        expect(children.length, 2);
        expect(children[0].key, '4');
        expect(children[1].key, '5');
      });

      test('works with orderByValue()', () async {
        await database.ref('scores').set({
          'player1': 50,
          'player2': 100,
          'player3': 150,
          'player4': 200,
        });

        final query = database.ref('scores').orderByValue().startAfter(150);
        final snapshot = await query.get();
        final children = snapshot.children.toList();

        expect(children.length, 1);
        expect(children[0].key, 'player4');
        expect(children[0].value, 200);
      });

      test('works with startAfter(value, key)', () async {
        final query =
            database.ref('users').orderByChild('age').startAfter(35, key: '3');
        final snapshot = await query.get();
        final children = snapshot.children.toList();

        expect(children.length, 2);
        expect(children[0].child('name').value, 'David');
        expect(children[1].child('name').value, 'Eve');
      });

      test('returns empty result if no matching data', () async {
        final query = database.ref('users').orderByChild('age').startAfter(50);
        final snapshot = await query.get();
        final children = snapshot.children.toList();

        expect(children.length, 0);
      });
    });

    group('endAt()', () {
      setUp(() async {
        final usersRef = database.ref('users');
        await usersRef.set({
          '1': {'name': 'Alice', 'age': 45},
          '2': {'name': 'Bob', 'age': 40},
          '3': {'name': 'Charlie', 'age': 35},
          '4': {'name': 'David', 'age': 30},
          '5': {'name': 'Eve', 'age': 25},
        });
      });

      test('works with orderByChild()', () async {
        final query = database.ref('users').orderByChild('age').endAt(35);
        final snapshot = await query.get();
        final children = snapshot.children.toList();

        expect(children.length, 3);
        expect(children[0].child('name').value, 'Eve');
        expect(children[1].child('name').value, 'David');
        expect(children[2].child('name').value, 'Charlie');
      });

      test('works with orderByKey()', () async {
        final query = database.ref('users').orderByKey().endAt('3');
        final snapshot = await query.get();
        final children = snapshot.children.toList();

        expect(children.length, 3);
        expect(children[0].key, '1');
        expect(children[1].key, '2');
        expect(children[2].key, '3');
      });

      test('works with orderByValue()', () async {
        await database.ref('scores').set({
          'player1': 100,
          'player2': 50,
          'player3': 150,
          'player4': 75,
        });

        final query = database.ref('scores').orderByValue().endAt(100);
        final snapshot = await query.get();
        final children = snapshot.children.toList();

        expect(children.length, 3);
        expect(children[0].key, 'player2');
        expect(children[0].value, 50);
        expect(children[1].key, 'player4');
        expect(children[1].value, 75);
        expect(children[2].key, 'player1');
        expect(children[2].value, 100);
      });

      test('works with endAt(value, key)', () async {
        final query =
            database.ref('users').orderByChild('age').endAt(40, key: '2');
        final snapshot = await query.get();
        final children = snapshot.children.toList();

        expect(children.length, 1);
        expect(children[0].child('name').value, 'Bob');
      });

      test('returns all results if no matching data', () async {
        final query = database.ref('users').orderByChild('age').endAt(50);
        final snapshot = await query.get();
        final children = snapshot.children.toList();

        expect(children.length, 5);
      });

      test('works with deep nested paths', () async {
        await database.ref('nested').set({
          'a': {
            'info': {'score': 100}
          },
          'b': {
            'info': {'score': 50}
          },
          'c': {
            'info': {'score': 75}
          },
        });

        final query =
            database.ref('nested').orderByChild('info/score').endAt(75);
        final snapshot = await query.get();
        final children = snapshot.children.toList();

        expect(children.length, 2);
        expect(children[0].key, 'b');
        expect(children[1].key, 'c');
      });
    });

    group('endBefore()', () {
      setUp(() async {
        final usersRef = database.ref('users');
        await usersRef.set({
          '1': {'name': 'Alice', 'age': 45},
          '2': {'name': 'Bob', 'age': 40},
          '3': {'name': 'Charlie', 'age': 35},
          '4': {'name': 'David', 'age': 30},
          '5': {'name': 'Eve', 'age': 25},
        });
      });

      test('works with orderByChild()', () async {
        final query = database.ref('users').orderByChild('age').endBefore(35);
        final snapshot = await query.get();
        final children = snapshot.children.toList();

        expect(children.length, 2);
        expect(children[0].child('name').value, 'Eve');
        expect(children[1].child('name').value, 'David');
      });

      test('works with orderByKey()', () async {
        final query = database.ref('users').orderByKey().endBefore('3');
        final snapshot = await query.get();
        final children = snapshot.children.toList();

        expect(children.length, 2);
        expect(children[0].key, '1');
        expect(children[1].key, '2');
      });

      test('works with orderByValue()', () async {
        await database.ref('scores').set({
          'player1': 100,
          'player2': 50,
          'player3': 150,
          'player4': 75,
        });

        final query = database.ref('scores').orderByValue().endBefore(100);
        final snapshot = await query.get();
        final children = snapshot.children.toList();

        expect(children.length, 2);
        expect(children[0].key, 'player2');
        expect(children[0].value, 50);
        expect(children[1].key, 'player4');
        expect(children[1].value, 75);
      });

      test('works with endBefore(value, key)', () async {
        final query =
            database.ref('users').orderByChild('age').endBefore(35, key: '4');
        final snapshot = await query.get();
        final children = snapshot.children.toList();

        expect(children.length, 1);
        expect(children[0].child('name').value, 'Charlie');
      });

      test('returns empty result if no matching data', () async {
        final query = database.ref('users').orderByChild('age').endBefore(20);
        final snapshot = await query.get();
        final children = snapshot.children.toList();

        expect(children.length, 0);
      });

      test('works with deep nested paths', () async {
        await database.ref('nested').set({
          'a': {
            'info': {'score': 100}
          },
          'b': {
            'info': {'score': 50}
          },
          'c': {
            'info': {'score': 75}
          },
        });

        final query =
            database.ref('nested').orderByChild('info/score').endBefore(75);
        final snapshot = await query.get();
        final children = snapshot.children.toList();

        expect(children.length, 1);
        expect(children[0].key, 'b');
      });
    });

    group('equalTo()', () {
      setUp(() async {
        final usersRef = database.ref('users');
        await usersRef.set({
          '1': {'name': 'Alice', 'age': 30},
          '2': {'name': 'Bob', 'age': 35},
          '3': {'name': 'Charlie', 'age': 30},
          '4': {'name': 'David', 'age': 35},
          '5': {'name': 'Eve', 'age': 40},
        });
      });

      test('works with orderByChild()', () async {
        final query = database.ref('users').orderByChild('age').equalTo(30);
        final snapshot = await query.get();
        final children = snapshot.children.toList();

        expect(children.length, 2);
        expect(children[0].child('name').value, 'Alice');
        expect(children[1].child('name').value, 'Charlie');
      });

      test('works with orderByKey()', () async {
        final query = database.ref('users').orderByKey().equalTo('3');
        final snapshot = await query.get();
        final children = snapshot.children.toList();

        expect(children.length, 1);
        expect(children[0].child('name').value, 'Charlie');
      });

      test('works with orderByValue()', () async {
        await database.ref('scores').set({
          'player1': 100,
          'player2': 50,
          'player3': 100,
          'player4': 75,
        });

        final query = database.ref('scores').orderByValue().equalTo(100);
        final snapshot = await query.get();
        final children = snapshot.children.toList();

        expect(children.length, 2);
        expect(children[0].key, 'player1');
        expect(children[1].key, 'player3');
      });

      test('works with equalTo(value, key)', () async {
        final query =
            database.ref('users').orderByChild('age').equalTo(35, key: '2');
        final snapshot = await query.get();
        final children = snapshot.children.toList();

        expect(children.length, 1);
        expect(children[0].child('name').value, 'Bob');
      });

      test('returns at most one entry when `key` exists', () async {
        final query =
            database.ref('users').orderByChild('age').equalTo(30, key: '3');
        final snapshot = await query.get();
        final children = snapshot.children.toList();

        expect(children.length, 1);
        expect(children[0].child('name').value, 'Charlie');
      });

      test('returns empty result if no matching data', () async {
        final query = database.ref('users').orderByChild('age').equalTo(50);
        final snapshot = await query.get();
        final children = snapshot.children.toList();

        expect(children.length, 0);
      });

      test('works with deep nested paths', () async {
        await database.ref('nested').set({
          'a': {
            'info': {'score': 100}
          },
          'b': {
            'info': {'score': 50}
          },
          'c': {
            'info': {'score': 100}
          },
        });

        final query =
            database.ref('nested').orderByChild('info/score').equalTo(100);
        final snapshot = await query.get();
        final children = snapshot.children.toList();

        expect(children.length, 2);
        expect(children[0].key, 'a');
        expect(children[1].key, 'c');
      });
    });

    group('limitToFirst()', () {
      setUp(() async {
        final usersRef = database.ref('users');
        await usersRef.set({
          '1': {'name': 'Alice', 'age': 45},
          '4': {'name': 'Bob', 'age': 40},
          '3': {'name': 'Charlie', 'age': 35},
          '2': {'name': 'David', 'age': 30},
          '5': {'name': 'Eve', 'age': 25},
        });
      });

      test('limits the number of results', () async {
        final query = database.ref('users').limitToFirst(3);
        final snapshot = await query.get();
        final children = snapshot.children.toList();

        expect(children.length, 3);
        expect(children[0].child('name').value, 'Alice');
        expect(children[1].child('name').value, 'Bob');
        expect(children[2].child('name').value, 'Charlie');
      });

      test('works with orderByChild()', () async {
        final query = database.ref('users').orderByChild('age').limitToFirst(3);
        final snapshot = await query.get();
        final children = snapshot.children.toList();

        expect(children.length, 3);
        expect(children[0].child('name').value, 'Eve');
        expect(children[1].child('name').value, 'David');
        expect(children[2].child('name').value, 'Charlie');
      });

      test('works with orderByKey()', () async {
        final query = database.ref('users').orderByKey().limitToFirst(2);
        final snapshot = await query.get();
        final children = snapshot.children.toList();

        expect(children.length, 2);
        expect(children[0].key, '1');
        expect(children[1].key, '2');
      });

      test('works with orderByValue()', () async {
        await database.ref('scores').set({
          'player1': 100,
          'player2': 50,
          'player3': 150,
          'player4': 75,
        });

        final query = database.ref('scores').orderByValue().limitToFirst(2);
        final snapshot = await query.get();
        final children = snapshot.children.toList();

        expect(children.length, 2);
        expect(children[0].key, 'player2');
        expect(children[0].value, 50);
        expect(children[1].key, 'player4');
        expect(children[1].value, 75);
      });

      test('returns all results if limit is greater than total count',
          () async {
        final query = database.ref('users').limitToFirst(10);
        final snapshot = await query.get();
        final children = snapshot.children.toList();

        expect(children.length, 5);
      });
    });

    group('limitToLast()', () {
      setUp(() async {
        final usersRef = database.ref('users');
        await usersRef.set({
          '1': {'name': 'Alice', 'age': 45},
          '4': {'name': 'Bob', 'age': 40},
          '3': {'name': 'Charlie', 'age': 35},
          '2': {'name': 'David', 'age': 30},
          '5': {'name': 'Eve', 'age': 25},
        });
      });

      test('limits the number of results', () async {
        final query = database.ref('users').limitToLast(3);
        final snapshot = await query.get();
        final children = snapshot.children.toList();

        expect(children.length, 3);
        expect(children[0].child('name').value, 'Charlie');
        expect(children[1].child('name').value, 'David');
        expect(children[2].child('name').value, 'Eve');
      });

      test('works with orderByChild()', () async {
        final query = database.ref('users').orderByChild('age').limitToLast(3);
        final snapshot = await query.get();
        final children = snapshot.children.toList();

        expect(children.length, 3);
        expect(children[0].child('name').value, 'Charlie');
        expect(children[1].child('name').value, 'Bob');
        expect(children[2].child('name').value, 'Alice');
      });

      test('works with orderByKey()', () async {
        final query = database.ref('users').orderByKey().limitToLast(2);
        final snapshot = await query.get();
        final children = snapshot.children.toList();

        expect(children.length, 2);
        expect(children[0].key, '4');
        expect(children[1].key, '5');
      });

      test('works with orderByValue()', () async {
        await database.ref('scores').set({
          'player1': 100,
          'player2': 50,
          'player3': 150,
          'player4': 75,
        });

        final query = database.ref('scores').orderByValue().limitToLast(2);
        final snapshot = await query.get();
        final children = snapshot.children.toList();

        expect(children.length, 2);
        expect(children[0].key, 'player1');
        expect(children[0].value, 100);
        expect(children[1].key, 'player3');
        expect(children[1].value, 150);
      });

      test('returns all results if limit is greater than total count',
          () async {
        final query = database.ref('users').limitToLast(10);
        final snapshot = await query.get();
        final children = snapshot.children.toList();

        expect(children.length, 5);
      });
    });

    group('Real-time event streams', () {
      test('onValue emits events when data changes', () async {
        final ref = database.ref('users');

        expectLater(
          ref.onValue,
          emitsInOrder([
            predicate<DatabaseEvent>(
                (e) => (e.snapshot.value as Map).length == 1),
            predicate<DatabaseEvent>(
                (e) => (e.snapshot.value as Map).length == 2),
          ]),
        );

        await ref.set({'name1': 'Alice'});
        await ref.set({'name1': 'Alice', 'name2': 'Bob'});
      });

      test('onChildAdded emits events when children are added', () async {
        final ref = database.ref('users');

        expectLater(
          ref.onChildAdded,
          emitsInOrder([
            predicate<DatabaseEvent>((e) => e.snapshot.key == 'user1'),
            predicate<DatabaseEvent>((e) => e.snapshot.key == 'user2'),
          ]),
        );

        await ref.update({
          'user1': {'name': 'Alice'}
        });

        await ref.update({
          'user2': {'name': 'Bob'}
        });
      });
    });
  });
}
