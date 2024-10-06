import 'package:flutter_test/flutter_test.dart';

import 'package:fake_firebase_database/fake_firebase_database.dart';

void main() {
  final database = FakeFirebaseDatabase.instance;

  setUp(() async {
    final ref = database.ref();
    await ref.set(null);
  });

  group('FakeDatabaseReference', () {
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

    test('the type should be correct after setting a map', () async {
      final ref = database.ref('users/123');
      final value = {'age': 18};

      await ref.set(value);

      final snapshot = await ref.get();
      expect(snapshot.value, isA<Map<String, dynamic>>());
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

      await ref1.set({'age': 18 as dynamic}); // Mimic a model
      await ref1.update({'age': null});

      final ref2 = database.ref();
      final snapshot2 = await ref2.get();
      expect(snapshot2.value, null);
    });

    test('can save a path with extra slashes', () async {
      final ref1 = database.ref('//');
      final ref2 = database.ref('//users//');
      final ref3 = database.ref('//users//123//');

      expect(ref1.path, '//');
      expect(ref2.path, '//users//');
      expect(ref3.path, '//users//123//');
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

    test('path` returns the correct path value', () async {
      final ref1 = database.ref();
      final ref2 = database.ref('');
      final ref3 = database.ref('/');
      final ref4 = database.ref('/users');
      final ref5 = database.ref('/users/123');

      expect(ref1.path, '/');
      expect(ref2.path, '');
      expect(ref3.path, '/');
      expect(ref4.path, '/users');
      expect(ref5.path, '/users/123');
    });

    test('`key` returns the last part of the path', () async {
      final ref1 = database.ref();
      final ref2 = database.ref('');
      final ref3 = database.ref('/');
      final ref4 = database.ref('/users');
      final ref5 = database.ref('/users/123');

      expect(ref1.key, null);
      expect(ref2.key, '');
      expect(ref3.key, '');
      expect(ref4.key, 'users');
      expect(ref5.key, '123');
    });
  });
}
