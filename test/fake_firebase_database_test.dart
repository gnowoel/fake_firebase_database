import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fake_firebase_database/fake_firebase_database.dart';

void main() {
  final database = FakeFirebaseDatabase.instance;

  tearDown(() {
    database.clear();
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
      expect(ref.path, '/users/123');
    });
  });
}
