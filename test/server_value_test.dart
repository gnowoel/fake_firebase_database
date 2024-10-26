import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_firebase_database/fake_firebase_database.dart';

void main() {
  final database = FakeFirebaseDatabase.instance;

  tearDown(() {
    database.clear();
  });

  group('ServerValue', () {
    group('timestamp', () {
      test('can set current timestamp', () async {
        final ref = database.ref();
        await ref.set(ServerValue.timestamp);

        final snapshot = await ref.get();
        expect(snapshot.value, isA<num>());
        expect(snapshot.value, isNonZero);
      });
    });
  });
}
