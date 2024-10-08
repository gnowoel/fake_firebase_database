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
    });
  });
}
