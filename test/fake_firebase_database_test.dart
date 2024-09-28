import 'package:flutter_test/flutter_test.dart';

import 'package:fake_firebase_database/fake_firebase_database.dart';

void main() {
  group('FakeFirebaseDatabase', () {
    test('can be instantiated', () {
      final fakeFirebaseDatabase = FakeFirebaseDatabase();

      expect(fakeFirebaseDatabase, isA<FakeFirebaseDatabase>());
    });
  });
}
