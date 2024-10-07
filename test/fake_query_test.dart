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
      test('path` returns the correct path value', () async {
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
  });
}
