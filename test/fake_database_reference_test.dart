import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fake_firebase_database/fake_firebase_database.dart';

void main() {
  final database = FakeFirebaseDatabase.instance;

  tearDown(() {
    database.clear();
  });

  group('FakeDatabaseReference', () {
    group('CRUD operations', () {
      test('can set() and get() a simple map at root path', () async {
        final ref = database.ref();
        final value = {'name': 'John', 'age': 18};

        await ref.set(value);

        final snapshot = await ref.get();
        expect(snapshot.value, value);
      });

      test('can set() and get() a complex map at root path', () async {
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

      test('A map key should be of type String', () async {
        final ref = database.ref();
        final value = {18: 'age'};

        final future = ref.set(value);

        await expectLater(future, throwsA(isA<TypeError>()));
      });

      test('can get() the value from a shallow path', () async {
        final ref1 = database.ref();
        final addresses = {'line1': '100 Mountain View'};
        final john = {'addresses': addresses};
        final value = {'John': john};

        await ref1.set(value);

        final ref2 = database.ref('/John');
        final snapshot = await ref2.get();
        expect(snapshot.value, john);
      });

      test('can get() the value from a deep path', () async {
        final ref1 = database.ref();
        final addresses = {'line1': '100 Mountain View'};
        final john = {'addresses': addresses};
        final value = {'John': john};

        await ref1.set(value);

        final ref2 = database.ref('/John/addresses');
        final snapshot = await ref2.get();
        expect(snapshot.value, addresses);
      });

      test('can set() a map at a non-root path', () async {
        final ref = database.ref('users/123');
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

      test('can set() a non-map at a non-root path', () async {
        final ref = database.ref('users/123');
        const value = 'John';

        await ref.set(value);

        final snapshot = await ref.get();
        expect(snapshot.value, value);
      });

      test('can update() data at the root path', () async {
        final ref = database.ref();

        await ref.set({'name': 'John', 'age': 18});
        await ref.update({'age': 19, 'city': 'Mountain View'});

        final snapshot = await ref.get();
        expect(snapshot.value, {
          'name': 'John',
          'age': 19,
          'city': 'Mountain View',
        });
      });

      test('can update() data at a non-root path', () async {
        final ref = database.ref('users/123');

        await ref.set({'name': 'John', 'age': 18});
        await ref.update({'age': 19, 'city': 'Mountain View'});

        final snapshot = await ref.get();
        expect(snapshot.value, {
          'name': 'John',
          'age': 19,
          'city': 'Mountain View',
        });
      });

      test('update() accepts a sub-path to nodes', () async {
        final ref1 = database.ref('users/123');

        await ref1.set({
          'name': 'John',
          'age': 18,
          'address': {
            'line1': '100 Mountain View',
          },
        });

        final ref2 = database.ref('users');

        await ref2.update({
          '123/age': 19,
          '123/address/line1': '1 Mountain View',
        });

        final snapshot = await ref1.get();
        expect(snapshot.value, {
          'name': 'John',
          'age': 19,
          'address': {
            'line1': '1 Mountain View',
          },
        });
      });

      test('can remove() data at the root path', () async {
        final ref = database.ref();

        await ref.set({'name': 'John', 'age': 18});
        await ref.remove();

        final snapshot = await ref.get();
        expect(snapshot.value, null);
      });

      test('can remove() data at a non-root path', () async {
        final ref = database.ref('users/123');

        await ref.set({'name': 'John', 'age': 18});
        await ref.remove();

        final snapshot = await ref.get();
        expect(snapshot.value, null);
      });
    });

    group('clean up `null` and empty entries', () {
      test('clean up `null` entries upward', () async {
        final ref1 = database.ref('users/123');

        await ref1.set(null);

        final ref2 = database.ref();
        final snapshot2 = await ref2.get();
        expect(snapshot2.value, null);
      });

      test('clean up empty map entries upward', () async {
        final ref1 = database.ref('users/123');

        await ref1.set({});

        final ref2 = database.ref();
        final snapshot2 = await ref2.get();
        expect(snapshot2.value, null);
      });

      test('clean up empty list entries upward', () async {
        final ref1 = database.ref('users/123');

        await ref1.set([]);

        final ref2 = database.ref();
        final snapshot2 = await ref2.get();
        expect(snapshot2.value, null);
      });

      test('clean up `null` entries downward', () async {
        final ref1 = database.ref('users/123');

        await ref1.set({
          'John': {'addresses': null}
        });

        final ref2 = database.ref();
        final snapshot2 = await ref2.get();
        expect(snapshot2.value, null);
      });

      test('clean up empty map entries downward', () async {
        final ref1 = database.ref('users/123');

        await ref1.set({
          'John': {'addresses': {}}
        });

        final ref2 = database.ref();
        final snapshot2 = await ref2.get();
        expect(snapshot2.value, null);
      });

      test('clean up empty list entries downward', () async {
        final ref1 = database.ref('users/123');

        await ref1.set({
          'John': {'addresses': []}
        });

        final ref2 = database.ref();
        final snapshot2 = await ref2.get();
        expect(snapshot2.value, null);
      });

      test('clean up `null` or empty entries when updating', () async {
        final ref1 = database.ref('users/123');

        await ref1.set({'age': 18 as dynamic}); // Mimic a model property
        await ref1.update({'age': null});

        final ref2 = database.ref();
        final snapshot2 = await ref2.get();
        expect(snapshot2.value, null);
      });
    });

    group('path argument', () {
      test('can save a path with extra slashes', () async {
        final ref1 = database.ref('//');
        final ref2 = database.ref('//users//');
        final ref3 = database.ref('//users//123//');

        expect(ref1.path, '/');
        expect(ref2.path, '/users');
        expect(ref3.path, '/users/123');
      });

      test('can use a path with extra slashes', () async {
        final value = {'name': 'John', 'age': 18};
        final ref1 = database.ref('//');

        await ref1.set(value);

        final ref2 = database.ref('');
        final snapshot2 = await ref2.get();

        expect(snapshot2.value, value);
      });

      test('can use a path with more extra slashes', () async {
        final value = {'name': 'John', 'age': 18};
        final ref1 = database.ref('//users//');

        await ref1.set(value);

        final ref2 = database.ref('users');
        final snapshot2 = await ref2.get();

        expect(snapshot2.value, value);
      });

      test('can use a path with even more extra slashes', () async {
        final value = {'name': 'John', 'age': 18};
        final ref1 = database.ref('//users//123//');

        await ref1.set(value);

        final ref2 = database.ref('users/123');
        final snapshot2 = await ref2.get();

        expect(snapshot2.value, value);
      });
    });

    group('get key', () {
      test('returns the last part of the path', () async {
        final ref1 = database.ref();
        final ref2 = database.ref('');
        final ref3 = database.ref('/');
        final ref4 = database.ref('/users');
        final ref5 = database.ref('/users/123');

        expect(ref1.key, null);
        expect(ref2.key, null);
        expect(ref3.key, null);
        expect(ref4.key, 'users');
        expect(ref5.key, '123');
      });
    });

    group('push()', () {
      test('`push()` returns a push ID', () async {
        final ref = database.ref('users').push();

        expect(ref.key?.length, 20);
        expect(ref.path, startsWith('/users/-'));
      });
    });

    group('child()', () {
      test('from the root ref', () async {
        final ref1 = database.ref().child('');
        final ref2 = database.ref().child('users');
        final ref3 = database.ref().child('/users');
        final ref4 = database.ref().child('users/123');
        final ref5 = database.ref().child('//users//123//');

        expect(ref1.path, '/');
        expect(ref2.path, '/users');
        expect(ref3.path, '/users');
        expect(ref4.path, '/users/123');
        expect(ref5.path, '/users/123');
      });

      test('from a non-root ref', () async {
        final ref1 = database.ref('users/123').child('');
        final ref2 = database.ref('users/123').child('addresses');
        final ref3 = database.ref('users/123').child('/addresses');
        final ref4 = database.ref('users/123').child('//addresses//');

        expect(ref1.path, '/users/123');
        expect(ref2.path, '/users/123/addresses');
        expect(ref3.path, '/users/123/addresses');
        expect(ref4.path, '/users/123/addresses');
      });
    });

    group('get parent', () {
      test('from the root ref', () async {
        final ref1 = database.ref('/').parent;
        final ref2 = database.ref('/users').parent?.parent;

        expect(ref1?.path, null);
        expect(ref2?.path, null);
      });

      test('from a non-root ref', () async {
        final ref1 = database.ref('/users').parent;
        final ref2 = database.ref('/users/123').parent;

        expect(ref1?.path, '/');
        expect(ref2?.path, '/users');
      });
    });

    group('get root', () {
      test('returns a root reference', () async {
        final ref1 = database.ref('/users/123');
        final ref2 = ref1.root;

        expect(ref2.path, '/');
      });
    });

    group('runTransaction()', () {
      test('can update data', () async {
        final ref = database.ref('counter');
        await ref.set(5);

        final result = await ref.runTransaction((value) {
          final newValue = (value as int) + 1;
          return Transaction.success(newValue);
        });

        expect(result.committed, true);
        expect(result.snapshot.value, 6);
      });

      test('can abort transaction', () async {
        final ref = database.ref('counter');
        await ref.set(5);

        final result = await ref.runTransaction((value) {
          return Transaction.abort();
        });

        expect(result.committed, false);
        expect(result.snapshot.value, 5);
      });

      test('transaction fails when handler throws', () async {
        final ref = database.ref('counter');
        await ref.set(5);

        final result = await ref.runTransaction((value) {
          throw Exception('Simulated error');
        });

        expect(result.committed, false);
        expect(result.snapshot.value, 5);
      });

      test('can handle complex data in transaction', () async {
        final ref = database.ref('user');
        await ref.set({
          'name': 'John',
          'score': 100,
        });

        final result = await ref.runTransaction((value) {
          value = value as Map;

          final newValue = {
            ...value,
            'score': (value['score'] as int) + 50,
          };

          return Transaction.success(newValue);
        });

        expect(result.committed, true);
        expect(result.snapshot.value, {
          'name': 'John',
          'score': 150,
        });
      });

      test('transaction sees the initial data correctly', () async {
        final ref = database.ref('data');
        await ref.set({'count': 1});

        final result = await ref.runTransaction((value) {
          expect(value, {'count': 1});
          return Transaction.success({'count': 2});
        });

        expect(result.committed, true);
        expect(result.snapshot.value, {'count': 2});
      });

      test('has updated value after successful transaction', () async {
        final ref = database.ref('data');
        await ref.set({'count': 1});

        await ref.runTransaction((value) {
          expect(value, {'count': 1});
          return Transaction.success({'count': 2});
        });

        final snapshot = await ref.get();
        expect(snapshot.value, {'count': 2});
      });
    });

    group('priority-related', () {
      test('can set priority', () async {
        final ref = database.ref('users/user1');
        await ref.set(<String, dynamic>{'name': 'Alice'});
        await ref.setPriority(100);

        final snapshot = await ref.get();
        expect(snapshot.priority, 100);
      });

      test('can set with priority', () async {
        final ref = database.ref('users/user1');
        await ref.setWithPriority(<String, dynamic>{'name': 'Alice'}, 100);

        final snapshot = await ref.get();
        expect(snapshot.priority, 100);
      });

      test('can order by priority', () async {
        final ref = database.ref('users');
        await ref.set({
          'user1': <String, dynamic>{'name': 'Alice', '.priority': 100},
          'user2': <String, dynamic>{'name': 'Bob', '.priority': 50},
          'user3': <String, dynamic>{'name': 'Charlie', '.priority': 150},
        });

        final query = ref.orderByPriority();
        final snapshot = await query.get();
        final children = snapshot.children.toList();

        expect(children.length, 3);
        expect(children[0].child('name').value, 'Bob');
        expect(children[1].child('name').value, 'Alice');
        expect(children[2].child('name').value, 'Charlie');
      });

      test('can set priority in different ways', () async {
        final ref1 = database.ref('users');
        await ref1.set({
          'user1': <String, dynamic>{'name': 'Alice', '.priority': 100},
        });

        final ref2 = ref1.child('user2');
        ref2.set(
          <String, dynamic>{'name': 'Bob'},
        );
        ref2.setPriority(50);

        final ref3 = ref1.child('user3');
        ref3.setWithPriority(<String, dynamic>{'name': 'Charlie'}, 150);

        final query = ref1.orderByPriority();
        final snapshot = await query.get();
        final children = snapshot.children.toList();

        expect(children.length, 3);
        expect(children[0].child('name').value, 'Bob');
        expect(children[1].child('name').value, 'Alice');
        expect(children[2].child('name').value, 'Charlie');
      });

      test('setPriority() throws on invalid priority type', () async {
        final ref = database.ref('test');
        expect(() => ref.setPriority(true), throwsAssertionError);
        expect(() => ref.setPriority([]), throwsAssertionError);
        expect(() => ref.setPriority({}), throwsAssertionError);
      });

      test('setWithPriority() throws on invalid priority type', () async {
        final ref = database.ref('test');
        final value = {'key': 'value'};
        expect(() => ref.setWithPriority(value, true), throwsAssertionError);
        expect(() => ref.setWithPriority(value, []), throwsAssertionError);
        expect(() => ref.setWithPriority(value, {}), throwsAssertionError);
      });
    });

    group('list handling', () {
      test('converts List to Map when setting', () async {
        final ref = database.ref('items');
        await ref.set(['a', 'b', 'c']);

        final snapshot = await ref.get();
        expect(snapshot.value, {'0': 'a', '1': 'b', '2': 'c'});
      });

      test('handles nested Lists', () async {
        final ref = database.ref('items');
        await ref.set({
          'nested': [
            'a',
            'b',
            ['c', 'd']
          ]
        });

        final snapshot = await ref.get();
        expect(snapshot.value, {
          'nested': {
            '0': 'a',
            '1': 'b',
            '2': {'0': 'c', '1': 'd'}
          }
        });
      });

      test('handles Lists in updates', () async {
        final ref = database.ref('items');
        await ref.update({
          'list1': ['a', 'b'],
          'list2': ['c', 'd'],
        });

        final snapshot = await ref.get();
        expect(snapshot.value, {
          'list1': {'0': 'a', '1': 'b'},
          'list2': {'0': 'c', '1': 'd'},
        });
      });

      test('handles null values in Lists', () async {
        final ref = database.ref('items');
        await ref.set(['a', null, 'c']);

        final snapshot = await ref.get();
        expect(snapshot.value, {'0': 'a', '2': 'c'});
      });

      test('handles empty Lists', () async {
        final ref = database.ref('items');
        await ref.set(['a', [], 'c']);

        final snapshot = await ref.get();
        expect(snapshot.value, {'0': 'a', '2': 'c'});
      });

      test('preserves numeric string keys', () async {
        final ref = database.ref('items');
        await ref.set({
          '0': 'a',
          '1': 'b',
          '2': 'c',
        });

        final snapshot = await ref.get();
        expect(snapshot.value, {'0': 'a', '1': 'b', '2': 'c'});
      });

      test('handles List with non-sequential indices', () async {
        final ref = database.ref('items');
        final list = List<String?>.filled(5, null);
        list[0] = 'a';
        list[2] = 'c';
        list[4] = 'e';

        await ref.set(list);

        final snapshot = await ref.get();
        expect(snapshot.value, {
          '0': 'a',
          '2': 'c',
          '4': 'e',
        });
      });
    });
  });
}
