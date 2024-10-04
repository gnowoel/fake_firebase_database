import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fake_firebase_database/fake_firebase_database.dart';

void main() {
  final database = FakeFirebaseDatabase.instance;

  setUp(() async {
    final ref = database.ref();
    await ref.set(null);
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

    test('clean up entries starting from the current path', () async {
      final ref1 = database.ref('users/123');

      await ref1.set(null);

      final ref2 = database.ref();
      final snapshot2 = await ref2.get();
      expect(snapshot2.value, null);
    });

    test('remove empty entries all the way up', () async {
      final ref1 = database.ref('users/123');

      await ref1.set({});

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

      final ref11 = database.ref('//');
      final ref21 = database.ref('//users//');
      final ref31 = database.ref('//users//123//');

      await ref11.set(value);
      await ref21.set(value);
      await ref31.set(value);

      final ref12 = database.ref('');
      final ref22 = database.ref('users');
      final ref32 = database.ref('users/123');

      final snapshot12 = await ref12.get();
      final snapshot22 = await ref22.get();
      final snapshot32 = await ref32.get();

      expect(snapshot12.value, value);
      expect(snapshot22.value, value);
      expect(snapshot32.value, value);
    });
  });
}
